# Architecture of the solution {#architecture-of-the-solution}

This example document contains several files with different purpose and structure:

- `istqb.cls` and `markdownthemeistqb_syllabus.sty` are the `\LaTeX`{=tex} template for ISTQB documents:
    - `istqb.cls` defines the design and the `\LaTeX`{=tex} commands provided by the `\LaTeX`{=tex} template.
    - `markdownthemeistqb_syllabus.sty` defines the processing of YAML metadata and the mapping between markdown elements and `\LaTeX`{=tex} commands.
- `example.yml` is a YAML document that contains the metadata of the example document.
- `example.bib` is a `Bib\LaTeX`{=tex} database with references, as discussed in <#section:references>.
- `example-*.md` are markdown documents that contain different parts of the text of the example document.
- `example.tex` is a `\LaTeX`{=tex} document that typesets the example document.

Here is the structure of file `example.tex`:

  1. The files `istqb.cls` and `markdownthemeistqb_syllabus.sty` with the `\LaTeX`{=tex} template are loaded:

     ``` tex
     \documentclass{istqb}
     \usepackage{markdown}
     \markdownSetup {
       import = {
         istqb/syllabus = {
           metadata,
           traceability-matrix as matrix,
         },
       },
     }
     ```

  2. The file `example-document/metadata.yml` with the document metadata is loaded:

     ``` tex
     % Metadata
     \markdownInput[snippet=metadata]{example-document/metadata.yml}
     ```

  3. The file `example-document/bibliography.bib` with references is loaded:

     ``` tex
     % References
     \addbibresource{example-document/bibliography.bib}
     ```

     You may use more `\addbibresource` `\LaTeX`{=tex} commands to include additional `Bíb\LaTeX`{=tex} databases.

  4. The front matter is typeset, including the markdown documents `example-document/copyright.md` and `example-document/revisions.md`:

     ``` tex
     % Landing Page
     \istqblandingpage

     % Copyright Notice
     \markdownInput{example-document/copyright.md}

     % Revision History
     \markdownInput[texComments]{example-document/revisions.md}

     % Table of Contents
     \istqbtableofcontents
     ```

     Here, the `texComments` option is used to allow the breaking of long lines in the revision table using the percent sign (`%`).
     You may use more `\markdownInput` `\LaTeX`{=tex} commands to include additional markdown documents. For each `\markdownInput`
     command, you may provide options supported by the Markdown package for `\TeX`{=tex} [@novotny:2023] like `texComments` to alter the flavor
     of markdown used in the markdown document.

  5. The main matter of the document is typeset, including the markdown documents `example-document/intro.md` and `example-document/content.md`:

     ``` tex
     % Document Text
     \markdownInput{example-document/acknowledgments.md}
     \markdownInput{example-document/00-introduction.md}
     \markdownInput{example-document/01-writing-guidelines.md}
     \markdownInput{example-document/02-intro.md}
     \markdownInput{example-document/03-markdown-guidelines.md}
     \markdownInput{example-document/04-architecture.md}
     ```

     You may use more `\markdownInput` `\LaTeX`{=tex} commands to include additional markdown documents.

  6. The back matter of the document is typeset:

     ``` tex
     % Bibliography
     \printistqbbibliography

     % List of Tables
     \listoftables

     % List of Figures
     \listoffigures

     % Index
     \printindex
     ```

     The back matter also contains an appendix with a traceability matrix between learning objectives and business outcomes. The traceability matrix is based on the file `example-document/traceability-matrix.yml`.

     ``` tex
     % Appendices
     \begin{istqbappendices}

     %% Traceability Matrix
     \markdownInput[snippet=matrix]{example-document/traceability-matrix.yml}

     \end{istqbappendices}
     ```

The example document also contains the directory `img/` with figures, as discussed in <#section:figures>.
