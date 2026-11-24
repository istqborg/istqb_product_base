# Custom latexmk configuration
## Enable shell escape
## The placeholder %P is the same as %S, unless code that should be executed before the source file is specified with
## the option -pretex. The script template.py uses the option to add `\DocumentMetadata` to TeX files.
set_tex_cmds('--shell-escape -interaction=nonstopmode %O %P');

## Output PDF by default
$pdf_mode = 4;

## Treat warnings as errors
$warnings_as_errors = 1;

## Allow many compilation runs
$max_repeat = 10;

## Only print a summary of the run, not the full log.
$silent = 1;
