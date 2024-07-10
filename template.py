# -*- coding: utf-8 -*-

"""
Processes ISTQB documents written with the LaTeX+Markdown template.

"""

from argparse import ArgumentParser, Namespace
import logging
from pathlib import Path
import re
import os


LOGGER = logging.getLogger(__name__)

METADATA_FILETYPES = ['all', 'all-yaml', 'user-yaml'] + sorted(['metadata', 'questions', 'languages'])
DOCUMENT_FILETYPES = sorted(['xlsx', 'markdown', 'eps', 'tex', 'bib'])
FILETYPES = METADATA_FILETYPES + DOCUMENT_FILETYPES


def find_files(args: Namespace):
    paths = sorted(_find_files(args.filetype))
    for path in paths:
        print(path)


def _find_files(file_type: str, root=Path('.')):
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


def main():
    parser = ArgumentParser(prog='IstqbTemplate', description='Process ISTQB documents written with the LaTeX+Markdown template')
    subparsers = parser.add_subparsers()

    parser_find = subparsers.add_parser('find-files', help='Produce a newline-separated list of different types of files in this repository')
    parser_find.add_argument('filetype', choices=FILETYPES, default='all')
    parser_find.set_defaults(func=find_files)

    args = parser.parse_args()
    if not 'func' in args:
        parser.print_help()
    else:
        args.func(args)


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')
    main()
