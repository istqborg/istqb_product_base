# -*- coding: utf-8 -*-

"""
Processes ISTQB documents written with the LaTeX+Markdown template.

"""

from argparse import ArgumentParser, Namespace
from collections import defaultdict
from configparser import ConfigParser
from contextlib import contextmanager
from itertools import chain, repeat
from functools import lru_cache
import json
import logging
from multiprocessing import Pool
from pathlib import Path
import re
import string
import subprocess
from tempfile import NamedTemporaryFile
from typing import Any, Dict, Iterable, List, Optional, Tuple, Union, TYPE_CHECKING
import os
import shutil

from git import Repo, InvalidGitRepositoryError
from thefuzz import process
import yamale
import yaml


LOGGER = logging.getLogger(__name__)

METADATA_FILETYPES = ['all', 'all-yaml', 'user-yaml'] + sorted([
  'metadata', 'questions-yaml', 'questions-markdown', 'languages', 'traceability-matrix',
])
DOCUMENT_FILETYPES = sorted(['xlsx', 'markdown', 'eps', 'tex', 'bib'])
FILETYPES = METADATA_FILETYPES + DOCUMENT_FILETYPES

VALIDATABLE_FILETYPES = ['all', 'all-yaml'] + sorted([
  'metadata', 'questions-yaml', 'languages', 'traceability-matrix', 'tex', 'markdown',
])
CONVERT_TO_DOCX_FILETYPES = ['all', 'user-yaml'] + sorted(['markdown', 'bib'])

CURRENT_DIRECTORY = Path('.').resolve()
ROOT_DIRECTORY = Path(__file__).parent.resolve()
SCHEMA_DIRECTORY = ROOT_DIRECTORY / 'schema'
ROOT_COPY_DIRECTORY = CURRENT_DIRECTORY / 'istqb_product_base'
EXAMPLE_DOCUMENT = CURRENT_DIRECTORY / 'example-document.tex'

CURRENT_REPOSITORY: Optional[Repo]
try:
    CURRENT_REPOSITORY = Repo(CURRENT_DIRECTORY, search_parent_directories=True)
except InvalidGitRepositoryError:
    CURRENT_REPOSITORY = None

LATEXMKRC = ROOT_DIRECTORY / 'latexmkrc'
ISTQB_CFG = ROOT_DIRECTORY / 'istqb.cfg'
ISTQB_MK4 = ROOT_DIRECTORY / 'istqb.mk4'

PANDOC_INPUT_FORMAT = 'commonmark'
PANDOC_EXTENSIONS = ['bracketed_spans', 'fancy_lists', 'pipe_tables', 'raw_attribute']

BUILTIN_IDENTIFIERS = {'section:references', 'section:further-reading'}

MARKDOWNINPUT_REGEXP = re.compile(r'\\markdownInput(\[.*?\])?{(?P<filename>.*?)}', re.DOTALL)
ADDBIBRESOURCE_REGEXP = re.compile(r'\\addbibresource{(?P<filename>.*?)}', re.DOTALL)

ATTRIBUTES_REGEXPS = {
    'section': re.compile(
        '|'.join([
            r'^\s*#.*\{([^}]*)\}\s*$',  # ATX headers
            r'^\s*(?!\s|#).*\{([^}]*)\}\s*\n\s*[=-]',  # Setext headers
        ]),
        re.MULTILINE
    ),
    'figure': re.compile(r'!\[([^]]+)'),  # Figures
    'table': re.compile(r'^\s{1,3}:.*\{([^}]*)\}\s*$', re.MULTILINE),  # Pipe tables
}
CROSS_REFERENCE_REGEXP = re.compile(
    '|'.join([
        r'<#(.+?)>',  # Relative autolink
        r']\(#(.+?)\)',  # Relative direct link
    ])
)
BIBLIOGRAPHIC_REFERENCE_REGEXP = re.compile(r'@([-a-zA-Z0-9#$%&+<>~/_]+)')  # Bracketed and text citations
BIBENTRY_REGEXP = re.compile(r'^\s*@[^{]+\{(.+?)\s*,\s*$', re.MULTILINE)
IDENTIFIER_REGEXP = re.compile(r'#(?P<identifier>\S+)')

XLSX_REGEXP = re.compile(r'\.xlsx$', flags=re.IGNORECASE)
EPS_REGEXP = re.compile(r'\.eps$', flags=re.IGNORECASE)
TEX_REGEXP = re.compile(r'(?<!\.md)\.tex$', flags=re.IGNORECASE)
BIB_REGEXP = re.compile(r'\.bib$', flags=re.IGNORECASE)
MARKDOWN_REGEXP = re.compile(r'\.(md|mdown|markdown)$', flags=re.IGNORECASE)
YAML_REGEXP = re.compile(r'\.ya?ml$', flags=re.IGNORECASE)
TEMPLATE_REGEXP = re.compile(r'\.(sty|cls|lua)$', flags=re.IGNORECASE)

METADATA_REGEXP = re.compile(r'metadata.*\.ya?ml', flags=re.IGNORECASE)
QUESTIONS_YAML_REGEXP = re.compile(r'questions.*\.ya?ml', flags=re.IGNORECASE)
QUESTIONS_MARKDOWN_REGEXP = re.compile(r'questions.*\.(md|mdown|markdown)', flags=re.IGNORECASE)
LANGUAGES_REGEXP = re.compile(r'..\.ya?ml', flags=re.IGNORECASE)
TRACEABILITY_MATRIX_REGEXP = re.compile(r'traceability-matrix\.ya?ml$', flags=re.IGNORECASE)

QUESTIONS_METADATA_REGEXP = re.compile(r'\s{0,3}#\s*metadata\s*', flags=re.IGNORECASE)
QUESTIONS_QUESTION_REGEXP = re.compile(r'\s{0,3}##\s*question\s*', flags=re.IGNORECASE)
QUESTIONS_ANSWERS_REGEXP = re.compile(r'\s{0,3}##\s*answers\s*', flags=re.IGNORECASE)
QUESTIONS_ANSWER_REGEXP = re.compile(
    r'^\s{0,3}(?P<number>[0-9])[.]\s*(?P<text>(.(?!^\s{0,3}[0-9][.]))*)',
    flags=re.IGNORECASE | re.MULTILINE | re.DOTALL,
)
QUESTIONS_EXPLANATION_REGEXP = re.compile(r'\s{0,3}##\s*(explanation|justification)\s*', flags=re.IGNORECASE)


FileLocation = Tuple[Path, int]


def _get_nearest_text(text: str, texts: Iterable[str]) -> str:
    nearest_text, _ = process.extractOne(text, texts)
    return nearest_text


@lru_cache(maxsize=None)  # only show every warning once
def _warning(*args, **kwargs) -> None:
    LOGGER.warning(*args, **kwargs)


def _get_identifiers_from_markdown_files(md_input_paths: Iterable[Path]) -> Iterable[Tuple[FileLocation, str]]:
    for md_input_path in md_input_paths:
        with md_input_path.open('rt') as f:
            text = f.read()
            for prefix, pattern in ATTRIBUTES_REGEXPS.items():
                for attributes_match in pattern.finditer(text):
                    group_number, = [group_number + 1 for group_number, group in enumerate(attributes_match.groups()) if group is not None]
                    attributes = attributes_match.group(group_number)
                    attributes_character_number = attributes_match.start(group_number)

                    raw_identifiers = []
                    if prefix == 'figure':
                        raw_identifiers.append((attributes, 0))
                    else:
                        for identifier_match in IDENTIFIER_REGEXP.finditer(attributes):
                            raw_identifier = identifier_match.group('identifier')
                            assert raw_identifier is not None
                            identifier_character_number = identifier_match.start('identifier')
                            raw_identifiers.append((raw_identifier, identifier_character_number))

                    for (raw_identifier, identifier_character_number) in raw_identifiers:
                        identifier = f'{prefix}:{raw_identifier}'
                        character_number = attributes_character_number + identifier_character_number
                        yield (md_input_path, character_number), identifier


def _get_identifiers_from_bib_files(bib_input_paths: Iterable[Path]) -> Iterable[Tuple[FileLocation, str]]:
    for bib_input_path in bib_input_paths:
        with bib_input_path.open('rt') as f:
            text = f.read()
            for identifier_match in BIBENTRY_REGEXP.finditer(text):
                group_number, = [group_number + 1 for group_number, group in enumerate(identifier_match.groups()) if group is not None]
                identifier = identifier_match.group(group_number)
                character_number = identifier_match.start(group_number)
                yield (bib_input_path, character_number), identifier


def _get_cross_references_from_markdown_files(md_input_paths: Iterable[Path]) -> Iterable[Tuple[FileLocation, str]]:
    for md_input_path in md_input_paths:
        with md_input_path.open('rt') as f:
            text = f.read()
            for identifier_match in CROSS_REFERENCE_REGEXP.finditer(text):
                group_number, = [group_number + 1 for group_number, group in enumerate(identifier_match.groups()) if group is not None]
                identifier = identifier_match.group(group_number)
                character_number = identifier_match.start(group_number)
                yield (md_input_path, character_number), identifier


def _get_bibliographic_references_from_markdown_files(md_input_paths: Iterable[Path]) -> Iterable[Tuple[FileLocation, str]]:
    for md_input_path in md_input_paths:
        with md_input_path.open('rt') as f:
            text = f.read()
            for identifier_match in BIBLIOGRAPHIC_REFERENCE_REGEXP.finditer(text):
                group_number, = [group_number + 1 for group_number, group in enumerate(identifier_match.groups()) if group is not None]
                identifier = identifier_match.group(group_number)
                character_number = identifier_match.start(group_number)
                yield (md_input_path, character_number), identifier


def _get_line_number_from_file_location(location: FileLocation) -> int:
    path, character_number = location
    current_character_number = 0
    with path.open('rt') as f:
        for line_number, line in enumerate(f):
            if current_character_number + len(line) >= character_number:
                return line_number + 1
            current_character_number += len(line)
    raise ValueError(
        f'Tried to determine the line number of character {character_number} in file "{path}" '
        f'but found only {current_character_number} characters'
    )


def _get_references_from_tex_files(tex_input_paths: Iterable[Path]) -> Iterable[Tuple[FileLocation, Path, Iterable[Path]]]:
    for tex_input_path in tex_input_paths:
        with tex_input_path.open('rt') as f:
            text = f.read()
            for pattern in [MARKDOWNINPUT_REGEXP, ADDBIBRESOURCE_REGEXP]:
                for match in pattern.finditer(text):
                    # Yield directly referenced paths.
                    original_referenced_path = Path(match.group('filename'))
                    character_number = match.start('filename')
                    referenced_path = original_referenced_path
                    if not referenced_path.is_absolute():
                        referenced_path = tex_input_path.parent / referenced_path
                    referenced_path = referenced_path.resolve()
                    referenced_paths = [referenced_path]
                    # For YAML questions, yield also MD question source files.
                    if QUESTIONS_YAML_REGEXP.fullmatch(referenced_path.name):
                        for referenced_md_path in referenced_path.parent.glob(f'{referenced_path.stem}.*'):
                            if QUESTIONS_MARKDOWN_REGEXP.fullmatch(referenced_md_path.name):
                                referenced_md_path = referenced_md_path.resolve()
                                referenced_paths.append(referenced_md_path)
                    yield (tex_input_path, character_number), original_referenced_path, referenced_paths


def _flatten_references(references: Iterable[Tuple[FileLocation, Path, Iterable[Path]]]) -> Iterable[Path]:
    return chain(*[paths for *_, paths in references])


def _get_flat_references_from_tex_files(tex_input_paths: Iterable[Path]) -> Iterable[Path]:
    return _flatten_references(_get_references_from_tex_files(tex_input_paths))


def _find_files(file_types: Iterable[str], tex_input_paths: Optional[Iterable[Path]] = None, root: Path = Path('.')) -> Iterable[Path]:
    file_types = list(file_types)
    referenced_files = set(_get_flat_references_from_tex_files(tex_input_paths)) if tex_input_paths is not None else None
    seen_paths = set()
    for parent_directory, subdirectories, filenames in os.walk(root, topdown=True, onerror=print, followlinks=True):

        def keep_path(file_type: str, path: Path) -> bool:
            if path.name.startswith('.'):
                return False
            if path.name in {'template.py', 'check-yaml.lua', 'istqb.cfg', 'istqb.mk4', 'latexmkrc', 'requirements.txt'}:
                return False
            if path.name.startswith('markdowntheme'):
                return False
            if TEMPLATE_REGEXP.search(path.name):
                return False

            if file_type == 'all':
                return True
            if file_type in ('all-yaml', 'user-yaml', 'metadata', 'questions-yaml', 'languages', 'traceability-matrix'):
                all_yaml_match = YAML_REGEXP.search(path.name)

                if not all_yaml_match:
                    return False
                if file_type == 'all-yaml':
                    return True

                metadata_match = METADATA_REGEXP.fullmatch(path.name)
                questions_match = QUESTIONS_YAML_REGEXP.fullmatch(path.name)
                languages_match = path.parent.name == 'languages' and LANGUAGES_REGEXP.fullmatch(path.name)
                traceability_matrix_match = TRACEABILITY_MATRIX_REGEXP.search(path.name)

                if file_type == 'metadata':
                    return bool(metadata_match)
                elif file_type == 'questions-yaml':
                    return bool(questions_match)
                elif file_type == 'languages':
                    return bool(languages_match)
                elif file_type == 'traceability-matrix':
                    return bool(traceability_matrix_match)
                elif file_type == 'user-yaml':
                    return bool(not languages_match)
                else:
                    raise ValueError(f'Unknown file type: {file_type}')
            elif file_type == 'xlsx':
                return bool(XLSX_REGEXP.search(path.name))
            elif file_type == 'eps':
                return bool(EPS_REGEXP.search(path.name))
            elif file_type == 'tex':
                return bool(TEX_REGEXP.search(path.name))
            elif file_type == 'bib':
                return bool(BIB_REGEXP.search(path.name))
            elif file_type == 'markdown':
                return bool(MARKDOWN_REGEXP.search(path.name))
            elif file_type == 'questions-markdown':
                return bool(QUESTIONS_MARKDOWN_REGEXP.fullmatch(path.name))
            else:
                raise ValueError(f'Unknown file type: {file_type}')

        def keep_filename(filename: str) -> Tuple[bool, Optional[Path]]:
            path = (Path(parent_directory) / filename).resolve()
            if referenced_files is not None and path not in referenced_files:
                return False, None
            if not any(keep_path(file_type, path) for file_type in file_types):
                return False, None
            return True, path

        def keep_subdirectory(subdirectory: str) -> bool:
            if subdirectory.startswith('.'):
                return False
            if subdirectory == 'istqb_product_base' and 'languages' not in file_types:
                return False
            if subdirectory in {'template', 'schema', 'markdown', 'venv'}:
                return False
            return True

        removed_subdirectory_indexes = [
            index
            for index, subdirectory in enumerate(subdirectories)
            if not keep_subdirectory(subdirectory)
        ]
        for index in sorted(removed_subdirectory_indexes, reverse=True):
            del subdirectories[index]

        for filename in filenames:
            should_keep, path = keep_filename(filename)
            if should_keep and path not in seen_paths:
                seen_paths.add(path)
                yield path


def _fixup_languages() -> None:
    for path in _find_files(file_types=['languages']):
        _fixup_language(path)


def _run_command(*args: str, text=False, timeout=60) -> Union[str, bytes]:
    try:
        output = subprocess.check_output(args, text=text, stderr=subprocess.STDOUT, timeout=timeout)
    except subprocess.CalledProcessError as e:
        try:
            output = e.output.decode()
        except UnicodeDecodeError:
            output = e.output
        print(output)
        raise e
    return output


def _find_files_in_tex_live(pathname) -> List[Path]:
    paths = _run_command('kpsewhich', pathname, text=True).splitlines()
    paths = list(map(Path, paths))
    return paths


def _find_file_in_tex_live(pathname) -> Path:
    paths = _find_files_in_tex_live(pathname)
    if len(paths) > 1:
        raise ValueError(f'Multiple files "{pathname}" was found in your TeX installation but only one was expected')
    if len(paths) != 1:
        raise ValueError(f'File "{pathname}" not found in your TeX installation (is TeX installed?)')
    path, = paths
    return path


def _fixup_language(path: Path) -> None:
    # Is `babel-language` already in the language definitions?
    with path.open('rt') as rf:
        input_yaml_text = rf.read()
    input_yaml = yaml.safe_load(input_yaml_text)
    if 'babel-language' in input_yaml:
        LOGGER.debug('File "%s" already contains `babel-language`', path)
        return

    # Determine the babel name of the language.
    iso_code = path.name[:2]
    pathname = f'{iso_code}/babel-{iso_code}.ini'
    config_filename = _find_file_in_tex_live(pathname)

    config = ConfigParser()
    config.read(config_filename)
    if 'identification' not in config:
        raise ValueError(f'Section "identification" not found in file "{config_filename}"')
    if 'name.babel' not in config['identification']:
        raise ValueError(f'Field "name.babel" not found in section "identification" of file "{config_filename}"')
    babel_names = config['identification']['name.babel'].split()
    assert len(babel_names) > 0
    babel_name, *_ = babel_names
    if len(babel_names) > 1:
        LOGGER.info(
            'Found multiple babel names in file "%s": %s; using the first one: "%s"',
            config_filename, ', '.join(f'"{name}"' for name in babel_names), babel_name,
        )

    # Add `babel-language` on top of the language definitions.
    LOGGER.info('Added "babel-language: %s" to file "%s"', babel_name, path)
    with path.open('wt') as wf:
        print(f'babel-language: {json.dumps(babel_name, ensure_ascii=False)}', file=wf)
        wf.write(input_yaml_text)


def _fixup_line_endings() -> None:
    for path in _find_files(file_types=['all-yaml', 'markdown', 'tex', 'bib']):
        with path.open('rt', newline='') as rf:
            input_text = rf.read()
        if '\r' not in input_text:
            return

        LOGGER.info('Translating line endings in file "%s"', path)
        with path.open('rt') as rf:
            input_lines = rf.readlines()
        with path.open('wt', newline='\n') as wf:
            wf.writelines(input_lines)

        with path.open('rt', newline='') as rf:
            input_text = rf.read()
        assert '\r' not in input_text


def _validate_files(file_types: Iterable[str], silent: bool = False) -> None:

    def validate_yaml_file(schema, path: Path):
        data = yamale.make_data(path)
        yamale.validate(schema, data)
        _run_command('texlua', f'{ROOT_DIRECTORY / "check-yaml.lua"}')
        if not silent:
            LOGGER.info('Validated file "%s" with schema "%s"', path, schema.name)

    def validate_tex_file(path: Path):
        references = list(_get_references_from_tex_files([path]))
        for (tex_input_path, character_number), original_referenced_path, referenced_paths in references:
            line_number = _get_line_number_from_file_location((tex_input_path, character_number))
            if not any(path.exists() for path in referenced_paths):
                message = f'File "{original_referenced_path}" referenced on line {line_number} of file "{tex_input_path}" not found'
                all_filenames = [str(path) for path in _find_files(['all'])]
                if all_filenames:
                    nearest_filename = _get_nearest_text(str(original_referenced_path), all_filenames)
                    nearest_path = Path(nearest_filename).relative_to(tex_input_path.parent, walk_up=True)
                    message = f'{message}; did you mean "{nearest_path}"?'
                raise ValueError(message)

        if not silent:
            LOGGER.info('Validated file "%s" that references %d other files', path, len(references))

    def validate_markdown_file(path: Path, tex_input_path: Path):
        # Check cross-references.
        md_identifiers: Dict[str, List[Tuple[Path, int]]] = defaultdict(lambda: list())
        bib_identifiers: Dict[str, List[Tuple[Path, int]]] = defaultdict(lambda: list())
        cross_references: Dict[str, List[Tuple[Path, int]]] = defaultdict(lambda: list())
        bibliographic_references: Dict[str, List[Tuple[Path, int]]] = defaultdict(lambda: list())
        num_cross_references, num_bibliographic_references = 0, 0

        md_input_paths = list(_find_files(file_types=['markdown'], tex_input_paths=[tex_input_path]))
        for location, md_identifier in _get_identifiers_from_markdown_files(md_input_paths):
            md_identifiers[md_identifier].append(location)
            if len(md_identifiers[md_identifier]) > 1:
                (first_md_input_path, first_character_number), \
                    (second_md_input_path, second_character_number) = md_identifiers[md_identifier]
                first_line_number = _get_line_number_from_file_location((first_md_input_path, first_character_number))
                second_line_number = _get_line_number_from_file_location((second_md_input_path, second_character_number))
                raise ValueError(
                    f'Markdown identifier "{md_identifier}" is defined twice, once on line {first_line_number} of file '
                    f'"{first_md_input_path}" and once on line {second_line_number} of file "{second_md_input_path}"'
                )
        bib_input_paths = list(_find_files(file_types=['bib'], tex_input_paths=[tex_input_path]))
        for location, bib_identifier in _get_identifiers_from_bib_files(bib_input_paths):
            bib_identifiers[bib_identifier].append(location)
            if len(bib_identifiers[bib_identifier]) > 1:
                (first_bib_input_path, first_character_number), \
                    (second_bib_input_path, second_character_number) = bib_identifiers[bib_identifier]
                first_line_number = _get_line_number_from_file_location((first_bib_input_path, first_character_number))
                second_line_number = _get_line_number_from_file_location((second_bib_input_path, second_character_number))
                raise ValueError(
                    f'BIB identifier "{bib_identifier}" is defined twice, once on line {first_line_number} of file '
                    f'"{first_bib_input_path}" and once on line {second_line_number} of file "{second_bib_input_path}"'
                )

        for location, md_identifier in _get_cross_references_from_markdown_files([path]):
            cross_references[md_identifier].append(location)
            num_cross_references += 1
        for location, bib_identifier in _get_bibliographic_references_from_markdown_files([path]):
            bibliographic_references[bib_identifier].append(location)
            num_bibliographic_references += 1

        missing_md_identifiers = cross_references.keys() - md_identifiers.keys() - BUILTIN_IDENTIFIERS
        for missing_md_identifier in missing_md_identifiers:
            (md_input_path, character_number), *_ = cross_references[missing_md_identifier]
            line_number = _get_line_number_from_file_location((md_input_path, character_number))
            message = (
                f'Markdown identifier "{missing_md_identifier}" referenced on line {line_number} of file "{md_input_path}" not found '
                f'in any of the {len(md_input_paths)} markdown files referenced from file "{tex_input_path}"'
            )
            if md_identifiers:
                nearest_md_identifier = _get_nearest_text(missing_md_identifier, md_identifiers.keys())
                (md_input_path, character_number), *_ = md_identifiers[nearest_md_identifier]
                line_number = _get_line_number_from_file_location((md_input_path, character_number))
                message = f'{message}; did you mean "{nearest_md_identifier}" defined on line {line_number} of file "{md_input_path}"?'
            raise ValueError(message)

        missing_bib_identifiers = bibliographic_references.keys() - bib_identifiers.keys() - BUILTIN_IDENTIFIERS
        for missing_bib_identifier in missing_bib_identifiers:
            (md_input_path, character_number), *_ = bibliographic_references[missing_bib_identifier]
            line_number = _get_line_number_from_file_location((md_input_path, character_number))
            message = (
                f'BIB identifier "{missing_bib_identifier}" referenced on line {line_number} of file "{md_input_path}" not found '
                f'in any of the {len(bib_input_paths)} BIB files referenced from file "{tex_input_path}"'
            )
            if bib_identifiers:
                nearest_bib_identifier = _get_nearest_text(missing_bib_identifier, bib_identifiers.keys())
                (bib_input_path, character_number), *_ = bib_identifiers[nearest_bib_identifier]
                line_number = _get_line_number_from_file_location((bib_input_path, character_number))
                message = f'{message}; did you mean "{nearest_bib_identifier}" defined on line {line_number} of file "{bib_input_path}"?'
            raise ValueError(message)

        unused_md_identifiers = md_identifiers.keys() - cross_references.keys()
        for unused_md_identifier in unused_md_identifiers:
            (md_input_path, character_number), *_ = md_identifiers[unused_md_identifier]
            line_number = _get_line_number_from_file_location((md_input_path, character_number))
            if not silent:
                _warning(
                    (
                        'Markdown identifier "%s" defined on line %d of file "%s" is unused in any of the %d markdown files referenced '
                        'from file "%s"'
                    ),
                    unused_md_identifier, line_number, md_input_path, len(md_input_paths), tex_input_path,
                )

        unused_bib_identifiers = bib_identifiers.keys() - bibliographic_references.keys()
        for unused_bib_identifier in unused_bib_identifiers:
            (bib_input_path, character_number), *_ = bib_identifiers[unused_bib_identifier]
            line_number = _get_line_number_from_file_location((bib_input_path, character_number))
            if not silent:
                _warning(
                    (
                        'BIB identifier "%s" defined on line %d of file "%s" is unused in any of the %d markdown files referenced '
                        'from file "%s"'
                    ),
                    unused_bib_identifier, line_number, bib_input_path, len(md_input_paths), tex_input_path,
                )

        if not silent:
            LOGGER.info(
                'Validated file "%s" that contains %d cross-references and %d bibliographic references',
                path, num_cross_references, num_bibliographic_references,
            )

    for file_type in file_types:
        if file_type in ('metadata', 'all', 'all-yaml'):
            schema = yamale.make_schema(SCHEMA_DIRECTORY / 'metadata.yml')
            for path in _find_files(file_types=['metadata']):
                validate_yaml_file(schema, path)
        if file_type in ('questions-yaml', 'all', 'all-yaml'):
            _convert_md_questions_to_yaml()
            schema = yamale.make_schema(SCHEMA_DIRECTORY / 'questions.yml')
            for path in _find_files(file_types=['questions-yaml']):
                validate_yaml_file(schema, path)
        if file_type in ('languages', 'all', 'all-yaml'):
            _fixup_languages()
            schema = yamale.make_schema(SCHEMA_DIRECTORY / 'language.yml')
            for path in _find_files(file_types=['languages']):
                validate_yaml_file(schema, path)
        if file_type in ('traceability-matrix', 'all', 'all-yaml'):
            schema = yamale.make_schema(SCHEMA_DIRECTORY / 'traceability-matrix.yml')
            for path in _find_files(file_types=['traceability-matrix']):
                validate_yaml_file(schema, path)
        if file_type in ('tex', 'all'):
            for path in _find_files(file_types=['tex']):
                validate_tex_file(path)
        if file_type in ('markdown', 'all'):
            for tex_input_path in _find_files(file_types=['tex']):
                md_input_paths = list(_find_files(file_types=['markdown'], tex_input_paths=[tex_input_path]))
                if tex_input_path == EXAMPLE_DOCUMENT:
                    LOGGER.info(
                        'Skipping the validation of %d markdown documents referenced from example document "%s"',
                        len(md_input_paths), tex_input_path,
                    )
                    continue
                for md_input_path in md_input_paths:
                    validate_markdown_file(md_input_path, tex_input_path)


def _convert_eps_files_to_pdf() -> None:
    for input_path in _find_files(file_types=['eps']):
        output_path = input_path.parent / f'{input_path.stem}-eps-converted-to.pdf'
        if not output_path.exists():
            _run_command('epstopdf', f'{input_path}', f'{output_path}')
            LOGGER.info('Converted file "%s" to "%s"', input_path, output_path)


def _convert_xlsx_files_to_pdf() -> None:
    for input_path in _find_files(file_types=['xlsx']):
        output_path = input_path.with_suffix('.pdf')
        if not output_path.exists():
            _run_command('libreoffice', '--headless', '--convert-to', 'pdf', f'{input_path}', '--outdir', f'{output_path.parent}')
            LOGGER.info('Converted file "%s" to "%s"', input_path, output_path)


def _read_md_questions(input_file: Path) -> Iterable[Tuple[int, Dict]]:
    with input_file.open('rt') as f:
        input_md_lines = f.read().splitlines()

    question_number = 1
    question: Optional[Dict] = None
    section: Optional[str] = None
    section_line_numbers = []
    heading_line_number: Optional[int] = None

    def finish_section():
        assert question is not None
        assert section is not None
        assert heading_line_number is not None
        if not section_line_numbers:
            raise ValueError(f'An empty section in file "{input_file}" below line {heading_line_number+1}')
        section_lines = [input_md_lines[index] for index in section_line_numbers]
        section_text = '\n'.join(section_lines)
        line_range = f'{heading_line_number+1}-{max(section_line_numbers)+1}'
        if section == 'metadata':
            input_yaml = yaml.safe_load(section_text)
            if 'lo' not in input_yaml:
                raise ValueError(f'Missing YAML key "lo" in file "{input_file}" on lines {line_range}')
            question['learning-objective'] = input_yaml['lo']
            if 'k-level' not in input_yaml:
                raise ValueError(f'Missing YAML key "k-level" in file "{input_file}" on lines {line_range}')
            question['k-level'] = input_yaml['k-level']
            if 'points' not in input_yaml:
                raise ValueError(f'Missing YAML key "points" in file "{input_file}" on lines {line_range}')
            question['number-of-points'] = input_yaml['points']
            if 'correct' not in input_yaml:
                raise ValueError(f'Missing YAML key "correct" in file "{input_file}" on lines {line_range}')
            question['correct'] = input_yaml['correct']
        elif section == 'question':
            question['question'] = section_text
        elif section == 'answers':
            answers = {}
            for answer_match in QUESTIONS_ANSWER_REGEXP.finditer(section_text):
                answer_number = int(answer_match.group('number'))
                answer_letter = string.ascii_lowercase[answer_number-1]
                answer_text = answer_match.group('text').strip()
                answers[answer_letter] = answer_text
            question['answers'] = answers
        elif section == 'explanation':
            question['explanation'] = section_text
        else:
            raise ValueError(f'Unknown section "{section}" in file "{input_file}" on lines {line_range}')
        section_line_numbers.clear()

    for line_number, line in enumerate(input_md_lines):
        # Check whether a new question has started.
        metadata_match = QUESTIONS_METADATA_REGEXP.fullmatch(line)
        if question is None and not metadata_match:
            if not line.strip():
                continue
            raise ValueError(f'Unexpected line {line_number+1} of file "{input_file}": "{line}"; expected "# metadata" or similar')
        if metadata_match:
            if section is not None:
                finish_section()
            if question is not None:
                yield question_number, question
                question_number += 1
            question = {}
            section = 'metadata'
            heading_line_number = line_number
            continue

        # Check whether a new section has started.
        question_match = QUESTIONS_QUESTION_REGEXP.fullmatch(line)
        answers_match = QUESTIONS_ANSWERS_REGEXP.fullmatch(line)
        explanation_match = QUESTIONS_EXPLANATION_REGEXP.fullmatch(line)
        if question_match:
            finish_section()
            section = 'question'
            heading_line_number = line_number
            continue
        if answers_match:
            finish_section()
            section = 'answers'
            heading_line_number = line_number
            continue
        if explanation_match:
            finish_section()
            section = 'explanation'
            heading_line_number = line_number
            continue

        # Otherwise, accumulate the lines.
        section_line_numbers.append(line_number)

    if section is not None:
        finish_section()
    if question is not None:
        yield question_number, question


def _convert_md_questions_to_yaml() -> None:
    for input_path in _find_files(['questions-markdown']):
        output_path = input_path.with_suffix('.yml')
        if output_path.exists():
            _warning('Skipping creation of existing file "%s"', output_path)
            continue

        output_yaml = {'questions': dict(_read_md_questions(input_path))}

        if not output_yaml:
            _warning('Found no questions in file "%s", skipping creation of empty file "%s"', input_path, output_path)
        else:
            with output_path.open('wt') as f:
                print('questions:', file=f)
                for question_number, question in sorted(output_yaml['questions'].items()):
                    print(f'  {question_number}:', file=f)
                    print(f'    learning-objective: {json.dumps(question["learning-objective"], ensure_ascii=False)}', file=f)
                    print(f'    k-level: {json.dumps(question["k-level"], ensure_ascii=False)}', file=f)
                    print(f'    number-of-points: {json.dumps(question["number-of-points"], ensure_ascii=False)}', file=f)
                    print(f'    question: {json.dumps(question["question"], ensure_ascii=False)}', file=f)
                    print(f'    answers: {json.dumps(question["answers"], ensure_ascii=False)}', file=f)
                    print(f'    correct: {json.dumps(question["correct"], ensure_ascii=False)}', file=f)
                    print(f'    explanation: {json.dumps(question["explanation"], ensure_ascii=False)}', file=f)
                LOGGER.info('Converted file "%s" to "%s"', input_path, output_path)


def _convert_yaml_questions_to_md() -> None:
    for input_path in _find_files(['questions-yaml']):
        output_path = input_path.with_suffix('.md')
        if output_path.exists():
            _warning('Skipping creation of existing file "%s"', output_path)
            continue

        with input_path.open('rt') as f:
            input_yaml_text = f.read()
        input_yaml = yaml.safe_load(input_yaml_text)

        with output_path.open('wt') as f:
            for question_index, (question_number, question) in enumerate(sorted(input_yaml['questions'].items())):
                if question_index > 0:
                    print(file=f)
                print('# metadata', file=f)
                print(f'lo: {question["learning-objective"]}', file=f)
                print(f'k-level: {question["k-level"]}', file=f)
                print(f'points: {question["number-of-points"]}', file=f)
                print(f'correct: {question["correct"]}', file=f)
                print(file=f)
                print('## question', file=f)
                print(question['question'].rstrip('\r\n'), file=f)
                print(file=f)
                print('## answers', file=f)
                for answer_index, (answer_letter, answer) in enumerate(sorted(question['answers'].items())):
                    answer = str(answer).rstrip('\r\n')
                    print(f'{answer_index + 1}. {answer}', file=f)
                print(file=f)
                print('## justification', file=f)
                print(question['explanation'].rstrip('\r\n'), file=f)
            LOGGER.info('Converted file "%s" to "%s"', input_path, output_path)


@lru_cache(maxsize=None)
def _changed_paths(base_branch='origin/main') -> List[Path]:
    if CURRENT_REPOSITORY is None:
        return []
    base_commit = CURRENT_REPOSITORY.commit(base_branch)
    head_commit = CURRENT_REPOSITORY.head.commit
    changed_paths = []
    for diff in base_commit.diff(head_commit):
        if diff.change_type in ('A', 'M'):
            changed_paths.append((Path(CURRENT_REPOSITORY.git_dir) / '..' / diff.b_path).resolve())
    return changed_paths


def _should_do_full_compile() -> bool:
    if CURRENT_REPOSITORY is None:
        return False
    try:
        branch_name = CURRENT_REPOSITORY.active_branch.name
        return branch_name == 'main'
    except TypeError:  # if HEAD is detached
        return False


@contextmanager
def _change_directory(new_path):
    original_path = os.getcwd()
    try:
        os.chdir(new_path)
        yield
    finally:
        os.chdir(original_path)


def _get_metadata_path(input_path: Path, action: str) -> Optional[Path]:
    metadata_paths = list(_find_files(file_types=['metadata'], tex_input_paths=[input_path]))
    if len(metadata_paths) == 0:
        if action:
            _warning('Found no metadata of file "%s" when trying to %s', input_path, action)
        return None
    if len(metadata_paths) > 1:
        if action:
            formatted_paths = ', '.join(f'"{path}"' for path in sorted(metadata_paths))
            _warning('Found multiple metadata (%s) of file "%s" when trying to %s', formatted_paths, input_path, action)
        return None
    metadata_path, = metadata_paths
    return metadata_path


def _should_compile_tex_file_to_pdf(input_path: Path) -> bool:
    if (input_path.parent / input_path.stem / 'NO_PDF').exists():
        return False

    metadata_path = _get_metadata_path(input_path, 'determine whether it should be compiled to PDF; will compile')
    if metadata_path is None:
        return True
    with metadata_path.open('rt') as f:
        metadata_yaml_text = f.read()
    metadata_yaml = yaml.safe_load(metadata_yaml_text)

    if 'pdf-output' in metadata_yaml:
        pdf_output = bool(metadata_yaml['pdf-output'])
        return pdf_output

    return True


def _is_release_version(version: str) -> bool:
    return version.lower().strip() == 'release'


def _should_compile_tex_file_to_html(input_path: Path) -> bool:
    if (input_path.parent / input_path.stem / 'NO_HTML').exists():
        return False

    metadata_path = _get_metadata_path(input_path, 'determine whether it should be compiled to HTML; will not compile')
    if metadata_path is None:
        return False

    with metadata_path.open('rt') as f:
        metadata_yaml_text = f.read()
    metadata_yaml = yaml.safe_load(metadata_yaml_text)

    if 'html-output' in metadata_yaml:
        html_output = bool(metadata_yaml['html-output'])
        return html_output
    if 'version' in metadata_yaml:
        version = str(metadata_yaml['version'])
        return _is_release_version(version)

    return False


def _should_compile_tex_file_to_epub(input_path: Path) -> bool:
    if (input_path.parent / input_path.stem / 'NO_EPUB').exists():
        return False
    if (input_path.parent / input_path.stem / 'NO_HTML').exists():
        return False

    metadata_path = _get_metadata_path(input_path, 'determine whether it should be compiled to EPUB; will not compile')
    if metadata_path is None:
        return False

    with metadata_path.open('rt') as f:
        metadata_yaml_text = f.read()
    metadata_yaml = yaml.safe_load(metadata_yaml_text)

    if 'epub-output' in metadata_yaml:
        epub_output = bool(metadata_yaml['epub-output'])
        return epub_output
    if 'html-output' in metadata_yaml:
        html_output = bool(metadata_yaml['html-output'])
        return html_output
    if 'version' in metadata_yaml:
        version = str(metadata_yaml['version'])
        return _is_release_version(version)

    return False


def _should_compile_tex_file_to_docx(input_path: Path) -> bool:
    if (input_path.parent / input_path.stem / 'NO_DOCX').exists():
        return False

    if _is_sample_exam_answers(input_path):
        return False

    metadata_path = _get_metadata_path(input_path, 'determine whether it should be compiled to DOCX; will not compile')
    if metadata_path is None:
        return False

    with metadata_path.open('rt') as f:
        metadata_yaml_text = f.read()
    metadata_yaml = yaml.safe_load(metadata_yaml_text)

    if 'docx-output' in metadata_yaml:
        docx_output = bool(metadata_yaml['docx-output'])
        return docx_output
    if 'version' in metadata_yaml:
        version = str(metadata_yaml['version'])
        return not _is_release_version(version)

    return False


def _is_sample_exam_questions(input_path: Path) -> bool:
    return 'questions' in input_path.name


def _is_sample_exam_answers(input_path: Path) -> bool:
    return 'answers' in input_path.name


def _get_project_name(input_path: Path) -> str:
    basename = input_path.stem
    if input_path == EXAMPLE_DOCUMENT:
        return basename
    metadata_path = _get_metadata_path(input_path, f'determine the project name; will use "{basename}"')
    if metadata_path is None:
        return basename

    with metadata_path.open('rt') as f:
        metadata_yaml_text = f.read()
    metadata_yaml = yaml.safe_load(metadata_yaml_text)

    organization = metadata_yaml.get('organization', 'ISTQB®').replace('®', '').strip()
    code = metadata_yaml.get('code', 'CODE').strip()
    document_type = metadata_yaml.get('type', 'TYPE').strip()
    if _is_sample_exam_questions(input_path):
        document_type = f'{document_type} Questions'
    elif _is_sample_exam_answers(input_path):
        document_type = f'{document_type} Answers'
    version = metadata_yaml.get('version', 'VERSION').strip()
    language = metadata_yaml.get('language', 'en').upper().strip()
    project_name = f'{organization}-{code}-{document_type}-{version}-{language}'
    return project_name


def _compile_tex_file_to_pdf(input_path: Path, previous_continuous: bool) -> Optional[Path]:
    if not _should_compile_tex_file_to_pdf(input_path):
        return
    if previous_continuous:
        _run_command('latexmk', '-pvc', '-r', f'{LATEXMKRC}', f'{input_path}', timeout=None)
    else:
        _run_command('latexmk', '-r', f'{LATEXMKRC}', f'{input_path}', timeout=600)
    project_name = _get_project_name(input_path)
    output_path = Path(f'{project_name}.pdf')
    input_path.with_suffix('.pdf').rename(output_path)
    return output_path


def _compile_tex_file_to_html(input_path: Path, output_directory: Path) -> Optional[Path]:
    if not _should_compile_tex_file_to_html(input_path):
        return
    project_name = _get_project_name(input_path)
    output_path = output_directory / project_name / input_path.with_suffix('.html').name
    _run_command('make4ht', '-s', '-c', f'{ISTQB_CFG}', '-e', f'{ISTQB_MK4}', '-d', f'{output_path.parent}', f'{input_path}', timeout=600)
    return output_path


def _compile_tex_file_to_epub(input_path: Path, output_directory: Path) -> Optional[Path]:
    if not _should_compile_tex_file_to_epub(input_path):
        return

    output_directory = output_directory.resolve()
    build_directory = output_directory / 'build' / input_path.stem

    def prune_output_directory(parent_directory: str, filenames: List[str]) -> List[str]:
        parent_directory = Path(parent_directory).resolve()
        if parent_directory == output_directory.parent:
            return [output_directory.name]
        return []

    shutil.copytree(input_path.parent, build_directory, ignore=prune_output_directory)

    with _change_directory(build_directory):
        _run_command(
            'tex4ebook', '-s', '-c', f'{ISTQB_CFG}', '-e', f'{ISTQB_MK4}', '-d', f'{output_directory}', input_path.name,
            timeout=600,
        )

    shutil.rmtree(build_directory)

    project_name = _get_project_name(input_path)
    output_path = output_directory / f'{project_name}.epub'
    (output_directory / input_path.with_suffix('.epub').name).rename(output_path)
    return output_path


def _compile_tex_file_to_docx(input_path: Path, output_directory: Path) -> Optional[Path]:
    if not _should_compile_tex_file_to_docx(input_path):
        return

    # Collect files referenced from the TeX file.
    markdown_texts = []
    for nested_path in _get_flat_references_from_tex_files(tex_input_paths=[input_path]):
        if MARKDOWN_REGEXP.search(nested_path.name):
            with nested_path.open('rt') as f:
                markdown_text = f.read()
                markdown_texts.append(markdown_text)
        elif YAML_REGEXP.search(nested_path.name) and not QUESTIONS_YAML_REGEXP.fullmatch(nested_path.name):
            with nested_path.open('rt') as f:
                markdown_text = f'``` yml\n{f.read()}\n```'
                markdown_texts.append(markdown_text)
        elif BIB_REGEXP.search(nested_path.name):
            with nested_path.open('rt') as f:
                markdown_text = f'``` bib\n{f.read()}\n```'
                markdown_texts.append(markdown_text)

    # Convert the collected files to DOCX.
    markdown_text = '\n\n'.join(markdown_texts)
    pandoc_from_format = '+'.join([PANDOC_INPUT_FORMAT, *PANDOC_EXTENSIONS])
    project_name = _get_project_name(input_path)
    output_path = output_directory / f'{project_name}.docx'
    with NamedTemporaryFile('wt', delete=False) as f:
        print(markdown_text, file=f)
        f.close()
        _run_command('pandoc', '-f', f'{pandoc_from_format}', '-i', f'{f.name}', '-o', f'{output_path}')
        os.unlink(f.name)

    return output_path


if TYPE_CHECKING:  # The Protocol class is unavailable in Python <3.8 but that should not prevent us from running the script.
    from typing import Protocol

    class CompilationFunction(Protocol):
        def __call__(self, input_path: Path, *args, **kwargs) -> Optional[Path]: ...


def _compile_fn(args: Tuple['CompilationFunction', Path, Tuple[Any], Dict[Any, Any]]) -> Tuple[Path, Optional[Path]]:
    compile_fn, input_path, args, kwargs = args
    output_path = compile_fn(input_path, *args, *kwargs)
    return input_path, output_path


def _should_compile_tex_file(input_path: Path) -> bool:
    if _should_do_full_compile():
        return True
    if input_path == EXAMPLE_DOCUMENT:
        return True

    changed_paths = set(_changed_paths())
    referenced_paths = set(chain([input_path], _get_flat_references_from_tex_files([input_path])))
    return bool(referenced_paths & changed_paths)


def _compile_tex_files(compile_fn: 'CompilationFunction', *args, **kwargs) -> None:
    input_paths = list(_find_files(file_types=['tex']))
    if not _should_do_full_compile():
        removed_indexes = []
        for input_path_index, input_path in enumerate(input_paths):
            if not _should_compile_tex_file(input_path):
                removed_indexes.append(input_path_index)
                LOGGER.info('Skipped the compilation of file "%s" because it has not changed in this branch', input_path)
        for removed_index in reversed(removed_indexes):
            del input_paths[removed_index]

    if not input_paths:
        return

    os.environ['TEXINPUTS'] = f'.:{ROOT_COPY_DIRECTORY}/template:'
    try:
        try:
            shutil.rmtree(ROOT_COPY_DIRECTORY)
        except FileNotFoundError:
            pass
        shutil.copytree(ROOT_DIRECTORY, ROOT_COPY_DIRECTORY)

        _validate_files(file_types=['all'], silent=True)
        _fixup_line_endings()
        _convert_eps_files_to_pdf()
        _convert_xlsx_files_to_pdf()

        compile_parameters = zip(repeat(compile_fn), input_paths, repeat(args), repeat(kwargs))
        with Pool(None) as pool:
            for input_path, output_path in pool.imap_unordered(_compile_fn, compile_parameters):
                if output_path is None:
                    LOGGER.info('Skipped the compilation of file "%s" because it has been disabled', input_path)
                else:
                    assert output_path.exists(), f'File "{output_path}" does not exist'
                    LOGGER.info('Compiled file "%s" to "%s"', input_path, output_path)
    finally:
        del os.environ['TEXINPUTS']
        try:
            shutil.rmtree(ROOT_COPY_DIRECTORY)
        except FileNotFoundError:
            pass


def _compile_tex_files_to_pdf(previous_continuous: bool) -> None:
    _compile_tex_files(_compile_tex_file_to_pdf, previous_continuous)


def _compile_tex_files_to_html(output_directory: Path) -> None:
    output_directory.mkdir(parents=True, exist_ok=True)
    _compile_tex_files(_compile_tex_file_to_html, output_directory)


def _compile_tex_files_to_epub(output_directory: Path) -> None:
    output_directory.mkdir(parents=True, exist_ok=True)
    _compile_tex_files(_compile_tex_file_to_epub, output_directory)


def _compile_tex_files_to_docx(output_directory: Path) -> None:
    output_directory.mkdir(parents=True, exist_ok=True)
    _compile_tex_files(_compile_tex_file_to_docx, output_directory)


def find_files(args: Namespace) -> None:
    file_types = [args.filetype]
    tex_input_paths = [Path(vars(args)['from'])] if vars(args)['from'] is not None else None
    paths = sorted(_find_files(file_types=file_types, tex_input_paths=tex_input_paths))
    for path in paths:
        print(path)


def fixup_languages(args: Namespace) -> None:
    _fixup_languages()


def fixup_line_endings(args: Namespace) -> None:
    _fixup_line_endings()


def validate_files(args: Namespace) -> None:
    _validate_files(file_types=[args.filetype])


def convert_eps_files_to_pdf(args: Namespace) -> None:
    _convert_eps_files_to_pdf()


def convert_xlsx_files_to_pdf(args: Namespace) -> None:
    _convert_xlsx_files_to_pdf()


def convert_md_questions_to_yaml(args: Namespace) -> None:
    _convert_md_questions_to_yaml()


def convert_yaml_questions_to_md(args: Namespace) -> None:
    _convert_yaml_questions_to_md()


def compile_tex_files_to_pdf(args: Namespace) -> None:
    _compile_tex_files_to_pdf(args.previous_continuous)


def compile_tex_files_to_html(args: Namespace) -> None:
    _compile_tex_files_to_html(output_directory=Path(args.outputdir))


def compile_tex_files_to_epub(args: Namespace) -> None:
    _compile_tex_files_to_epub(output_directory=Path(args.outputdir))


def compile_tex_files_to_docx(args: Namespace) -> None:
    _compile_tex_files_to_docx(output_directory=Path(args.outputdir))


def main():
    parser = ArgumentParser(
        prog='template.py',
        description='Process ISTQB documents written with the LaTeX+Markdown template',
        epilog='This program requires that Git, LibreOffice, Pandoc, TeX Live and Tidy HTML5 are installed.',
    )
    subparsers = parser.add_subparsers()

    parser_find_files = subparsers.add_parser(
        'find-files',
        help='Produce a newline-separated list of different types of files in this repository',
    )
    parser_find_files.add_argument('filetype', choices=FILETYPES)
    parser_find_files.add_argument('-f', '--from', help='a TeX document in which the files should be used')
    parser_find_files.set_defaults(func=find_files)

    parser_fixup_languages = subparsers.add_parser(
        'fixup-languages',
        help='Determine and add `babel-language` to language definitions if missing',
    )
    parser_fixup_languages.set_defaults(func=fixup_languages)

    parser_fixup_line_endings = subparsers.add_parser(
        'fixup-line-endings',
        help='Convert all text files to Unix-style line endings',
    )
    parser_fixup_line_endings.set_defaults(func=fixup_line_endings)

    parser_validate_files = subparsers.add_parser(
        'validate-files',
        help='Validate the different types of files in this repository',
    )
    parser_validate_files.add_argument('filetype', choices=VALIDATABLE_FILETYPES)
    parser_validate_files.set_defaults(func=validate_files)

    parser_convert_eps_files_to_pdf = subparsers.add_parser(
        'convert-eps-to-pdf',
        help='Convert all EPS files in this repository to PDF',
    )
    parser_convert_eps_files_to_pdf.set_defaults(func=convert_eps_files_to_pdf)

    parser_convert_xlsx_files_to_pdf = subparsers.add_parser(
        'convert-xlsx-to-pdf',
        help='Convert all XLSX files in this repository to PDF',
    )
    parser_convert_xlsx_files_to_pdf.set_defaults(func=convert_xlsx_files_to_pdf)

    parser_convert_md_questions_to_yaml = subparsers.add_parser(
        'convert-md-questions-to-yaml',
        help='Convert all MD files with questions definitions to YAML',
    )
    parser_convert_md_questions_to_yaml.set_defaults(func=convert_md_questions_to_yaml)

    parser_convert_yaml_questions_to_md = subparsers.add_parser(
        'convert-yaml-questions-to-md',
        help='Convert all YAML files with questions definitions to MD',
    )
    parser_convert_yaml_questions_to_md.set_defaults(func=convert_yaml_questions_to_md)

    parser_compile_tex_to_pdf = subparsers.add_parser(
        'compile-tex-to-pdf',
        help='Compile all TeX files in this repository to PDF',
    )
    parser_compile_tex_to_pdf.add_argument(
        '-pvc', '--previous-continuous',
        action='store_true',
        help='Keep recompiling the TeX files as they change',
    )
    parser_compile_tex_to_pdf.set_defaults(func=compile_tex_files_to_pdf)

    parser_compile_tex_to_html = subparsers.add_parser(
        'compile-tex-to-html',
        help='Compile all TeX files in this repository to HTML',
    )
    parser_compile_tex_to_html.add_argument('outputdir')
    parser_compile_tex_to_html.set_defaults(func=compile_tex_files_to_html)

    parser_compile_tex_to_epub = subparsers.add_parser(
        'compile-tex-to-epub',
        help='Compile all TeX files in this repository to EPUB',
    )
    parser_compile_tex_to_epub.add_argument('outputdir')
    parser_compile_tex_to_epub.set_defaults(func=compile_tex_files_to_epub)

    parser_compile_tex_files_to_docx = subparsers.add_parser(
        'compile-tex-to-docx',
        help='Compile all TeX files in this repository to DOCX',
    )
    parser_compile_tex_files_to_docx.add_argument('outputdir')
    parser_compile_tex_files_to_docx.set_defaults(func=compile_tex_files_to_docx)

    args = parser.parse_args()
    if 'func' not in args:
        parser.print_help()
    else:
        args.func(args)


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, format='%(asctime)s\t[%(levelname)s]\t%(message)s')
    main()
