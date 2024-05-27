# Markdown & `\LaTeX`{=tex} syntax examples

This chapter explains how to use the template for ISTQB® documents, but explaning specific syntax of Markdown and `\LaTeX`{=tex} to be used while creating content or completing a document.

## Landing page

Data for the Landing page are defined in the file `metadata.yml` as follows:

```yaml
schema: Certified Tester
level: Foundation Level
title: Example Document
prefix: EXMPL
code: CT-EXMPL
type: Syllabus
version: v0.1
date: YYYY/MM/DD
release: For internal use only
logo: istqb-logo-default
language: en
compatibility: |
  Compatible with Syllabus on Foundation and Advanced Levels,
  and Specialist Modules
```

3rd parties can be added to the landing page by specifying the key `provided-by` in the file `metadata.yml` as follows:

```yaml
provided-by:
# 3rd-party organizations with logos
- name: Czech and Slovak Quality Board
  logo: casqb-logo-vertical
- name: Polish Testing Board
  logo: sjsi-logo
# 3rd-party organizations without logos
- name: International Requirements Engineering Board  # or just:
- Hungarian Testing Board
```

## Learning objectives and keywords

You can write keywords and learning objectives as follows:

``` md
#### Keywords

coverage, debugging, defect, error, failure, quality, quality assurance

#### Learning Objectives for Chapter 1: {.learning-objectives}

1. Subchapter x.1 name
    1. (K1) First Learning Objective for Subchapter x.1, so it is x.1.1
    2. (K2) Second Learning Objective for Subchapter x.1, so it is x.1.2
    3. (K2) Third Learning Objective for Subchapter x.1, so it is x.1.3
2. Subchapter x.2 name
    1. (K3) First Learning Objective for Subchapter x.2, so it is x.2.1
    2. (K2) Second Learning Objective for Subchapter x.2, so it is x.2.2
3. Subchapter x.3 name
    1. (K4) First Learning Objective for Subchapter x.3, so it is x.3.1
```

This will produce the following output:

#### Keywords

coverage, debugging, defect, error, failure, quality, quality assurance

#### Learning Objectives for Chapter 1: {.learning-objectives}

1. Subchapter x.1 name
    1. (K1) First Learning Objective for Subchapter x.1, so it is x.1.1
    2. (K2) Second Learning Objective for Subchapter x.1, so it is x.1.2
    3. (K2) Third Learning Objective for Subchapter x.1, so it is x.1.3
2. Subchapter x.2 name
    1. (K3) First Learning Objective for Subchapter x.2, so it is x.2.1
    2. (K2) Second Learning Objective for Subchapter x.2, so it is x.2.2
3. Subchapter x.3 name
    1. (K4) First Learning Objective for Subchapter x.3, so it is x.3.1

Notice that the prefix EXMPL- was automatically added to the learning objectives.
This prefix is specified in file `example-document/metadata.yml` as `prefix: EXMPL`.

## Paragraphs

You can write a new paragraph by writing a blank line as follows:

``` md
Here is the first paragraph.

Here is the second paragraph.
```

This will produce the following output:

Here is the first paragraph.

Here is the second paragraph.

## Line breaks

You can break a line in the middle of a paragraph by writing two spaces at the end of a line as follows:

``` md
Here is the first line of a paragraph␣␣
and here is the second line of the paragraph.
```

This will produce the following output:

Here is the first line of a paragraph  
and here is the second line of the paragraph.

## Superscripts and subscripts

You can write superscripts and subscripts by surrounding a span of text with `^`s or `~`s as follows:

``` md
E = mc^2^␣␣
a~n~ = a~1~ + (n − 1)d
```

This will produce the following output:

E = mc^2^  
a~n~ = a~1~ + (n − 1)d

Alternatively, you may also use Unicode superscript and subscript characters as follows:

``` md
E = mc²␣␣
aₙ = a₁ + (n − 1)d
```

This will produce the following output:

E = mc²  
aₙ = a₁ + (n − 1)d

Both outputs should be identical.

## Lists

You can write an unnumbered list as follows:

``` md
* This is the first item in the list
* Folowed by a second one
* And so on, until you have them all here
```

This will produce the following output:

* This is the first item in the list
* Folowed by a second one
* And so on, until you have them all here

You can also write a numbered list as follows:

``` md
1. This is the first item in the list
1. Folowed by a second one
1. And so on, until you have them all here
```

The first number sets the sequence starting number. Every other number is ignored, but teh sequence is used.  
So it will produce the following output:

1. This is the first item in the list
1. Folowed by a second one
1. And so on, until you have them all here

## Sections {.landscape}

You can write the heading of a second-level section as follows:

``` md
## Sections
```

This will produce the same output as the heading of this section.

To display a section in a landscape layout, write `{.landscape}` next to the section heading as follows:

``` md
## Sections {.landscape}
```

This will move the section to the next page and format it the same as this section.

To make a section unnumbered, write `{-}` next to the section heading as follows:

``` md
## Unnumbered section {-}
```

This is applied e.g. in the Revision History section.

## Section references {#section-references}

To reference a section from the text of the document, first write a section identifier such as `{#section-references}` next to the section heading such as follows:

``` md
## Section references {#section-references}
```

This will produce the same output as the heading of this section.

You can reference the section from the text of the document by writing `<#section:section-references>`. This will produce the following output: <#section:section-references>.

If you are writing a document in a flective language other than English such as Czech, writing `<#section:section-references>` will produce a text in accusative case such as [Sekci `\ref{section:section-references}`{=tex}](#section:section-references). You can explictly use a different grammatical case such as the nominative by writing  ``[Sekce `\ref{section:section-references}`{=tex}](#section:section-references)``. This will produce the following output: [Sekce `\ref{section:section-references}`{=tex}](#section:section-references).

You can also create a clickable link to the section by writing `[displayed text](#section:section-references)`. This will produce the following output: [displayed text](#section:section-references).

## Figures {#figures}

You can display a figure from the `img/` folder as follows:

``` md
![label](istqb-logo-default){width=3cm}
```

This will produce the following output:

![label](istqb-logo-default){width=3cm}

Notice that we did't need to specify the suffix of the figure, it was guessed automatically.

You can add a caption to the figure as follows:

``` md
![another-label](istqb-logo-default "Here is a caption describing the image."){width=3cm}
```

This will produce the following output:

![another-label](istqb-logo-default "Here is a caption describing the image."){width=3cm}

You can reference a captioned figure from the text of the document by writing `<#figure:another-label>`. This will produce the following output: <#figure:another-label>.

## Simple tables

You can write a simple table as follows:

``` md
 | Right | Left | Center | Default |
 |------:|:-----|:------:|---------|
 |   12  |  12  |    12  |    12   |
 |  123  |  123 |   123  |   123   |
 |    1  |  1   |     1  |   1     |
```

This will produce the following output:

 | Right | Left | Center | Default |
 |------:|:-----|:------:|---------|
 |   12  |  12  |    12  |    12   |
 |  123  |  123 |   123  |   123   |
 |    1  |  1   |     1  |   1     |

The second line of the table allows you to define the formatting of columns.
Writing `---:`, `:---`, or `:--:` will cause the cells in the column to be typeset at their natural width with either right-aligned, left-aligned, or centered content.
Writing `----` will stretch the column to the page width and left-align its content.
If you write `----` for several columns, each will stretch to a uniform portion of the remaining page width.

You can add a caption to the table as follows:

``` md
 | Right | Left | Center | Default |
 |------:|:-----|:------:|---------|
 |   12  |  12  |    12  |    12   |
 |  123  |  123 |   123  |   123   |
 |    1  |  1   |     1  |   1     |

 : Here is a caption describing the table. {#label}
```

This will produce the following output:

 | Right | Left | Center | Default |
 |------:|:-----|:------:|---------|
 |   12  |  12  |    12  |    12   |
 |  123  |  123 |   123  |   123   |
 |    1  |  1   |     1  |   1     |

 : Here is a caption describing the table. {#label}

You can reference a captioned table from the text of the document by writing `<#table:label>`. This will produce the following output: <#table:label>.

## Complex tables

While markdown is appropriate for writing short and simple tables, you may want to use `\LaTeX`{=tex} for more complex tables.
You can write a complex table in `\LaTeX`{=tex} as follows:

`````` tex
``` {=tex}
% Use three columns, each 5cm wide and separated with vertical lines.
\begin{longtable}{|p{5cm}|p{5cm}|p{5cm}|}

% The table caption and table head shown on the first page.
\caption{A sample long table with \LaTeX-formatted text} \label{table:long} \\
\hline
\multicolumn{2}{|c|}{Grouped Columns} & \multicolumn{1}{c|}{Third Column} \\
\hline
First Column & Second Column & Third Column \\
\hline
\endfirsthead

% The table caption and table head shown on the following pages.
\multicolumn{3}{c}%
{\tablename\ \thetable{} -- continued from previous page} \\
\hline
\multicolumn{2}{|c|}{Grouped Columns} & \multicolumn{1}{c|}{Third Column} \\
\hline
First Column & Second Column & Third Column \\
\hline
\endhead

% The table foot shown on all pages except the last.
\hline
\multicolumn{3}{|r|}{{Continued on next page}} \\
\hline
\endfoot

% The table foot shown on the last page.
\hline
\endlastfoot

% The table body with examples of text formatting in LaTeX.
Here is a short paragraph with \emph{emphasized} and \textbf{bold} text.

&

Here is a long paragraph:
\medskip

\lipsum[2]

&

Here is an image:
\medskip

\includegraphics[width=\linewidth]{istqb-logo-default}

\\
\hline

% Bullet list
\begin{itemize}
\item First item
\item Second item
\item Third item
\end{itemize}

&

% Numbered list
\begin{enumerate}
\item First item
\item Second item
\item Third item
\end{enumerate}

&

% Definition list
\begin{description}
\item First item without a label
\item[Second] Another item
\item[Third] Yet another item
\end{description}
\end{longtable}
```
``````

This will produce <#table:long> that is shown on the following pages.

``` {=tex}
% Use three columns, each 5cm wide and separated with vertical lines.
\begin{longtable}{|p{5cm}|p{5cm}|p{5cm}|}

% The table caption and table head shown on the first page.
\caption{A sample long table with \LaTeX-formatted text} \label{table:long} \\
\hline
\multicolumn{2}{|c|}{Grouped Columns} & \multicolumn{1}{c|}{Third Column} \\
\hline
First Column & Second Column & Third Column \\
\hline
\endfirsthead

% The table caption and table head shown on the following pages.
\multicolumn{3}{c}%
{\tablename\ \thetable{} -- continued from previous page} \\
\hline
\multicolumn{2}{|c|}{Grouped Columns} & \multicolumn{1}{c|}{Third Column} \\
\hline
First Column & Second Column & Third Column \\
\hline
\endhead

% The table foot shown on all pages except the last.
\hline
\multicolumn{3}{|r|}{{Continued on next page}} \\
\hline
\endfoot

% The table foot shown on the last page.
\hline
\endlastfoot

% The table body with examples of text formatting in LaTeX.
Here is a short paragraph with \emph{emphasized} and \textbf{bold} text.

&

Here is a long paragraph:
\medskip

\lipsum[2]

&

Here is an image:
\medskip

\includegraphics[width=\linewidth]{istqb-logo-default}

\\
\hline

% Bullet list
\begin{itemize}
\item First item
\item Second item
\item Third item
\end{itemize}

&

% Numbered list
\begin{enumerate}
\item First item
\item Second item
\item Third item
\end{enumerate}

&

% Definition list
\begin{description}
\item First item without a label
\item[Second] Another item
\item[Third] Yet another item
\end{description}
\end{longtable}
```

You can reference the table from the text of the document by writing `<#table:long>`. This will produce the following output: <#table:long>.

## References {#about-references}

You can add five types of references to your documents: standards, ISTQB documents, books, journal articles, and web pages.

First, you would define the references in file `example-document/bibliography.bib` as follows:

``` bib
% Standards
@report{iso-iec:2022,
  institution = {International Organization for Standardization},
  title = {Software and systems engineering -- Software testing},
  subtitle = {Part 1: General Concepts},
  date = {2022-01},
  type = {Standard},
  volume = {2022}
}

% ISTQB documents
@misc{istqb:2023,
  title = {Certified Tester},
  subtitle = {Foundation Level Syllabus},
  date = {2023-04-21},
  note = {Version 4.0},
  keywords = {istqb}
}

% Books
@book{beizer:1990,
  author = {Boris Beizer},
  title = {Software Testing Techniques},
  year = {1990},
  publisher = {Van Nostrand Reinhold: Boston MA},
  volume = {2}
}

% Articles
@article{brykczynski:1992,
  author = {Bill Brykczynski},
  title = {A survey of software inspection checklists},
  year = {1992},
  journal = {{ACM SIGSOFT} Software Engineering Notes},
  volume = {24},
  number = {1},
  pages = {82-89}
}

% Further Reading
@online{marick:2013,
  author = {Brian Marick},
  title = {Exploration through Example},
  date = {2003-08-21},
  url = {http://www.exampler.com/old-blog/2003/08/21/},
  urldate = {2023-07-11}
}
```

You can cite the defined references in the text by writing `[@istqb:2023]`. This produces the following output: [@istqb:2023].
You can also add prefixes and suffixes to your references and chain several references together by writing `[see @beizer:1990, Chapter 5; @brykczynski:1992, Section 3]`.
This produces the following output: [see @beizer:1990, Chapter 5; @brykczynski:1992, Section 3].

Furthermore, if you want to use citations as the subject or the object of a sentence, you can write without parentheses: `@iso-iec:2022`. This produces the following output: @iso-iec:2022.
Several citations without parentheses can be stringed together by writing `@iso-iec:2022 @marick:2013`. This produces the following output: @iso-iec:2022 @marick:2013.

Cited references of all types except web pages are placed in section *References* at the end of each document.
You can reference the section from the text of the document by writing `<#section:references>`. This will produce the following output: <#section:references>.

Uncited references and web pages are placed in section *Further Reading* at the end of the document.
You can reference the section from the text of the document by writing `<#section:further-reading>`. This will produce the following output: <#section:further-reading>.

For further instructions on defining references, see the `Bib\LaTeX`{=tex} manual [@kime:2023, Chapter 2].

## Indexing

You can index terms by writing `[0-switch coverage]{.index}`, `[functional appropriateness]{.index}`, or `[component integration testing]{.index}`. This will produce the following output: [0-switch coverage]{.index}, [functional appropriateness]{.index}, or [component integration testing]{.index}.

Indexed terms are placed in section *Index* at the end of the document together with the page numbers on which the terms appeared.
