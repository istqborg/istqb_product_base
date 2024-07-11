# -*- coding: utf-8 -*-

"""
Processes ISTQB documents written with the LaTeX+Markdown template.

"""

from argparse import ArgumentParser, Namespace
from configparser import ConfigParser
import json
import logging
from pathlib import Path
import re
import subprocess
from typing import Iterable, List
import os
import shutil
import sys

from git import Repo
import yamale
import yaml


LOGGER = logging.getLogger(__name__)

METADATA_FILETYPES = ['all', 'all-yaml', 'user-yaml'] + sorted(['metadata', 'questions', 'languages'])
DOCUMENT_FILETYPES = sorted(['xlsx', 'markdown', 'eps', 'tex', 'bib'])
FILETYPES = METADATA_FILETYPES + DOCUMENT_FILETYPES

VALIDATABLE_FILETYPES = sorted(['metadata', 'questions', 'languages'])

ROOT_DIRECTORY = Path(__file__).parent.resolve()
SCHEMA_DIRECTORY = ROOT_DIRECTORY / 'schema'


def _find_files(file_types: Iterable[str], root=Path('.')) -> Iterable[Path]:
    file_types = list(file_types)
    for parent_directory, subdirectories, filenames in os.walk(root, topdown=True, onerror=print, followlinks=True):

        def _keep_filename(file_type: str, filename: str) -> bool:
            if filename.startswith('.'):
                return False
            if filename in {'template.py', 'check-yaml.lua', 'istqb.cfg', 'istqb.mk4', 'latexmkrc', 'requirements.txt'}:
                return False
            if filename.startswith('markdowntheme'):
                return False
            if re.search('\.(sty|cls|lua)$', filename):
                return False

            if file_type == 'all':
                return True
            if file_type in ('all-yaml', 'user-yaml', 'metadata', 'questions', 'languages'):
                all_yaml_match = re.search('\.ya?ml$', filename, flags=re.IGNORECASE)

                if not all_yaml_match:
                    return False
                if file_type == 'all-yaml':
                    return True

                metadata_match = re.fullmatch('metadata\.ya?ml', filename, flags=re.IGNORECASE)
                questions_match = re.fullmatch('questions\.ya?ml', filename, flags=re.IGNORECASE)
                languages_match = Path(parent_directory).name == 'languages' and re.fullmatch('..\.ya?ml', filename, flags=re.IGNORECASE)

                if file_type == 'metadata':
                    return metadata_match
                elif file_type == 'questions':
                    return questions_match
                elif file_type == 'languages':
                    return languages_match
                elif file_type == 'user-yaml':
                    return not languages_match
                else:
                    raise ValueError(f'Unknown file type: {file_type}')
            elif file_type == 'xlsx':
                return re.search('\.xlsx$', filename, flags=re.IGNORECASE)
            elif file_type == 'eps':
                return re.search('\.eps$', filename, flags=re.IGNORECASE)
            elif file_type == 'tex':
                return re.search('\.tex$', filename, flags=re.IGNORECASE)
            elif file_type == 'bib':
                return re.search('\.bib$', filename, flags=re.IGNORECASE)
            elif file_type == 'markdown':
                return re.search('\.(md|mdown|markdown)$', filename, flags=re.IGNORECASE)
            else:
                raise ValueError(f'Unknown file type: {file_type}')

        def keep_filename(filename: str) -> bool:
            return any(_keep_filename(file_type, filename) for file_type in file_types)

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
            if keep_filename(filename):
                yield Path(parent_directory) / filename


def _fixup_languages() -> None:
    for path in _find_files(file_types=['languages']):
        _fixup_language(path)


def _find_files_in_tex_live(pathname) -> List[Path]:
    paths = subprocess.check_output(['kpsewhich', pathname], text=True).splitlines()
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
        LOGGER.debug(f'File %s already contains `babel-language`', path)
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
        LOGGER.info('Found multiple babel names in file "%s": %s; using the first one: %s', config_filename, ', '.join(babel_names), babel_name)

    # Add `babel-language` on top of the language definitions.
    LOGGER.info('Adding "babel-language: %s" to file "%s"', babel_name, path)
    with path.open('wt') as wf:
        print(f'babel-language: {json.dumps(babel_name)}', file=wf)
        wf.write(input_yaml_text)


def _fixup_line_endings(path: Path) -> None:
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
        subprocess.check_output(['texlua', f'{ROOT_DIRECTORY / "check-yaml.lua"}'])
        LOGGER.info('Validated file "%s" with schema "%s"', path, schema.name)

    for file_type in file_types:
        if file_type == 'metadata':
            schema = yamale.make_schema(SCHEMA_DIRECTORY / 'metadata.yml')
            for path in _find_files(file_types=['metadata']):
                validate_file(schema, path)
        elif file_type == 'questions':
            schema = yamale.make_schema(SCHEMA_DIRECTORY / 'questions.yml')
            for path in _find_files(file_types=['questions']):
                validate_file(schema, path)
        elif file_type == 'languages':
            _fixup_languages()
            schema = yamale.make_schema(SCHEMA_DIRECTORY / 'language.yml')
            for path in _find_files(file_types=['languages']):
                validate_file(schema, path)
        else:
            raise ValueError(f'Unknown file type: {file_type}')


def _convert_eps_to_pdf() -> None:
    for input_path in _find_files(file_types=['eps']):
        output_path = input_path.parent / f'{input_path.stem}-eps-converted-to.pdf'
        if not output_path.exists():
            subprocess.check_output(['epstopdf', f'{input_path}', f'{output_path}'])
            LOGGER.info('Converted file "%s" to "%s"', input_path, output_path)


def _is_on_main_branch(path: Path) -> bool:
    repo = Repo(path.parent, search_parent_directories=True)
    return repo.active_branch.name == 'main'


def _convert_xlsx_to_pdf() -> None:
    example_image_path = None
    for input_path in _find_files(file_types=['xlsx']):
        output_path = input_path.with_suffix('.pdf')
        if not output_path.exists():
            if _is_on_main_branch(input_path):
                subprocess.check_output(['libreoffice7.3', '--headless', '--convert-to', 'pdf', f'{input_path}', '--outdir', f'{output_path.parent}'])
                LOGGER.info('Converted file "%s" to "%s"', input_path, output_path)
            else:
                if example_image_path is None:
                    example_image_path = _find_file_in_tex_live('example-image.pdf')
                shutil.copy(example_image_path, output_path)
                LOGGER.info('Copied file "%s" to "%s"', example_image_path, output_path)


def find_files(args: Namespace) -> None:
    paths = sorted(_find_files(file_types=[args.filetype]))
    for path in paths:
        print(path)


def fixup_languages(args: Namespace) -> None:
    _fixup_languages()


def fixup_line_endings(args: Namespace) -> None:
    for path in _find_files(file_types=['all-yaml', 'markdown', 'tex', 'bib']):
        _fixup_line_endings(path)


def validate_files(args: Namespace) -> None:
    _validate_files(file_types=[args.filetype])


def convert_eps_to_pdf(args: Namespace) -> None:
    _convert_eps_to_pdf()


def convert_xlsx_to_pdf(args: Namespace) -> None:
    _convert_xlsx_to_pdf()


def main():
    parser = ArgumentParser(
        prog='template.py',
        description='Process ISTQB documents written with the LaTeX+Markdown template',
        epilog='This program requires that Git, LibreOffice, and TeX Live are installed.',
    )
    subparsers = parser.add_subparsers()

    parser_find_files = subparsers.add_parser(
        'find-files',
        help='Produce a newline-separated list of different types of files in this repository',
    )
    parser_find_files.add_argument('filetype', choices=FILETYPES, default='all')
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

    parser_convert_eps_to_pdf = subparsers.add_parser(
        'convert-eps-to-pdf',
        help='Convert EPS files in this repository to PDF',
    )
    parser_convert_eps_to_pdf.set_defaults(func=convert_eps_to_pdf)

    parser_convert_xlsx_to_pdf = subparsers.add_parser(
        'convert-xlsx-to-pdf',
        help='Convert XLSX files in this repository to PDF',
    )
    parser_convert_xlsx_to_pdf.set_defaults(func=convert_xlsx_to_pdf)

    args = parser.parse_args()
    if not 'func' in args:
        parser.print_help()
    else:
        args.func(args)


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')
    main()
