# Custom latexmk configuration
## Enable shell escape
set_tex_cmds('--shell-escape %O %S');

## Output PDF by default
$pdf_mode = 1;

## Treat warnings as errors
$warnings_as_errors = 1;
