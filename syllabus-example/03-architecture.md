# Architecture of the solution

This example document contains several files with different purpose and structure:

- `istqb.cls` and `markdownthemeistqb_syllabus.sty` are the `\LaTeX`{=tex} template for ISTQB documents:
    - `istqb.cls` defines the design and the `\LaTeX`{=tex} commands provided by the `\LaTeX`{=tex} template.
    - `markdownthemeistqb_syllabus.sty` defines the processing of YAML metadata and the mapping between markdown elements and `\LaTeX`{=tex} commands.
- `example.yml` is a YAML document that contains the metadata of the example document.
- `example.bib` is a `Bíb\LaTeX`{=tex} database with references, as discussed in <#section:references>.
- `example-*.md` are markdown documents that contain different parts of the text of the example document.
- `example.tex` is a `\LaTeX`{=tex} document that typesets the example document.

Here is the structure of file `example.tex`:

  1. The files `istqb.cls` and `markdownthemeistqb_syllabus.sty` with the `\LaTeX`{=tex} template are loaded:

     ``` tex
     \documentclass{istqb}
     \usepackage{markdown}
     \markdownSetup{
       import = {
         istqb/syllabus = metadata
       }
     }
     ```

  2. The file `syllabus-example/metadata.yml` with the document metadata is loaded:

     ``` tex
     % Metadata
     \markdownInput[snippet=metadata]{syllabus-example/metadata.yml}
     ```

  3. The file `syllabus-example/bibliography.bib` with references is loaded:

     ``` tex
     % References
     \addbibresource{syllabus-example/bibliography.bib}
     ```

     You may use more `\addbibresource` `\LaTeX`{=tex} commands to include additional `Bíb\LaTeX`{=tex} databases.

  4. The front matter is typeset, including the markdown documents `syllabus-example/copyright.md` and `syllabus-example/revisions.md`:

     ``` tex
     % Landing Page
     \istqblandingpage
    
     % Copyright Notice
     \markdownInput{syllabus-example/copyright.md}
    
     % Revision History
     \markdownInput[texComments]{syllabus-example/revisions.md}
    
     % Table of Contents
     \tableofcontents
     ```

     Here, the `texComments` option is used to allow the breaking of long lines in the revision table using the percent sign (`%`).
     You may use more `\markdownInput` `\LaTeX`{=tex} commands to include additional markdown documents. For each `\markdownInput`
     command, you may provide options supported by the Markdown package for `\TeX`{=tex} [@novotny:2023] like `texComments` to alter the flavor
     of markdown used in the markdown document.

  5. The main matter of the document is typeset, including the markdown documents `syllabus-example/intro.md` and `syllabus-example/content.md`:

     ``` tex
     % Document Text
     \markdownInput{syllabus-example/acknowledgments.md}
     \markdownInput{syllabus-example/00-introduction.md}
     \markdownInput{syllabus-example/01-writing-guidelines.md}
     \markdownInput{syllabus-example/02-intro.md}
     \markdownInput{syllabus-example/02-markdown-guidelines.md}
     \markdownInput{syllabus-example/03-architecture.md}
     ```

     You may use more `\markdownInput` `\LaTeX`{=tex} commands to include additional markdown documents.

  6. The back matter of the document is typeset:

     ``` tex
     % Bibliography
     \nocite{*}  % Include references that are not cited in the text
     \printistqbbibliography
    
     % List of Tables
     \listoftables
    
     % List of Figures
     \listoffigures
    
     % Index
     \printindex
     ```

The example document also contains the directory `img/` with figures, as discussed in <#section:figures>.
