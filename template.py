# -*- coding: utf-8 -*-

"""
Processes ISTQB documents written with the LaTeX+Markdown template.

"""

from argparse import ArgumentParser, Namespace
from configparser import ConfigParser
from contextlib import contextmanager
from itertools import chain, repeat
from functools import lru_cache
import json
import logging
from multiprocessing import Pool
from pathlib import Path
import re
import subprocess
from tempfile import NamedTemporaryFile
from typing import Any, Dict, Iterable, List, Optional, Tuple, Union, TYPE_CHECKING
import os
import shutil

from git import Repo, InvalidGitRepositoryError
import yamale
import yaml


LOGGER = logging.getLogger(__name__)

METADATA_FILETYPES = ['all', 'all-yaml', 'user-yaml'] + sorted(['metadata', 'questions', 'languages'])
DOCUMENT_FILETYPES = sorted(['xlsx', 'markdown', 'eps', 'tex', 'bib'])
FILETYPES = METADATA_FILETYPES + DOCUMENT_FILETYPES

VALIDATABLE_FILETYPES = ['all', 'all-yaml'] + sorted(['metadata', 'questions', 'languages'])
CONVERT_TO_DOCX_FILETYPES = ['all', 'user-yaml'] + sorted(['markdown', 'bib'])

CURRENT_DIRECTORY = Path('.').resolve()
ROOT_DIRECTORY = Path(__file__).parent.resolve()
SCHEMA_DIRECTORY = ROOT_DIRECTORY / 'schema'
ROOT_COPY_DIRECTORY = CURRENT_DIRECTORY / 'istqb_product_base'

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

MARKDOWNINPUT_REGEXP = re.compile(r'\\markdownInput(\[.*?\])?{(?P<filename>.*?)}', re.DOTALL)


def _get_references_from_tex_file(tex_input_paths: Iterable[Path]) -> Iterable[Path]:
    for tex_input_path in tex_input_paths:
        with tex_input_path.open('rt') as f:
            text = f.read()
            for match in MARKDOWNINPUT_REGEXP.finditer(text):
                path = Path(match.group('filename'))
                if not path.is_absolute():
                    path = tex_input_path.parent / path
                path = path.resolve()
                yield path


def _find_files(file_types: Iterable[str], tex_input_paths: Optional[Iterable[Path]] = None, root: Path = Path('.')) -> Iterable[Path]:
    file_types = list(file_types)
    referenced_files = set(_get_references_from_tex_file(tex_input_paths)) if tex_input_paths is not None else None
    for parent_directory, subdirectories, filenames in os.walk(root, topdown=True, onerror=print, followlinks=True):

        def keep_path(file_type: str, path: Path) -> bool:
            if path.name.startswith('.'):
                return False
            if path.name in {'template.py', 'check-yaml.lua', 'istqb.cfg', 'istqb.mk4', 'latexmkrc', 'requirements.txt'}:
                return False
            if path.name.startswith('markdowntheme'):
                return False
            if re.search(r'\.(sty|cls|lua)$', path.name):
                return False

            if file_type == 'all':
                return True
            if file_type in ('all-yaml', 'user-yaml', 'metadata', 'questions', 'languages'):
                all_yaml_match = re.search(r'\.ya?ml$', path.name, flags=re.IGNORECASE)

                if not all_yaml_match:
                    return False
                if file_type == 'all-yaml':
                    return True

                metadata_match = re.fullmatch(r'metadata\.ya?ml', path.name, flags=re.IGNORECASE)
                questions_match = re.fullmatch(r'questions\.ya?ml', path.name, flags=re.IGNORECASE)
                languages_match = path.parent.name == 'languages' and re.fullmatch(r'..\.ya?ml', path.name, flags=re.IGNORECASE)

                if file_type == 'metadata':
                    return bool(metadata_match)
                elif file_type == 'questions':
                    return bool(questions_match)
                elif file_type == 'languages':
                    return bool(languages_match)
                elif file_type == 'user-yaml':
                    return bool(not languages_match)
                else:
                    raise ValueError(f'Unknown file type: {file_type}')
            elif file_type == 'xlsx':
                return bool(re.search(r'\.xlsx$', path.name, flags=re.IGNORECASE))
            elif file_type == 'eps':
                return bool(re.search(r'\.eps$', path.name, flags=re.IGNORECASE))
            elif file_type == 'tex':
                return bool(re.search(r'\.tex$', path.name, flags=re.IGNORECASE))
            elif file_type == 'bib':
                return bool(re.search(r'\.bib$', path.name, flags=re.IGNORECASE))
            elif file_type == 'markdown':
                return bool(re.search(r'\.(md|mdown|markdown)$', path.name, flags=re.IGNORECASE))
            else:
                raise ValueError(f'Unknown file type: {file_type}')

        def keep_filename(filename: str) -> Tuple[bool, Optional[Path]]:
            path = (Path(parent_directory) / filename).resolve()
            if referenced_files is not None and path not in referenced_files:
                return False, None
            if not any(keep_path(file_type, path) for file_type in file_types):
                return False, None
            return True, path

        def prune_subdirectory(subdirectory: str) -> bool:
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
            if not prune_subdirectory(subdirectory)
        ]
        for index in sorted(removed_subdirectory_indexes, reverse=True):
            del subdirectories[index]

        for filename in filenames:
            should_keep, path = keep_filename(filename)
            if should_keep:
                yield path


def _fixup_languages() -> None:
    for path in _find_files(file_types=['languages']):
        _fixup_language(path)


def _run_command(*args: str, text=False) -> Union[str, bytes]:
    try:
        output = subprocess.check_output(args, text=text, stderr=subprocess.STDOUT)
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
        LOGGER.debug('File %s already contains `babel-language`', path)
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
        print(f'babel-language: {json.dumps(babel_name)}', file=wf)
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


def _validate_files(file_types: Iterable[str]) -> None:

    def validate_file(schema, path: Path):
        data = yamale.make_data(path)
        yamale.validate(schema, data)
        _run_command('texlua', f'{ROOT_DIRECTORY / "check-yaml.lua"}')
        LOGGER.info('Validated file "%s" with schema "%s"', path, schema.name)

    for file_type in file_types:
        if file_type in ('metadata', 'all', 'all-yaml'):
            schema = yamale.make_schema(SCHEMA_DIRECTORY / 'metadata.yml')
            for path in _find_files(file_types=['metadata']):
                validate_file(schema, path)
        if file_type in ('questions', 'all', 'all-yaml'):
            schema = yamale.make_schema(SCHEMA_DIRECTORY / 'questions.yml')
            for path in _find_files(file_types=['questions']):
                validate_file(schema, path)
        if file_type in ('languages', 'all', 'all-yaml'):
            _fixup_languages()
            schema = yamale.make_schema(SCHEMA_DIRECTORY / 'language.yml')
            for path in _find_files(file_types=['languages']):
                validate_file(schema, path)


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


@lru_cache(maxsize=None)
def _changed_paths(base_branch='origin/main') -> List[Path]:
    if CURRENT_REPOSITORY is None:
        return []
    base_commit = CURRENT_REPOSITORY.commit(base_branch)
    head_commit = CURRENT_REPOSITORY.head.commit
    changed_paths = []
    for diff in base_commit.diff(head_commit):
        if diff.change_type in ('A', 'M'):
            changed_paths.append((Path(CURRENT_REPOSITORY.git_dir) / diff.b_path).resolve())
    return changed_paths


def _should_do_full_compile() -> bool:
    if CURRENT_REPOSITORY is None:
        return False
    branch_name = CURRENT_REPOSITORY.active_branch.name
    return branch_name == 'main'


@contextmanager
def _change_directory(new_path):
    original_path = os.getcwd()
    try:
        os.chdir(new_path)
        yield
    finally:
        os.chdir(original_path)


def _get_metadata_paths(input_path: Path) -> List[Path]:
    referenced_paths = set(chain([input_path], _get_references_from_tex_file([input_path])))
    metadata_paths = set(_find_files(file_types=['metadata'])) & referenced_paths
    return sorted(metadata_paths)


def _should_compile_tex_file_to_pdf(input_path: Path) -> bool:
    if (input_path.parent / input_path.stem / 'NO_PDF').exists():
        return False

    metadata_paths = _get_metadata_paths(input_path)
    if len(metadata_paths) == 0:
        LOGGER.warning(
            'Found no metadata of file "%s" when trying to determine whether it should be compiled to PDF; will compile',
            input_path,
        )
        return True
    if len(metadata_paths) > 1:
        LOGGER.warning(
            'Found multiple metadata (%s) of file "%s" when trying to determine whether it should be compiled to PDF; will compile',
            ', '.join(f'"{path}"' for path in sorted(metadata_paths)), input_path,
        )
        return True

    metadata_path, = metadata_paths
    with metadata_path.open('rt') as f:
        metadata_yaml_text = f.read()
    metadata_yaml = yaml.safe_load(metadata_yaml_text)

    if 'pdf-output' in metadata_yaml:
        pdf_output = bool(metadata_yaml['pdf_output'])
        return pdf_output

    return True


def _is_release_version(version: str) -> bool:
    return version.lower().strip() == 'release'


def _should_compile_tex_file_to_html(input_path: Path) -> bool:
    if (input_path.parent / input_path.stem / 'NO_HTML').exists():
        return False

    metadata_paths = _get_metadata_paths(input_path)
    if len(metadata_paths) == 0:
        LOGGER.warning(
            'Found no metadata of file "%s" when trying to determine whether it should be compiled to HTML; will not compile',
            input_path,
        )
        return False
    if len(metadata_paths) > 1:
        LOGGER.warning(
            'Found multiple metadata (%s) of file "%s" when trying to determine whether it should be compiled to HTML; will not compile',
            ', '.join(f'"{path}"' for path in sorted(metadata_paths)), input_path,
        )
        return False

    metadata_path, = metadata_paths
    with metadata_path.open('rt') as f:
        metadata_yaml_text = f.read()
    metadata_yaml = yaml.safe_load(metadata_yaml_text)

    if 'html-output' in metadata_yaml:
        html_output = bool(metadata_yaml['html_output'])
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

    metadata_paths = _get_metadata_paths(input_path)
    if len(metadata_paths) == 0:
        LOGGER.warning(
            'Found no metadata of file "%s" when trying to determine whether it should be compiled to EPUB; will not compile',
            input_path,
        )
        return False
    if len(metadata_paths) > 1:
        LOGGER.warning(
            'Found multiple metadata (%s) of file "%s" when trying to determine whether it should be compiled to EPUB; will not compile',
            ', '.join(f'"{path}"' for path in sorted(metadata_paths)), input_path,
        )
        return False

    metadata_path, = metadata_paths
    with metadata_path.open('rt') as f:
        metadata_yaml_text = f.read()
    metadata_yaml = yaml.safe_load(metadata_yaml_text)

    if 'epub-output' in metadata_yaml:
        epub_output = bool(metadata_yaml['epub_output'])
        return epub_output
    if 'html-output' in metadata_yaml:
        html_output = bool(metadata_yaml['html_output'])
        return html_output
    if 'version' in metadata_yaml:
        version = str(metadata_yaml['version'])
        return _is_release_version(version)

    return False


def _compile_tex_file_to_pdf(input_path: Path) -> Optional[Path]:
    if not _should_compile_tex_file_to_pdf(input_path):
        return
    _run_command('latexmk', '-gg', '-r', f'{LATEXMKRC}', f'{input_path}')
    if input_path.name != 'example-document.tex':
        with input_path.with_suffix('.istqb_project_name').open('rt') as f:
            project_name = f.read().strip()
            output_path = Path(f'{project_name}.pdf')
        input_path.with_suffix('.pdf').rename(output_path)
    else:
        output_path = input_path.with_suffix('.pdf')
    return output_path


def _compile_tex_file_to_html(input_path: Path, output_directory: Path) -> Optional[Path]:
    if not _should_compile_tex_file_to_html(input_path):
        return
    output_path = output_directory / input_path.stem / input_path.with_suffix('.html').name
    _run_command('make4ht', '-s', '-c', f'{ISTQB_CFG}', '-e', f'{ISTQB_MK4}', '-d', f'{output_path.parent}', f'{input_path}')
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
        _run_command('tex4ebook', '-s', '-c', f'{ISTQB_CFG}', '-e', f'{ISTQB_MK4}', '-d', f'{output_directory}', input_path.name)

    shutil.rmtree(build_directory)

    output_path = output_directory / input_path.with_suffix('.epub').name
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
    changed_paths = set(_changed_paths())
    referenced_paths = set(chain([input_path], _get_references_from_tex_file([input_path])))
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

        _fixup_languages()
        _validate_files(file_types=['all'])
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


def _compile_tex_files_to_pdf() -> None:
    _compile_tex_files(_compile_tex_file_to_pdf)


def _compile_tex_files_to_html(output_directory: Path) -> None:
    output_directory.mkdir(parents=True, exist_ok=True)
    _compile_tex_files(_compile_tex_file_to_html, output_directory)


def _compile_tex_files_to_epub(output_directory: Path) -> None:
    output_directory.mkdir(parents=True, exist_ok=True)
    _compile_tex_files(_compile_tex_file_to_epub, output_directory)


def _convert_files_to_docx(output_directory: Path, file_types: Iterable[str]) -> None:
    output_directory.mkdir(parents=True, exist_ok=True)

    def create_nested_output_directory(input_path: Path) -> Tuple[Path, Path]:
        nested_output_directory = output_directory / input_path.relative_to(CURRENT_DIRECTORY).parent
        nested_output_directory.mkdir(parents=True, exist_ok=True)
        output_path = nested_output_directory / f'{input_path.name}.docx'
        return nested_output_directory, output_path

    pandoc_from_format = '+'.join([PANDOC_INPUT_FORMAT, *PANDOC_EXTENSIONS])
    for file_type in file_types:
        if file_type in ('all', 'markdown'):
            for input_path in _find_files(file_types=['markdown']):
                nested_output_directory, output_path = create_nested_output_directory(input_path)
                _run_command('pandoc', '-f', pandoc_from_format, '-i', f'{input_path}', '-o', f'{output_path}')
                assert output_path.exists(), f'File "{output_path}" does not exist'
                LOGGER.info('Converted file "%s" to "%s"', input_path, output_path)
        if file_type in ('all', 'user-yaml'):
            for input_path in _find_files(file_types=['user-yaml']):
                nested_output_directory, output_path = create_nested_output_directory(input_path)
                with NamedTemporaryFile('wt', delete=False) as wf, input_path.open('rt') as rf:
                    print(f'``` yml\n{rf.read()}\n```', file=wf)
                    wf.close()
                    _run_command('pandoc', '-f', f'{pandoc_from_format}+hard_line_breaks', '-i', f'{wf.name}', '-o', f'{output_path}')
                    os.unlink(wf.name)
                assert output_path.exists(), f'File "{output_path}" does not exist'
                LOGGER.info('Converted file "%s" to "%s"', input_path, output_path)
        if file_type in ('all', 'bib'):
            for input_path in _find_files(file_types=['bib']):
                nested_output_directory, output_path = create_nested_output_directory(input_path)
                with NamedTemporaryFile('wt', delete=False) as wf, input_path.open('rt') as rf:
                    print(f'``` bib\n{rf.read()}\n```', file=wf)
                    wf.close()
                    _run_command('pandoc', '-f', f'{pandoc_from_format}+hard_line_breaks', '-i', f'{wf.name}', '-o', f'{output_path}')
                    os.unlink(wf.name)
                assert output_path.exists(), f'File "{output_path}" does not exist'
                LOGGER.info('Converted file "%s" to "%s"', input_path, output_path)


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


def compile_tex_files_to_pdf(args: Namespace) -> None:
    _compile_tex_files_to_pdf()


def compile_tex_files_to_html(args: Namespace) -> None:
    _compile_tex_files_to_html(output_directory=Path(args.outputdir))


def compile_tex_files_to_epub(args: Namespace) -> None:
    _compile_tex_files_to_epub(output_directory=Path(args.outputdir))


def convert_files_to_docx(args: Namespace) -> None:
    _convert_files_to_docx(output_directory=Path(args.outputdir), file_types=[args.filetype])


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

    parser_compile_tex_to_pdf = subparsers.add_parser(
        'compile-tex-to-pdf',
        help='Compile all TeX files in this repository to PDF',
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

    parser_convert_files_to_docx = subparsers.add_parser(
        'convert-to-docx',
        help='Convert the different types of files in this repository to DOCX',
    )
    parser_convert_files_to_docx.add_argument('filetype', choices=CONVERT_TO_DOCX_FILETYPES)
    parser_convert_files_to_docx.add_argument('outputdir')
    parser_convert_files_to_docx.set_defaults(func=convert_files_to_docx)

    args = parser.parse_args()
    if 'func' not in args:
        parser.print_help()
    else:
        args.func(args)


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')
    main()
