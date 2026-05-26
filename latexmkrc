# Custom latexmk configuration
## Enable shell escape
set_tex_cmds('--shell-escape -interaction=nonstopmode %O %S');

## Output PDF by default
$pdf_mode = 1;

## Treat warnings as errors
$warnings_as_errors = 1;

## Allow many compilation runs
$max_repeat = 10;

## Only print a summary of the run, not the full log.
$silent = 1;
