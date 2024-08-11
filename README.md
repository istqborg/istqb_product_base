# ISTQB LaTeX+Markdown Template

This repository contains the code of the LaTeX+Markdown template that is used
to typeset ISTQB documents.

## Usage

To typeset ISTQB documents on your computer, take the following steps:

1. **Install [Docker][install-docker] and [Git][installing-git].**

2. **Download the Docker image [`istqb_product_base`][istqb-product-base].**

   For example, here is how you would do this in a terminal of a Linux system:
   ``` sh
   $ docker pull ghcr.io/istqborg/istqb_product_base
   ```

3. **Download one of [ISTQB document repositories][istqborg] with Git.**

   For example, here is how you would download the example documents from the [`istqb_product_template`][istqb_product_template] repository in a terminal of a Linux system:
   ``` sh
   $ git clone https://github.com/istqborg/istqb_product_template
   ```

4. **Typeset the documents with the Docker image.**

   For example, here is how you would typeset the example documents to PDF in a terminal of a Linux system:
   ``` sh
   $ docker run --rm -it -v "$PWD"/istqb_product_template/:/mnt -w /mnt ghcr.io/istqborg/istqb_product_base compile-tex-to-pdf
   ```
   ```
   Compiled file "/mnt/accreditation-guidelines.tex" to "ISTQB-CT-TEMP-Accreditation Guidelines-v0.1-EN.pdf"
   Compiled file "/mnt/body-of-knowledge.tex" to "ISTQB-CT-TEMP-Body of Knowledge-v0.1-EN.pdf"
   Compiled file "/mnt/release-notes.tex" to "ISTQB-CT-TEMP-Release Notes-v0.1-EN.pdf"
   Compiled file "/mnt/sample-exam-answers.tex" to "ISTQB-CT-TEMP-Sample Exam -- Answers-v0.1-EN.pdf"
   Compiled file "/mnt/sample-exam-questions.tex" to "ISTQB-CT-TEMP-Sample Exam -- Questions-v0.1-EN.pdf"
   Compiled file "/mnt/syllabus.tex" to "ISTQB-CT-TEMP-Syllabus-v0.1-EN.pdf"
   ```

   Besides typesetting documents to PDF with the `compile-tex-to-pdf` command, you can also convert them to HTML, EPUB, and DOCX, among other things. Here is how you would list the available commands in a terminal of a Linux system:
   ``` sh
   $ docker run --rm -it ghcr.io/istqborg/istqb_product_base --help
   ```
   ```
   usage: template.py [-h]
                   {find-files,fixup-languages,fixup-line-endings,validate-files,convert-eps-to-pdf,convert-xlsx-to-pdf,convert-md-questions-to-yaml,convert-yaml-questions-to-md,compile-tex-to-pdf,compile-tex-to-html,compile-tex-to-epub,compile-tex-to-docx} ...

   Process ISTQB documents written with the LaTeX+Markdown template

   positional arguments:
     {find-files,fixup-languages,fixup-line-endings,validate-files,convert-eps-to-pdf,convert-xlsx-to-pdf,convert-md-questions-to-yaml,convert-yaml-questions-to-md,compile-tex-to-pdf,compile-tex-to-html,compile-tex-to-epub,compile-tex-to-docx}
       find-files          Produce a newline-separated list of different types of files in this repository
       fixup-languages     Determine and add `babel-language` to language definitions if missing
       fixup-line-endings  Convert all text files to Unix-style line endings
       validate-files      Validate the different types of files in this repository
       convert-eps-to-pdf  Convert all EPS files in this repository to PDF
       convert-xlsx-to-pdf
                           Convert all XLSX files in this repository to PDF
       convert-md-questions-to-yaml
                           Convert all MD files with questions definitions to YAML
       convert-yaml-questions-to-md
                           Convert all YAML files with questions definitions to MD
       compile-tex-to-pdf  Compile all TeX files in this repository to PDF
       compile-tex-to-html
                           Compile all TeX files in this repository to HTML
       compile-tex-to-epub
                           Compile all TeX files in this repository to EPUB
       compile-tex-to-docx
                           Compile all TeX files in this repository to DOCX

   options:
     -h, --help            show this help message and exit
   ```

 [install-docker]: https://docs.docker.com/get-docker/ "Get Docker | Docker Docs"
 [installing-git]: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git "Git - Installing Git"
 [istqb-product-base]: https://github.com/istqborg/istqb_product_base/pkgs/container/istqb_product_base "Package istqb_product_base"
 [istqborg]: https://github.com/istqborg "ISTQB.ORG"
 [istqb_product_template]: https://github.com/istqborg/istqb_product_template "istqborg/istqb_product_template: Example documents for the LaTeX+Markdown template that can be forked as a base for new products"

## Further Reading

For more information about the LaTeX+Markdown template, consult the following materials:

1. [An example ISTQB document][example-document] that documents how the template can be used by authors.
2. [A whitepaper][whitepaper] that documents how the template can be extended to further document types by programmers.

 [example-document]: https://github.com/istqborg/istqb_product_base/releases/download/latest/example-document.pdf
 [whitepaper]: https://github.com/witiko/markdown-themes-in-practice/releases/download/latest/tb140starynovotny-markdown-themes.pdf
