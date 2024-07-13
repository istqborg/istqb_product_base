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

   For example, here is how you would download the CTAL-TA documents from the [`istqb-ctal-ta`][istqb-ctal-ta] repository in a terminal of a Linux system:
   ``` sh
   $ git clone https://github.com/istqborg/istqb-ctal-ta
   ```

4. **Typeset the documents with the Docker image.**

   For example, here is how you would typeset the CTAL-TA documents to PDF in a terminal of a Linux system:
   ``` sh
   $ docker run --rm -it -v "$PWD"/istqb-ctal-ta/:/mnt -w /mnt ghcr.io/istqborg/istqb_product_base compile-tex-to-pdf
   ```
   ```
   Compiled file "release-notes.tex" to "ISTQB-CT-TEMP-Release Notes-Version v0.1-EN.pdf"
   Compiled file "accreditation-guidelines.tex" to "ISTQB-CT-TEMP-Accreditation Guidelines-Version v0.1-EN.pdf"
   ```

   Besides typesetting documents to PDF with the `compile-tex-to-pdf` command, you can also convert them to HTML, EPUB, and DOCX, among other things. Here is how you would list the available commands in a terminal of a Linux system:
   ``` sh
   $ docker run --rm -it ghcr.io/istqborg/istqb_product_base --help
   ```
   ```
   usage: template.py [-h] {find-files,fixup-languages,fixup-line-endings,validate-files,convert-eps-to-pdf,convert-xlsx-to-pdf,compile-tex-to-pdf,compile-tex-to-html,compile-tex-to-epub,convert-to-docx} ...

   Process ISTQB documents written with the LaTeX+Markdown template

   positional arguments:
     {find-files,fixup-languages,fixup-line-endings,validate-files,convert-eps-to-pdf,convert-xlsx-to-pdf,compile-tex-to-pdf,compile-tex-to-html,compile-tex-to-epub,convert-to-docx}
       find-files          Produce a newline-separated list of different types of files in this repository
       fixup-languages     Determine and add `babel-language` to language definitions if missing
       fixup-line-endings  Convert all text files to Unix-style line endings
       validate-files      Validate the different types of files in this repository
       convert-eps-to-pdf  Convert all EPS files in this repository to PDF
       convert-xlsx-to-pdf
                           Convert all XLSX files in this repository to PDF
       compile-tex-to-pdf  Compile all TeX files in this repository to PDF
       compile-tex-to-html
                           Compile all TeX files in this repository to HTML
       compile-tex-to-epub
                           Compile all TeX files in this repository to EPUB
       convert-to-docx     Convert the different types of files in this repository to DOCX

   options:
     -h, --help            show this help message and exit
   ```

 [install-docker]: https://docs.docker.com/get-docker/ "Get Docker | Docker Docs"
 [installing-git]: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git "Git - Installing Git"
 [istqb-product-base]: https://github.com/istqborg/istqb_product_base/pkgs/container/istqb_product_base "Package istqb_product_base"
 [istqborg]: https://github.com/istqborg "ISTQB.ORG"
 [istqb-ctal-ta]: https://github.com/istqborg/istqb-ctal-ta "istqborg/istqb-ctal-ta: Certified Tester Advanced Level Test Analyst (CTAL-TA)"

## Further Reading

For more information about the LaTeX+Markdown template, consult the following materials:

1. [An example ISTQB document][example-document] that documents how the template can be used by authors.
2. [A whitepaper][whitepaper] that documents how the template can be extended to further document types by programmers.

 [example-document]: https://github.com/istqborg/istqb_product_base/releases/download/latest/example-document.pdf
 [whitepaper]: https://github.com/witiko/markdown-themes-in-practice/releases/download/latest/tb140starynovotny-markdown.pdf
