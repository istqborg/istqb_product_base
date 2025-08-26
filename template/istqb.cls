\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{istqb}[2025/01/20 1.2.2 LaTeX class for ISTQB Documents]

% Fonts
\LoadClass[10pt]{article}
\usepackage{microtype}
\DisableLigatures[-]{family=tt*}

% Page layout
%% Page geometry
\RequirePackage{geometry}
\ExplSyntaxOn
\tl_new:N \g_istqb_geometry_tl
\tl_gset:Nn
  \g_istqb_geometry_tl
  {
    left = 1in,
    right = 1in,
    top = 1.75in,
    headheight = 0.6in,
    headsep = 0.5in,
    footskip = 0in,
  }
\exp_args:NV
  \geometry
  \g_istqb_geometry_tl
\ExplSyntaxOff

%% Landscape content
\ExplSyntaxOn
\def \istqblandscapebegin
  {
    \group_begin:
    \paperwidth = \pdfpageheight
    \paperheight = \pdfpagewidth
    \edef \Gm@restore@org { \Gm@restore }
    \exp_args:NV
      \newgeometry
      \g_istqb_geometry_tl
    \fancyhfoffset [ L ] { 0pt }
    \fancyhfoffset [ R ] { 0pt }
    \pdfpagewidth = \paperwidth
    \pdfpageheight = \paperheight
  }
\def \istqblandscapeend
  {
    \clearpage
    \group_end:
    \restoregeometry
  }
\ExplSyntaxOff

%% Paragraphs and text alignment
\raggedbottom  % Do not try to equalize the number of lines on a page by increasing vertical spaces.
\RequirePackage{ragged2e}
\RaggedRight  % Do not try to justify text by increasing horizontal spaces.
\usepackage{parskip}  % Put half of line height between paragraphs.
\sloppy  % Prevent overfull lines.

%% Typefaces
\RequirePackage[T1]{fontenc}
\RequirePackage{tgheros}
\renewcommand*\familydefault{\sfdefault}

%% Microtypography
\RequirePackage{microtype}

%% Header and Footer
\RequirePackage{fancyhdr}
\pagestyle{fancy}
\fancyhf{}

%%% Header
\ExplSyntaxOn
\tl_new:N \g_istqb_schema_tl
\tl_new:N \g_istqb_level_tl
\tl_new:N \g_istqb_title_tl
\tl_new:N \g_istqb_code_tl
\tl_new:N \g_istqb_logo_tl
\tl_new:N \g_istqb_organization_tl
\tl_gset:Nn
  \g_istqb_logo_tl
  { istqb-logo-default }
\tl_gset:Nn
  \g_istqb_organization_tl
  { ISTQB® }
\lhead{%
  \fontsize{9}{10.8}\selectfont
  \kern 0.1in
  % Organization and schema
  \tl_if_empty:NF
    \g_istqb_organization_tl
    {
      \mbox { \g_istqb_organization_tl }
      \tl_if_empty:NF
        \g_istqb_schema_tl
        { ~ }
    }
  \tl_if_empty:NF
    \g_istqb_schema_tl
    { \mbox { \g_istqb_schema_tl } }
  \bool_if:nF
    {
      \tl_if_empty_p:N
        \g_istqb_organization_tl &&
      \tl_if_empty_p:N
        \g_istqb_schema_tl
    }
    { \\ \leavevmode \kern 0.1in }
  % Level
  \tl_if_empty:NF
    \g_istqb_level_tl
    { \mbox { \g_istqb_level_tl } }
  % Title (code)
  \tl_if_empty:NF
    \g_istqb_title_tl
    {
      \tl_if_empty:NF
        \g_istqb_level_tl
        { ~ }
      \mbox { \g_istqb_title_tl }
      \tl_if_empty:NF
        \g_istqb_code_tl
        { ~\mbox { ( \g_istqb_code_tl ) } }
    }
  % Type
  \tl_if_empty:NF
    \g_istqb_type_tl
    {
      \bool_if:nF
        {
          \tl_if_empty_p:N \g_istqb_level_tl &&
          \tl_if_empty_p:N \g_istqb_title_tl
        }
        { ~ }
      \mbox { \g_istqb_type_tl }
    }
}
\rhead{%
  \includegraphics[height=\headheight]{\g_istqb_logo_tl}%
}
\ExplSyntaxOff
\renewcommand{\headrule}{%
  \kern -0.1in
  \leavevmode
  \kern 0.05in
  \vbox to 0pt
  {%
    \makebox[\dimexpr(\headwidth - 0.05in)]{%
      \leavevmode\leaders\hrule height 0.4pt\hfill\kern0pt
    }%
    \vss
  }%
}

%%% Footer
\renewcommand{\footrulewidth}{0pt}
\PassOptionsToPackage{table}{xcolor}
\RequirePackage{xcolor}
\RequirePackage{tcolorbox}
\tcbset{
  istqb/footer/upper/.style={
    boxrule=0.75pt,
    colframe=black!25!white,
    colback=white,
    left=0.08in,
    right=8pt,
    top=3pt,
    bottom=3pt,
    before skip=\baselineskip,
    after skip=\topskip,
    left skip=-8pt,
    right skip=-8pt,
    boxsep=0pt,
    arc=0mm,
    outer arc=0mm,
  },
  istqb/footer/lower/.style={
    istqb/footer/upper,
    left skip=0pt,
    after skip=1.75\topskip,
  }
}
\@ifundefined
  {HCode}%
  {\RequirePackage{lastpage}}%
  {\def\lastpage@lastpage{??}}
\ExplSyntaxOn
\tl_new:N \g_istqb_version_tl
\tl_new:N \g_istqb_date_tl
\tl_new:N \g_istqb_release_tl
\tl_new:N \g_istqb_footer_tl
\tl_gset:Nn
  \g_istqb_footer_tl
  {
    \begin{tcolorbox}[istqb/footer/upper]
      \fontsize{9}{10.8}\selectfont
      \begin{minipage}{0.4\linewidth}
      \mbox{\g_istqb_version_tl{}~\g_istqb_release_tl}
      \end{minipage}
      \begin{minipage}{0.2\linewidth}
      \centering
      \int_set:Nn
        \l_tmpa_int
        { \thepage }
      \str_if_eq:VnTF
        \lastpage@lastpage
        { ?? }
        {
          \int_set:Nn
            \l_tmpb_int
            { 999 }
        }
        {
          \int_set:Nn
            \l_tmpb_int
            { \lastpage@lastpage }
        }
      \mbox
        {
          \istqbpagename
          {}~
          \int_use:N
            \l_tmpa_int
          {}~
          \istqboutofname
          {}~
          \int_use:N
            \l_tmpb_int
        }
      \end{minipage}
      \begin{minipage}{0.4\linewidth}
      \hfill
      \mbox{\g_istqb_date_tl}
      \end{minipage}~
      \fontsize{6}{12}\selectfont
      \textcopyright{}~\istqborgname
    \end{tcolorbox}
  }
\box_new:N \l_istqb_footer_box
\AtBeginDocument
  {
    \cs_generate_variant:Nn
      \vbox_set:Nn
      { NV }
    \vbox_set:NV
      \l_istqb_footer_box
      \g_istqb_footer_tl
    %%%% Ensure that the footer is always the 0.8in from the bottom of the page regardless of its contents.
    \tl_gput_right:Nn
      \g_istqb_geometry_tl
      {
        bottom = \dimexpr( 0.8in + \box_ht_plus_dp:N \l_istqb_footer_box ),
      }
    \exp_args:NV
      \newgeometry
      \g_istqb_geometry_tl
    \cfoot
      {
        \tl_use:N \g_istqb_footer_tl
      }
  }
\ExplSyntaxOff

% Graphics
\RequirePackage{graphicx}
\graphicspath{{.}{./img}{./istqb_product_base/img/}}  % Look for images first in ./, then in ./img/ and ./istqb_product_base/img/.
\setkeys{Gin}{width = \columnwidth, keepaspectratio}  % By default, typeset images to maximum width.

% Tables and Figures
\RequirePackage{float}
\floatplacement{figure}{H}  % Prevent tables and figures from floating.
\floatplacement{table}{H}

% Lists of Tables and Figures
%% Place lists into the Table of Contents.
\PassOptionsToPackage{nottoc}{tocbibind}
\RequirePackage{tocbibind}
%% Number the sections.
\renewcommand{\listoftables}{\begingroup\tocsection\tocfile{\listtablename}{lot}\endgroup}
\renewcommand{\listoffigures}{\begingroup\tocsection\tocfile{\listfigurename}{lof}\endgroup}

% Table of Contents
\setcounter{tocdepth}{3}  % Show level 1 up to level 3 of headings.
\setcounter{section}{-1}  % Start sections from 0.
\newcommand\istqbtableofcontents{%
  \clearpage
  \phantomsection
  \currentpdfbookmark{\contentsname}{istqbtoc}%
  \tableofcontents
}

% Bibliography
\RequirePackage{csquotes}
\PassOptionsToPackage{style=iso-authoryear}{biblatex}
\RequirePackage{biblatex}
\urlstyle{same}
\setlength\bibitemsep{0.5\baselineskip}

%% Citation style for ISTQB documents, based on the macros from the standard library `authoryear.cbx`.
\renewbibmacro*{cite:labeldate+extradate}{%
  \iffieldundef{version}
    {%
      \iffieldundef{labelyear}
        {}
        {\printtext[bibhyperref]{\printlabeldateextra}}%
    }
    {\printtext[bibhyperref]{v\printfield[default]{version}}}}

%% Bibliographic categories
\DeclareBibliographyCategory{cited}
\AtEveryCitekey{\addtocategory{cited}{\thefield{entrykey}}}

%% Formatting of Glossary References
\DeclareFieldFormat{glossary-references-url}{\url{#1}}
\DeclareBibliographyDriver{glossary-references}{%
  \printfield[noformat]{title}%
  \setunit{\addcolon\space}%
  \printfield[glossary-references-url]{url}%
}
\defbibenvironment{glossary-references}
  {\begin{itemize}}
  {\end{itemize}}
  {\item}

%% Bibliographic notes
\defbibnote{skip}{}
\defbibnote{web-pages}{%
  \emph{\istqbwebpagespostnote}%
}
\defbibnote{glossary-references}{%
  \par
  \istqbglossaryreferencesprenote
  :%
}

%% Bibliographic filters
\defbibfilter{standards}{type=report and category=cited}
\defbibfilter{istqb-documents}{type=misc and keyword=istqb and category=cited}
\defbibfilter{glossary-references}{type=online and keyword=glossary}
\defbibfilter{books}{type=book and category=cited}
\defbibfilter{articles}{type=article and category=cited}
\defbibfilter{web-pages}{type=online and category=cited}
\defbibfilter{further-reading}{not type=online and not keyword=glossary and not category=cited}

%% Reference printing
\ExplSyntaxOn
\cs_new:Npn
  \printistqbbibliography
  {
    \nocite
      { * }
    \section
      { \istqbrefname }
    \label
      { section:references }
    \group_begin:
    \defbibheading
      { bibliography }
      {
        \group_begin:
        \normalfont
        \mdseries
        \fontsize
          { 14 }
          { 16.8 }
        \selectfont
        ##1
        \group_end:
      }
    \printbibliography
      [
        filter = standards,
        title = \istqbstandardsname,
        postnote = skip,
      ]
    \printbibliography
      [
        filter = istqb-documents,
        title = \istqbdocumentsname,
        postnote = skip,
      ]
    \group_begin:
      \cs_set:Npn
        \blx@driver
        ##1
        {
          \csuse
            { blx@bbx@glossary-references }
        }
      \printbibliography
        [
          env = glossary-references,
          filter = glossary-references,
          title = \istqbglossaryreferencesname,
          prenote = glossary-references,
          postnote = skip,
        ]
    \group_end:
    \printbibliography
      [
        filter = books,
        title = \istqbbooksname,
        postnote = skip,
      ]
    \printbibliography
      [
        filter = articles,
        title = \istqbarticlesname,
        postnote = skip,
      ]
    \printbibliography
      [
        filter = web-pages,
        title = \istqbwebpagesname,
        postnote = web-pages,
      ]
    \group_end:
    \bool_if:NT
      \g_istqb_further_reading_bool
      {
        \group_begin:
        \defbibheading
          { bibliography }
          {
            \section
              { ##1 }
            \label
              { section:further-reading }
          }
        \printbibliography
          [
            filter = further-reading,
            title = \istqbfurtherreadingname,
          ]
      }
    \group_end:
  }
\ExplSyntaxOff

% Landing Page
\ExplSyntaxOn
\tl_new:N \g_istqb_type_tl
\tl_new:N \g_istqb_compatibility_tl
\seq_new:N \g_istqb_third_parties_seq
\prop_new:N \g_istqb_third_party_logos_prop
\RequirePackage{graphbox}
\newcommand
  \istqblandingpage
  {
    \thispagestyle
      { empty }
    \group_begin:
    \parskip=0pt
    \centering
    \leavevmode
    \par
    \normalfont
    \bfseries
    \fontsize { 24 } { 28.8 } \selectfont
    \tl_if_empty:NF
      \g_istqb_schema_tl
      {
        \g_istqb_schema_tl
        \\
      }
    \tl_if_empty:NF
      \g_istqb_level_tl
      {
        \g_istqb_level_tl
        \\
      }
    \tl_if_empty:NF
      \g_istqb_title_tl
      {
        \g_istqb_title_tl
        \tl_if_empty:NF
          \g_istqb_code_tl
          {
            {}~(\g_istqb_code_tl)
          }
        \\
      }
    \g_istqb_type_tl
    \par \vfill \vfill
    \normalfont
    \itshape
    \fontsize { 18 } { 21.6 } \selectfont
    \g_istqb_version_tl
    \tl_if_empty:NF
      \g_istqb_compatibility_tl
      {
        \par \vfill \vfill
        \normalfont
        \fontsize { 18 } { 21.6 } \selectfont
        \g_istqb_compatibility_tl
      }
    \par \vfill \vfill \vfill \vfill
    \leaders \vrule width \textwidth \vskip 1pt
    \par \vspace { 0.2in }
    \normalfont
    \fontsize { 18 } { 21.6 } \selectfont
    \istqborgname
    \par \vspace { 0.3in }
    \leaders \vrule width \textwidth \vskip 1pt
    \par \vfill \vfill
    \includegraphics [ height = 1.2in ] { \g_istqb_logo_tl }
    \seq_if_empty:NTF
      \g_istqb_third_parties_seq
      { \par \vfill \vfill \vfill \vfill \vfill \vfill }
      {
        % Display third party organization(s)
        \par \vfill \vfill
        \leaders \vrule width \textwidth \vskip 1pt
        \par \vspace { 0.2in }
        \normalfont
        \fontsize { 18 } { 21.6 } \selectfont
        \int_compare:nNnTF
          { \seq_count:N \g_istqb_third_parties_seq } = { 1 }
          {
            % A single third party organization
            \istqbprovidedbysingularname
            {}~
            \seq_get_left:NN
              \g_istqb_third_parties_seq
              \l_tmpa_tl
            \tl_use:N
              \l_tmpa_tl
          }
          {
            % Several third party organizations
            \istqbprovidedbypluralname
            \par \vfill
            \exp_last_unbraced:NNo
              \seq_use:Nnnn
              \g_istqb_third_parties_seq
              {
                { \g_istqb_list_delimiter_two_tl }
                { \g_istqb_list_delimiter_many_tl }
                { \g_istqb_list_delimiter_last_tl }
              }
          }
        \par \vspace { 0.3in }
        \vfill \vfill
        % Display logo(s) of third party organization(s)
        \seq_clear:N
          \l_tmpa_seq
        \seq_map_inline:Nn
          \g_istqb_third_parties_seq
          {
            \prop_get:NnNT
              \g_istqb_third_party_logos_prop
              { ##1 }
              \l_tmpa_tl
              {
                \tl_set:Nn
                  \l_tmpb_tl
                  {
                    \includegraphics
                      [
                        align = c,
                        width = 2in,
                        height = 0.4in,
                      ]
                  }
                \tl_put_right:Nx
                  \l_tmpb_tl
                  { { \l_tmpa_tl } }
                \seq_put_right:NV
                  \l_tmpa_seq
                  \l_tmpb_tl
              }
          }
        \seq_use:Nn
          \l_tmpa_seq
          { \qquad }
        \par
      }
    \par
    \group_end:
    \clearpage
  }
\ExplSyntaxOff

% Headings
\ExplSyntaxOn
\int_new:N
  \g_istqb_previous_heading_level_int
\int_gset:Nn
  \g_istqb_previous_heading_level_int
  { 0 }
\cs_new:Npn
  \istqbupdateheadinglevel
  #1
  {
    \int_if_zero:VF
      \g_istqb_previous_heading_level_int
      {
        % Encourage page breaks before sections
        \penalty -2000
        % Discourage page breaks between sections and subsections in TOC
        \int_compare:nT
          { \g_istqb_previous_heading_level_int < #1 }
          { \addtocontents { toc } { \nopagebreak } }
        % Encourage page breaks between subsections and sections in TOC
        \int_compare:nT
          { \g_istqb_previous_heading_level_int > #1 }
          { \addtocontents { toc } { \pagebreak[0] } }
      }
    \int_gset:Nn
      \g_istqb_previous_heading_level_int
      { #1 }
  }
\cs_generate_variant:Nn
  \int_if_zero:nF
  { VF }
\ExplSyntaxOff
%% Sections, subsections, and subsubsections
\RequirePackage{tcolorbox}
\tcbset{
  istqb/section/.style={
    boxrule=0.95pt,
    colframe=black,
    colback=white,
    left=0.08in,
    right=0.2in,
    top=0.05in,
    bottom=0in,
    before skip=0pt,
    after skip=0pt,
    left skip=0in,
    right skip=0in,
    boxsep=0pt,
    arc=0mm,
    outer arc=0mm,
  },
  istqb/subsection/.style={
    istqb/section,
    boxrule=0.63pt,
    top=0.035in,
  }
}
\RequirePackage{xpatch}
\xpatchcmd{\section}{\normalfont\Large\bfseries}{\istqbsectionbox}{}{\PatchFailed}
\xpatchcmd{\subsection}{\normalfont\large\bfseries}{\istqbsubsectionbox}{}{\PatchFailed}
\RequirePackage{titlesec, etoolbox}
\pretocmd{\section}{\clearpage}{}{\PatchFailed}
\newcommand\istqbsectionbox[1]{%
  \clearpage
  \begin{tcolorbox}[istqb/section]
    \normalfont
    \bfseries
    \fontsize{16}{19.2}\selectfont
    \phantomsection
    \begingroup
    \titlelabel{\thetitle\kern0.3em}
    #1%
    \endgroup
  \end{tcolorbox}%
}
\newcommand\istqbsubsectionbox[1]{%
  \begin{tcolorbox}[istqb/subsection]
    \normalfont
    \mdseries
    \fontsize{14}{16.8}\selectfont
    \phantomsection
    \begingroup
    \titlelabel{\thetitle\kern0.3em}
    #1%
    \endgroup
  \end{tcolorbox}%
}
\titleformat\subsubsection
{% format
    \normalfont
    \mdseries
    \fontsize{12}{14.4}\selectfont
}%
{\thesubsubsection}% label
{0.5em}% sep
{}% before-code
\titlespacing\section{0pt}{0pt}{*2.35}
\titlespacing\subsection{0pt}{*5.5}{*2.3}
\titlespacing\subsubsection{0pt}{*3.25}{*1}
%%% Document commands
\ExplSyntaxOn
\tl_new:N \g_istqb_current_chapter_name_tl
\newcommand\istqbsection[1]{
  \istqbupdateheadinglevel{1}
  \section{#1}
  \tl_gset:Nn
    \g_istqb_current_chapter_name_tl
    { #1 }
}
\ExplSyntaxOff
\newcommand\istqbsubsection[1]{%
  \istqbupdateheadinglevel{2}%
  \subsection{#1}%
}
\newcommand\istqbsubsubsection[1]{%
  \istqbupdateheadinglevel{3}%
  \subsubsection{#1}%
}
\newcommand\istqbunnumberedsection[1]{%
  \istqbupdateheadinglevel{1}%
  \section*{#1}%
  \markboth{#1}{#1}%
  \addcontentsline{toc}{section}{#1}%
}
\newcommand\istqbunnumberedsubsection[1]{%
  \istqbupdateheadinglevel{2}%
  \subsection*{#1}%
  \addcontentsline{toc}{subsection}{#1}%
}
\newcommand\istqbunnumberedsubsubsection[1]{%
  \istqbupdateheadinglevel{3}%
  \subsubsection*{#1}%
  \addcontentsline{toc}{subsubsection}{#1}%
}

%% Learning objectives
\RequirePackage{longtable}
\newcounter{istqbobjective}[section]
\newcounter{istqbsubobjective}[istqbobjective]
\ExplSyntaxOn
\seq_new:N \g_istqb_learning_objective_chapter_numbers_seq
\prop_new:N \g_istqb_learning_objective_chapter_names_prop
\prop_new:N \g_istqb_learning_objective_subchapter_numbers_prop
\seq_new:N \l_istqb_learning_objective_subchapter_numbers_seq
\prop_new:N \g_istqb_learning_objective_subchapter_names_prop
\newenvironment{istqbobjectives}{
  \seq_gput_right:Nx
    \g_istqb_learning_objective_chapter_numbers_seq
    { \thesection }
  \prop_gput:NxV
    \g_istqb_learning_objective_chapter_names_prop
    { \thesection }
    \g_istqb_current_chapter_name_tl
  \def\istqbobjective##1{
    \stepcounter{istqbobjective}
    \par\kern -0.03in
    \paragraph{\thesection.\theistqbobjective\enspace##1}
    \par\leavevmode
    \prop_gput:Nxn
      \g_istqb_learning_objective_subchapter_names_prop
      { \thesection . \theistqbobjective }
      { ##1 }
    \seq_put_right:Nx
      \l_istqb_learning_objective_subchapter_numbers_seq
      { \theistqbobjective }
  }
}{
  \clist_set_from_seq:NN
    \l_tmpa_clist
    \l_istqb_learning_objective_subchapter_numbers_seq
  \prop_gput:NxV
    \g_istqb_learning_objective_subchapter_numbers_prop
    { \thesection }
    \l_tmpa_clist
  \setcounter{istqbobjective}{0}
  \par\kern 0.12in
}
\cs_generate_variant:Nn
  \prop_gput:Nnn
  { Nxn, NxV }
\tl_new:N \g_istqb_prefix_tl
\tl_gset:Nn \g_istqb_prefix_tl { ?? }
\prop_new:N \g_istqb_learning_objective_numbers_prop
\seq_new:N \g_istqb_learning_objective_numbers_seq
\prop_new:N \g_istqb_learning_objective_names_prop  % noqa: w415
\prop_new:N \g_istqb_learning_objective_k_levels_prop  % noqa: w415
\tl_new:N \l_istqb_current_learning_objective_text_tl
\regex_const:Nn \c_istqb_learning_objective_regex { ^\((K[0-9])\)\ +(.+)$ }
\newenvironment{istqbsubobjectives}{
  \seq_gclear:N
    \g_istqb_learning_objective_numbers_seq
  \def\istqbsubobjective##1{
    \stepcounter{istqbsubobjective}
    \g_istqb_prefix_tl-\thesection.\theistqbobjective.\theistqbsubobjective & ##1 \\[0.07in]
    \tl_set:Nn
      \l_istqb_current_learning_objective_text_tl
      { ##1 }
    \regex_replace_once:NnNTF
      \c_istqb_learning_objective_regex
      {
        \c{prop_gput:Nxn}
          \c{g_istqb_learning_objective_k_levels_prop}
          \cB\{ \c{thesection} . \c{theistqbobjective} . \c{theistqbsubobjective} \cE\}
          \cB\{ \1 \cE\}
        \c{prop_gput:Nxn}
          \c{g_istqb_learning_objective_names_prop}
          \cB\{ \c{thesection} . \c{theistqbobjective} . \c{theistqbsubobjective} \cE\}
          \cB\{ \2 \cE\}
      }
      \l_istqb_current_learning_objective_text_tl
      {
        \tl_use:N
          \l_istqb_current_learning_objective_text_tl
      }
      {
        \msg_error:nnV
          { istqb }
          { malformed-learning-objective }
          \l_istqb_current_learning_objective_text_tl
      }
    \seq_gput_right:Nx
      \g_istqb_learning_objective_numbers_seq
      { \theistqbsubobjective }
  }
  \LTpre=0.08in
  \LTpost=0.12in
  \begin{longtable}{@{}p{1in}@{}p{\dimexpr(\linewidth - 1in)}@{}}
}{
  \end{longtable}
  \clist_set_from_seq:NN
    \l_tmpa_clist
    \g_istqb_learning_objective_numbers_seq
  \prop_gput:NxV
    \g_istqb_learning_objective_numbers_prop
    { \thesection . \theistqbobjective }
    \l_tmpa_clist
  \setcounter{istqbsubobjective}{0}
  \par\kern -0.2in
}
\msg_new:nnn
  { istqb }
  { malformed-learning-objective }
  {
    Learning~objective~"#1"~is~not~in~the~expected~format~"(K?)~OBJECTIVE".
  }
\ExplSyntaxOff

%% Appendices
\newcounter{istqbappendix}
\RequirePackage{xparse}
\newenvironment{istqbappendices}{%
  \begingroup
  \let\istqboldsection\section
  \RenewDocumentCommand\section{sm}{%
    \stepcounter{istqbappendix}%
    \IfBooleanTF
      {##1}%
      {\istqboldsection*{\istqbappendixname~\Alph{istqbappendix}~--~##2}}%
      {\istqboldsection{\istqbappendixname~\Alph{istqbappendix}~--~##2}}%
  }%
  \renewcommand\istqbunnumberedsection[1]{%
    \istqbupdateheadinglevel{1}%
    \section*{##1}%
    \markboth{\istqbappendixname~\Alph{istqbappendix}~--~##1}%
             {\istqbappendixname~\Alph{istqbappendix}~--~##1}%
    \addcontentsline{toc}{section}{\istqbappendixname~\Alph{istqbappendix}~--~##1}%
  }%
}{%
  \setcounter{istqbappendix}{0}%
  \endgroup
}

% Index
\RequirePackage{imakeidx}
\makeindex[columns=2, columnsep=1cm, noautomatic]
\indexsetup{firstpagestyle=fancy}
%% Ensure that the index is numbered and part of the table of contents.
\renewcommand\imki@indexlevel{\section}
%% Remove spaces between indexed items.
\RequirePackage{etoolbox}
\apptocmd\theindex{\let\indexspace=\relax}{}{\PatchFailed}

% Hyperlinks
\PassOptionsToPackage{hidelinks, bookmarksnumbered}{hyperref}
\RequirePackage{hyperref}

% Tables
\RequirePackage{nicematrix, tabularx}
\RequirePackage{xcolor, colortbl}
\definecolor{istqbgraytableheader}{HTML}{D9D9D9}
\definecolor{istqbbluetableheader}{HTML}{B5C5E5}
\definecolor{istqbgreentableheader}{HTML}{C5E0B3}
\ExplSyntaxOn
\newenvironment
  { istqbtable }
  [ 1 ]
  {
    \renewcommand { \arraystretch }{ 1.25 }  % Set vertical cell margins
    \setlength \tabcolsep { 3pt }  % Set horizontal cell margins
    \str_if_in:nnTF
      { #1 }
      { X }
      {
        \cs_set:Npn
          \endistqbtable
          { \end { NiceTabularX } }
        \begin { NiceTabularX } \linewidth { #1 } \hline
      }
      {
        \cs_set:Npn
          \endistqbtable
          {
            \end { NiceTabular }
            \par
          }
        \centering
        \begin { NiceTabular } { #1 } \hline
      }
    \RowStyle [ nb-rows=1, rowcolor=istqbgraytableheader ] { }  % Color table head
  }
  { }
\ExplSyntaxOff

%% Revision History
\newenvironment{istqbrevisionhistory}{%
  \begin{istqbtable}{|l|l|X|}%
}{%
  \end{istqbtable}%
}

% Structure Tables
\ExplSyntaxOn
\tl_new:N
  \l_istqb_external_document_basename_tl
\int_new:N
  \l_istqb_external_document_last_page_int
\cs_new:Nn
  \istqb_structure_tables:n
  {
    \pdfximage
      { #1.pdf }
    \int_set:Nn
      \l_istqb_external_document_last_page_int
      { \the\pdflastximagepages }
    % Overview
    \istqblandscapebegin
    \int_compare:nNnTF
      { \l_istqb_external_document_last_page_int } > { 3 }
      {
        \includegraphics
          [
            page = 4,
            trim = {1.75cm~7.5cm~1.75cm~0.75cm},
            clip,
          ]
          { #1 }
      }
      {
        % For placeholder or incorrect inputs, display at least page 1.
        \centering
        \includegraphics
          [
            page = 1,
            keepaspectratio,
            width = \linewidth,
            height = 0.5\paperheight,
          ]
          { #1 }
      }
    \istqblandscapeend
    % Structure Tables
    \int_step_inline:nnn
      { 5 }
      { \l_istqb_external_document_last_page_int }
      {
        \centering
        \includegraphics
          [
            page = #1,
            height = 0.7\paperheight,
            trim = {0.75cm~0.75cm~0.75cm~0.75cm},
            clip,
          ]
          { #1 }
        \par
      }
  }
\newcommand
  \istqbstructuretables
  [ 1 ]
  {
    \file_parse_full_name:nNNN
      { #1 }
      \l_tmpa_tl
      \l_istqb_external_document_basename_tl
      \l_tmpb_tl
    \istqb_structure_tables:V
      \l_istqb_external_document_basename_tl
  }
\cs_generate_variant:Nn
  \istqb_structure_tables:n
  { V }
\ExplSyntaxOff

% Unicode characters
\RequirePackage{newunicodechar}
%% Subscripts
\newunicodechar{₀}{\textsubscript{0}}
\newunicodechar{₁}{\textsubscript{1}}
\newunicodechar{₂}{\textsubscript{2}}
\newunicodechar{₃}{\textsubscript{3}}
\newunicodechar{₄}{\textsubscript{4}}
\newunicodechar{₅}{\textsubscript{5}}
\newunicodechar{₆}{\textsubscript{6}}
\newunicodechar{₇}{\textsubscript{7}}
\newunicodechar{₈}{\textsubscript{8}}
\newunicodechar{₉}{\textsubscript{9}}
\newunicodechar{ₐ}{\textsubscript{a}}
\newunicodechar{ₑ}{\textsubscript{e}}
\newunicodechar{ₒ}{\textsubscript{o}}
\newunicodechar{ₓ}{\textsubscript{x}}
\newunicodechar{ₕ}{\textsubscript{h}}
\newunicodechar{ₖ}{\textsubscript{k}}
\newunicodechar{ₗ}{\textsubscript{l}}
\newunicodechar{ₘ}{\textsubscript{m}}
\newunicodechar{ₙ}{\textsubscript{n}}
\newunicodechar{ₚ}{\textsubscript{p}}
\newunicodechar{ₛ}{\textsubscript{s}}
\newunicodechar{ₜ}{\textsubscript{t}}
\newunicodechar{₊}{\textsubscript{+}}
\newunicodechar{₋}{\textsubscript{-}}
\newunicodechar{₌}{\textsubscript{=}}
\newunicodechar{₍}{\textsubscript{(}}
\newunicodechar{₎}{\textsubscript{)}}
%% Superscripts
\newunicodechar{⁰}{\textsuperscript{0}}
\newunicodechar{¹}{\textsuperscript{1}}
\newunicodechar{²}{\textsuperscript{2}}
\newunicodechar{³}{\textsuperscript{3}}
\newunicodechar{⁴}{\textsuperscript{4}}
\newunicodechar{⁵}{\textsuperscript{5}}
\newunicodechar{⁶}{\textsuperscript{6}}
\newunicodechar{⁷}{\textsuperscript{7}}
\newunicodechar{⁸}{\textsuperscript{8}}
\newunicodechar{⁹}{\textsuperscript{9}}
\newunicodechar{ⁱ}{\textsuperscript{i}}
\newunicodechar{ⁿ}{\textsuperscript{n}}
\newunicodechar{⁺}{\textsuperscript{+}}
\newunicodechar{⁻}{\textsuperscript{-}}
\newunicodechar{⁼}{\textsuperscript{=}}
\newunicodechar{⁽}{\textsuperscript{(}}
\newunicodechar{⁾}{\textsuperscript{)}}
%% Punctuation
\newunicodechar{−}{--}  % Render the minus sign as an en-dash, assuming that the author mistyped.
%% Math
\newunicodechar{≤}{\ensuremath{\leq}}
\newunicodechar{≥}{\ensuremath{\geq}}
\newunicodechar{≠}{\ensuremath{\neq}}
%% Spacing
\newunicodechar{ }{\,}
\newunicodechar{ }{\,}
\newunicodechar{​}{}
%% Miscellaneous
\newunicodechar{®}{\textsuperscript{\textregistered}}

% Miscellaneous
\RequirePackage{lipsum}  % The `lipsum` package is used in a complex table from the example document.
