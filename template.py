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
from typing import Iterable
import os

import yaml


LOGGER = logging.getLogger(__name__)

METADATA_FILETYPES = ['all', 'all-yaml', 'user-yaml'] + sorted(['metadata', 'questions', 'languages'])
DOCUMENT_FILETYPES = sorted(['xlsx', 'markdown', 'eps', 'tex', 'bib'])
FILETYPES = METADATA_FILETYPES + DOCUMENT_FILETYPES


def _find_files(file_type: str, root=Path('.')) -> Iterable[Path]:
    for parent_directory, subdirectories, filenames in os.walk(root, topdown=True, onerror=print, followlinks=True):

        def keep_filename(filename: str):
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
                if not re.search('\.ya?ml$', filename, flags=re.IGNORECASE):
                    return False

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
                    return not (metadata_match or questions_match or languages_match)
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

        def prune_subdirectory(subdirectory: str):
            if subdirectory.startswith('.'):
                return False
            if subdirectory in {'istqb_product_base', 'template', 'schema', 'markdown'}:
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
    config_filenames = subprocess.check_output(['kpsewhich', pathname], text=True).splitlines()
    assert len(config_filenames) <= 1
    if len(config_filenames) != 1:
        raise ValueError(f'File "{pathname}" not found in your TeX installation (is TeX installed?)')
    config_filename, = config_filenames

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


def find_files(args: Namespace) -> None:
    paths = sorted(_find_files(args.filetype))
    for path in paths:
        print(path)


def fixup_languages(args: Namespace) -> None:
    for path in _find_files(file_type='languages'):
        _fixup_language(path)


def main():
    parser = ArgumentParser(prog='IstqbTemplate', description='Process ISTQB documents written with the LaTeX+Markdown template')
    subparsers = parser.add_subparsers()

    parser_find = subparsers.add_parser('find-files', help='Produce a newline-separated list of different types of files in this repository')
    parser_find.add_argument('filetype', choices=FILETYPES, default='all')
    parser_find.set_defaults(func=find_files)

    parser_fixup_languages = subparsers.add_parser('fixup-languages', help='Determine and add `babel-language` to language definitions if missing')
    parser_fixup_languages.set_defaults(func=fixup_languages)

    args = parser.parse_args()
    if not 'func' in args:
        parser.print_help()
    else:
        args.func(args)


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')
    main()
