\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{istqb}[2025/01/20 1.2.2 LaTeX class for ISTQB Documents]

% Fonts
\LoadClass[10pt]{article}
\usepackage{fontspec}
\setsansfont[Ligatures=TeX, Scale=1.0]{TeX Gyre Heros}
\renewcommand*\familydefault{\sfdefault}
\usepackage{unicode-math}
\setmathfont{TeX Gyre Termes Math}
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
\cs_new_protected:Npn
  \istqblandscapebegin
  {
    \group_begin:
    \paperwidth = \pageheight
    \paperheight = \pagewidth
    \edef \Gm@restore@org { \Gm@restore }
    \exp_args:NV
      \newgeometry
      \g_istqb_geometry_tl
    \fancyhfoffset [ L ] { 0pt }
    \fancyhfoffset [ R ] { 0pt }
    \pagewidth = \paperwidth
    \pageheight = \paperheight
  }
\cs_new_protected:Npn
  \istqblandscapeend
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
\RequirePackage{lastpage}  % Before the last page is known, `\lastpage@lastpage` expands to `??`, see below.
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
%% With LuaTeX, the package csquotes adds an extra space after opening quotation marks to the text of tagged PDFs.
%% Disable the production of space characters for the marker glue, as suggested by @u-fischer in
%% <https://github.com/latex3/tagging-project/issues/1041#issuecomment-3536771210>.
\ExplSyntaxOn
\FirstAidNeededT
  { csquotes }
  { sty }
  { 2026-05-19~v5.2p~context-sensitive~quotations~(JAW) }
  {
    \cs_set:Npn
      \csq@setmarker@open
      {
        \penalty \@M
        \tag_spacechar_off:
        \hskip - \csq@themarker \relax
        \hskip \csq@themarker \relax
        \tag_spacechar_on:
      }
  }
\ExplSyntaxOff
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
\cs_new_protected:Npn
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
\cs_new_protected:Npn
  \istqbupdateheadinglevel
  #1
  {
    \int_if_zero:VF
      \g_istqb_previous_heading_level_int
      {
        % Encourage page breaks before sections, unless the section directly follows another heading
        \legacy_if:nF
          { @nobreak }
          { \penalty -2000 }
        % Discourage page breaks between sections and subsections in TOC
        \int_compare:nT
          { \g_istqb_previous_heading_level_int < #1 }
          { \addtocontents { toc } { \nopagebreak } }
        % Encourage page breaks between subsections and sections in TOC
        \int_compare:nT
          { \g_istqb_previous_heading_level_int > #1 }
          { \addtocontents { toc } { \pagebreak[0] } }
        % Directly after another heading, the above writes to TOC would allow a page break between the headings
        \legacy_if:nT
          { @nobreak }
          { \nobreak }
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
%%% We customize the heading templates of the LaTeX kernel, which produce tagged PDF, rather than use the package
%%% titlesec, whose commands `\titleformat`, `\titlespacing`, and `\titlelabel` are not supported with tagging. The
%%% heading templates are only available with `\DocumentMetadata`, which the script template.py adds to TeX files.
%%% See also <https://github.com/istqborg/istqb_product_base/issues/152#issuecomment-5715946481>.
\ExplSyntaxOn
\msg_new:nnnn
  { istqb }
  { missing-heading-templates }
  {
    The~class~istqb~requires~the~heading~templates~of~the~LaTeX~kernel,~which~are~only~available~with~
    \iow_char:N\\DocumentMetadata.
  }
  {
    Typeset~the~document~with~the~command~"istqb-template~compile-tex-to-pdf",~which~adds~
    \iow_char:N\\DocumentMetadata~automatically.
  }
\cs_if_exist:NF
  \ParseLaTeXeHeading
  {
    \msg_fatal:nn
      { istqb }
      { missing-heading-templates }
  }
\ExplSyntaxOff
%%% Units of vertical space before and after headings, taken from the package titlesec.
\newskip\istqbbeforetitleunit
\istqbbeforetitleunit=1ex\@plus.3ex\@minus.06ex
\newskip\istqbaftertitleunit
\istqbaftertitleunit=1ex\@plus.1ex
%%% The package parskip subtracts \parskip from the vertical space that titlesec adds before and after headings, but it
%%% doesn't patch the heading templates. Therefore, we subtract \parskip from the vertical space ourselves. For framed
%%% headings, we also subtract the following lengths, so that the frames are where they were in version 1.2.2 of this
%%% class, when they were drawn by the package tcolorbox inside headings typeset by the package titlesec.
\newskip\istqbbeforeframedtitleadjustment
\istqbbeforeframedtitleadjustment=6.9pt
\newskip\istqbafterframedtitleadjustment
\istqbafterframedtitleadjustment=3.34pt
%%% Frames around sections and subsections.
\newdimen\istqbheadinglinewidth
\newcommand\istqbheadingframe[3]{% #1: rule width, #2: space above the heading text, #3: heading material
  \begingroup
  \setlength\fboxrule{#1}%
  \setlength\fboxsep{0pt}%
  % The heading templates reduce \linewidth by the left and right margins of the heading. In our headings, these
  % margins are inside the frame, which spans the whole \hsize.
  \setlength\istqbheadinglinewidth{\dimexpr\linewidth - 2\fboxrule\relax}%
  \fbox{%
    \parbox[b]{\dimexpr\hsize - 2\fboxrule\relax}{%
      \setlength\linewidth{\istqbheadinglinewidth}%
      \vspace*{#2}%
      % Like titlesec, add struts, so that the height of the frame does not depend on the letters in the heading.
      \strut#3\strut
    }%
  }%
  \endgroup
}
\EditInstance{heading}{section}{
  placement = top,
  % Unlike `placement = top`, don't use the page style plain on the first page of a section.
  placement-start-code = \clearpage\global\@topnum\z@,
  before-vspace = 0pt,
  after-vspace = \istqbaftertitleunit * 47 / 20 - \parskip - \istqbafterframedtitleadjustment,
  heading-decls = \normalfont\bfseries\fontsize{16}{19.2}\selectfont,
  heading-format = \istqbheadingframe{0.95pt}{0.05in}{#1},
}
\EditInstance{headformat}{section}{
  left-margin = 0.08in,
  right-margin = 0.2in,
  separator-b = \hspace{0.3em},
}
\EditInstance{heading}{subsection}{
  before-vspace = \istqbbeforetitleunit * 11 / 2 - \parskip - \istqbbeforeframedtitleadjustment,
  after-vspace = \istqbaftertitleunit * 23 / 10 - \parskip - \istqbafterframedtitleadjustment,
  heading-decls = \normalfont\mdseries\fontsize{14}{16.8}\selectfont,
  heading-format = \istqbheadingframe{0.63pt}{0.035in}{#1},
}
\EditInstance{headformat}{subsection}{
  left-margin = 0.08in,
  right-margin = 0.2in,
  separator-b = \hspace{0.3em},
}
\EditInstance{heading}{subsubsection}{
  before-vspace = \istqbbeforetitleunit * 13 / 4 - \parskip,
  after-vspace = \istqbaftertitleunit - \parskip,
  heading-decls = \normalfont\mdseries\fontsize{12}{14.4}\selectfont,
}
\EditInstance{headformat}{subsubsection}{
  separator-b = \hspace{0.5em},
}
%%% Document commands
\ExplSyntaxOn
\tl_new:N \g_istqb_current_chapter_name_tl
\tl_new:N \g_istqb_current_section_name_tl
\tl_new:N \g_istqb_current_subsection_name_tl
\newcommand\istqbsection[1]{
  \istqbupdateheadinglevel{1}
  \section{#1}
  \tl_gset:Nn
    \g_istqb_current_chapter_name_tl
    { #1 }
}
\newcommand\istqbsubsection[1]{
  \istqbupdateheadinglevel{2}
  \subsection{#1}
  \tl_gset:Nn
    \g_istqb_current_section_name_tl
    { #1 }
}
\newcommand\istqbsubsubsection[1]{
  \istqbupdateheadinglevel{3}
  \subsubsection{#1}
  \tl_gset:Nn
    \g_istqb_current_subsection_name_tl
    { #1 }
}
\ExplSyntaxOff
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

%% Appendices
\newcounter{istqbappendix}
\RequirePackage{xparse}
\newenvironment{istqbappendices}{%
  \begingroup
  \DeclareCommandCopy\istqboldsection\section
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

% Objectives
%% Formatting of objective lists
\ExplSyntaxOn
\newenvironment
  { istqb objectives }
  {
    \cs_gset:cpn
      { istqb objective }
      ##1##2
      {
        \par
        \kern -0.03in
        \paragraph
          { ##1 \enspace ##2 }
        \par
        \leavevmode
      }
  }
  {
    \par
    \kern 0.12in
  }
\newenvironment
  { istqb subobjectives }
  {
    \cs_gset:cpn
      { istqb subobjective }
      ##1##2
      {
        ##1 & ##2 \\[0.07in]
      }
    \LTpre=0.08in
    \LTpost=0.12in
    \begin
      { longtable }
      { @{} p{1in} @{} p{\dimexpr(\linewidth - 1in)} @{} }
  }
  {
    \end
      { longtable }
    \istqb_negative_skip_after_last_subobjective:
  }
\cs_new:Nn
  \istqb_negative_skip_after_last_subobjective:
  {
    \par
    \kern -0.2in
  }
\ExplSyntaxOff

%% Hands-on objectives
\RequirePackage{tcolorbox}
\tcbuselibrary{breakable}
\tcbset{
  istqb/hands-on-objective/.style={
    breakable,
    boxrule=0.4pt,
    colframe=black,
    colback=white,
    coltitle=black,
    colbacktitle=white,
    fonttitle=\normalfont\bfseries,
    titlerule=0pt,
    arc=0mm,
    outer arc=0mm,
    boxsep=0pt,
    left=5pt,
    right=5pt,
    top=0pt,
    bottom=10pt,
    lefttitle=5pt,
    righttitle=5pt,
    toptitle=10pt,
    bottomtitle=10pt,
    before skip=10pt,
    % Reproduce the vertical space after the box in version 1.2.2 of this class, which used the package mdframed.
    after skip=12pt,
  }
}
\newtcolorbox{istqbhandsonobjectivesection}[1][]{istqb/hands-on-objective, #1}

%% Learning objectives
\RequirePackage{longtable}
\ExplSyntaxOn
\newcounter
  { istqb learning objective }
  [ section ]
\newcounter
  { istqb learning subobjective }
  [ istqb learning objective ]
\seq_new:N \g_istqb_learning_objective_chapter_numbers_seq
\prop_new:N \g_istqb_learning_objective_chapter_names_prop
\prop_new:N \g_istqb_learning_objective_subchapter_numbers_prop
\seq_new:N \l_istqb_learning_objective_subchapter_numbers_seq
\prop_new:N \g_istqb_learning_objective_subchapter_names_prop
\newenvironment
  { istqb learning objectives }
  {
    \seq_gput_right:Nx
      \g_istqb_learning_objective_chapter_numbers_seq
      { \thesection }
    \prop_gput:NxV
      \g_istqb_learning_objective_chapter_names_prop
      { \thesection }
      \g_istqb_current_chapter_name_tl
    \cs_gset:cpn
      { istqb learning objective }
      ##1
      {
        \stepcounter
          { istqb learning objective }
        \use:c
          { istqb objective }
          {
            \thesection
            .
            \use:c
              { the istqb learning objective }
          }
          { ##1 }
        \prop_gput:Nxn
          \g_istqb_learning_objective_subchapter_names_prop
          {
            \thesection
            .
            \use:c
              { the istqb learning objective }
          }
          { ##1 }
        \seq_put_right:Nx
          \l_istqb_learning_objective_subchapter_numbers_seq
          {
            \use:c
              { the istqb learning objective }
          }
      }
  }
  {
    \clist_set_from_seq:NN
      \l_tmpa_clist
      \l_istqb_learning_objective_subchapter_numbers_seq
    \prop_gput:NxV
      \g_istqb_learning_objective_subchapter_numbers_prop
      { \thesection }
      \l_tmpa_clist
    \setcounter
      { istqb learning objective }
      { 0 }
  }
\cs_generate_variant:Nn
  \prop_gput:Nnn
  { Nxn, NxV }
\tl_new:N \g_istqb_prefix_tl
\tl_gset:Nn \g_istqb_prefix_tl { ?? }
\prop_new:N \g_istqb_learning_objective_numbers_prop
\seq_new:N \g_istqb_learning_objective_numbers_seq
\prop_new:N \g_istqb_learning_objective_names_prop
\prop_new:N \g_istqb_learning_objective_k_levels_prop
\tl_new:N \l_istqb_current_learning_objective_text_tl
\regex_const:Nn \c_istqb_learning_objective_regex { ^\((K[0-9])\):?\ +(.+)$ }
\regex_const:Nn \c_istqb_hands_on_objective_regex { ^\((H[0-9])\):?\ +(.+)$ }
\newenvironment
  { istqb learning subobjectives }
  {
    \seq_gclear:N
      \g_istqb_learning_objective_numbers_seq
    \cs_gset:cpn
      { istqb learning subobjective }
      ##1
      {
        \stepcounter
          { istqb learning subobjective }
        \use:c
          { istqb subobjective }
          {
            \tl_use:N
              \g_istqb_prefix_tl
            -
            \thesection
            .
            \use:c
              { the istqb learning objective }
            .
            \use:c
              { the istqb learning subobjective }
          }
          { ##1 }
        \tl_set:Nn
          \l_istqb_current_learning_objective_text_tl
          { ##1 }
        \regex_replace_once:NnNTF
          \c_istqb_learning_objective_regex
          {
            \c{prop_gput:Nxn}
              \c{g_istqb_learning_objective_k_levels_prop}
              \cB\{ \c { the section } . \c { the istqb learning objective } . \c { the istqb learning subobjective } \cE\}
              \cB\{ \1 \cE\}
            \c{prop_gput:Nxn}
              \c{g_istqb_learning_objective_names_prop}
              \cB\{ \c { the section } . \c { the istqb learning objective } . \c { the istqb learning subobjective } \cE\}
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
          {
            \use:c
              { the istqb learning subobjective }
          }
      }
  }
  {
    \clist_set_from_seq:NN
      \l_tmpa_clist
      \g_istqb_learning_objective_numbers_seq
    \prop_gput:NxV
      \g_istqb_learning_objective_numbers_prop
      {
        \thesection
        .
        \use:c
          { the istqb learning objective }
      }
      \l_tmpa_clist
    \setcounter
      { istqb learning subobjective }
      { 0 }
  }
\msg_new:nnn
  { istqb }
  { malformed-learning-objective }
  {
    Learning~objective~"#1"~is~not~in~the~expected~format~"(K?)~OBJECTIVE".
  }
\ExplSyntaxOff

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
%% We typeset tables with the packages longtable and xltabular, which are compatible with tagging.
%% See also <https://github.com/istqborg/istqb_product_base/issues/152#issuecomment-5715946481>.
\RequirePackage{xcolor}
\definecolor{istqbgraytableheader}{HTML}{D9D9D9}
\definecolor{istqbbluetableheader}{HTML}{B5C5E5}
\definecolor{istqbgreentableheader}{HTML}{C5E0B3}
\RequirePackage{longtable}
\RequirePackage{xltabular}
\ExplSyntaxOn
\tl_new:N \l_istqb_table_tl
\tl_new:N \l_istqb_table_end_tl
\tl_new:N \l_istqb_table_caption_tl
\tl_new:N \l_istqb_table_label_tl
\tl_new:N \l_istqb_table_header_tl
\tl_new:N \l_istqb_table_body_tl
\seq_new:N \l_istqb_table_rows_seq
\keys_define:nn
  { istqb / table }
  {
    caption .tl_set:N = \l_istqb_table_caption_tl,
    label .tl_set:N = \l_istqb_table_label_tl,
  }
%%% Typeset a table that may break across pages, repeating the header row on every page.
%%%
%%% #1: caption (may be empty), #2: label (may be empty), #3: column specification,
%%% #4: cells of the header row, #5: rows of the table body, each followed by `\\` and a horizontal rule.
\cs_new_protected:Nn
  \istqb_table:nnnnn
  {
    \group_begin:
    \dim_set:Nn
      \tabcolsep
      { 3pt }
    % Approximate the height of rows in version 1.2.2 of this class, when tables were typeset with the package
    % tabularray with the settings `rows = { ht = \baselineskip }` and `rowsep = 2pt`.
    \cs_set:Npn
      \arraystretch
      { 1.25 }
    \tl_if_empty:nTF
      { #1 }
      {
        \skip_set:Nn \LTpre { \medskipamount }
        \skip_set:Nn \LTpost { \medskipamount }
        % Don't increment the counter of tables for tables without captions.
        \cs_set:Npn
          \LTcaptype
          { }
      }
      {
        \skip_set:Nn \LTpre { 1.5 \bigskipamount }
        \skip_set:Nn \LTpost { 1.5 \bigskipamount }
      }
    % Use the package xltabular if the table contains X columns and the package longtable otherwise.
    \tl_if_in:nnTF
      { #3 }
      { X }
      {
        \tl_set:Nn
          \l_istqb_table_tl
          { \begin { xltabular } { \linewidth } { #3 } }
        \tl_set:Nn
          \l_istqb_table_end_tl
          { \end { xltabular } }
      }
      {
        \tl_set:Nn
          \l_istqb_table_tl
          { \begin { longtable } { #3 } }
        \tl_set:Nn
          \l_istqb_table_end_tl
          { \end { longtable } }
      }
    % Typeset the caption and the header row on the first page.
    \tl_if_empty:nF
      { #1 }
      {
        \tl_put_right:Nn
          \l_istqb_table_tl
          { \caption { #1 } }
        \tl_if_empty:nF
          { #2 }
          {
            \tl_put_right:Nn
              \l_istqb_table_tl
              { \label { #2 } }
          }
        \tl_put_right:Nn
          \l_istqb_table_tl
          {
            \\
            \hline
            \rowcolor { istqbgraytableheader }
            #4 \\
            \hline
            \endfirsthead
          }
      }
    % Typeset the header row on the following pages (and on the first page if there is no caption).
    \tl_put_right:Nn
      \l_istqb_table_tl
      {
        \hline
        \rowcolor { istqbgraytableheader }
        #4 \\
        \hline
        \endhead
        #5
      }
    \tl_put_right:NV
      \l_istqb_table_tl
      \l_istqb_table_end_tl
    \tl_use:N
      \l_istqb_table_tl
    \group_end:
  }
\cs_generate_variant:Nn
  \istqb_table:nnnnn
  { nnnVV }
%%% Typeset a table from rows separated by `\\`, where the first row is the header row.
%%%
%%% #1: caption (may be empty), #2: label (may be empty), #3: column specification, #4: rows.
\cs_new_protected:Nn
  \istqb_table_from_rows:nnnn
  {
    \seq_set_split:Nnn
      \l_istqb_table_rows_seq
      { \\ }
      { #4 }
    \seq_pop_left:NN
      \l_istqb_table_rows_seq
      \l_istqb_table_header_tl
    \tl_clear:N
      \l_istqb_table_body_tl
    \seq_map_inline:Nn
      \l_istqb_table_rows_seq
      {
        \tl_if_blank:nF
          { ##1 }
          {
            \tl_put_right:Nn
              \l_istqb_table_body_tl
              { ##1 \\ \hline }
          }
      }
    \istqb_table:nnnVV
      { #1 }
      { #2 }
      { #3 }
      \l_istqb_table_header_tl
      \l_istqb_table_body_tl
  }
\cs_generate_variant:Nn
  \istqb_table_from_rows:nnnn
  { VVnn }
%%% A table environment with optional keys `caption` and `label` and a mandatory column specification.
\NewDocumentEnvironment
  { istqbtable }
  { O { } m +b }
  {
    \group_begin:
    \keys_set:nn
      { istqb / table }
      { #1 }
    \istqb_table_from_rows:VVnn
      \l_istqb_table_caption_tl
      \l_istqb_table_label_tl
      { #2 }
      { #3 }
    \group_end:
  }
  { }
\ExplSyntaxOff

%% Revision History
\NewDocumentEnvironment{istqbrevisionhistory}{+b}{%
  \begin{istqbtable}{|l|l|X|}#1\end{istqbtable}%
}{}

% Structure Tables
\ExplSyntaxOn
\tl_new:N
  \l_istqb_external_document_basename_tl
\int_new:N
  \l_istqb_external_document_last_page_int
\cs_new_protected:Nn
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
%% Typeset a substitute for a character that is missing from the font. In tagged PDF, the original character is
%% recorded as the actual text of the substitute, so that it is extracted correctly, e.g. by assistive technologies.
%% See also <https://github.com/istqborg/istqb_product_base/issues/152#issuecomment-5715946481>.
%%
%% The first argument of `\istqbactualtext` is the character code of the original character rather than the character
%% itself, since the character is active and would be expanded when read back from auxiliary files such as `.toc`.
\ExplSyntaxOn
\cs_new_protected:Npn
  \istqbactualtext
  #1#2
  {
    \tag_mc_end_push:
    \exp_args:Ne
      \tag_mc_begin:n
      { actualtext = \char_generate:nn { #1 } { 12 } }
    #2
    \tag_mc_end:
    \tag_mc_begin_pop:n
      { }
  }
\ExplSyntaxOff
\newcommand\istqbnewsubstitutedunicodechar[2]{%
  \newunicodechar{#1}{\texorpdfstring{\istqbactualtext{`#1}{#2}}{#1}}%
}
%% Subscripts
\istqbnewsubstitutedunicodechar{₀}{\textsubscript{0}}
\istqbnewsubstitutedunicodechar{₁}{\textsubscript{1}}
\istqbnewsubstitutedunicodechar{₂}{\textsubscript{2}}
\istqbnewsubstitutedunicodechar{₃}{\textsubscript{3}}
\istqbnewsubstitutedunicodechar{₄}{\textsubscript{4}}
\istqbnewsubstitutedunicodechar{₅}{\textsubscript{5}}
\istqbnewsubstitutedunicodechar{₆}{\textsubscript{6}}
\istqbnewsubstitutedunicodechar{₇}{\textsubscript{7}}
\istqbnewsubstitutedunicodechar{₈}{\textsubscript{8}}
\istqbnewsubstitutedunicodechar{₉}{\textsubscript{9}}
\istqbnewsubstitutedunicodechar{ₐ}{\textsubscript{a}}
\istqbnewsubstitutedunicodechar{ₑ}{\textsubscript{e}}
\istqbnewsubstitutedunicodechar{ₒ}{\textsubscript{o}}
\istqbnewsubstitutedunicodechar{ₓ}{\textsubscript{x}}
\istqbnewsubstitutedunicodechar{ₕ}{\textsubscript{h}}
\istqbnewsubstitutedunicodechar{ₖ}{\textsubscript{k}}
\istqbnewsubstitutedunicodechar{ₗ}{\textsubscript{l}}
\istqbnewsubstitutedunicodechar{ₘ}{\textsubscript{m}}
\istqbnewsubstitutedunicodechar{ₙ}{\textsubscript{n}}
\istqbnewsubstitutedunicodechar{ₚ}{\textsubscript{p}}
\istqbnewsubstitutedunicodechar{ₛ}{\textsubscript{s}}
\istqbnewsubstitutedunicodechar{ₜ}{\textsubscript{t}}
\istqbnewsubstitutedunicodechar{₊}{\textsubscript{+}}
\istqbnewsubstitutedunicodechar{₋}{\textsubscript{-}}
\istqbnewsubstitutedunicodechar{₌}{\textsubscript{=}}
\istqbnewsubstitutedunicodechar{₍}{\textsubscript{(}}
\istqbnewsubstitutedunicodechar{₎}{\textsubscript{)}}
%% Superscripts
\istqbnewsubstitutedunicodechar{⁰}{\textsuperscript{0}}
\istqbnewsubstitutedunicodechar{¹}{\textsuperscript{1}}
\istqbnewsubstitutedunicodechar{²}{\textsuperscript{2}}
\istqbnewsubstitutedunicodechar{³}{\textsuperscript{3}}
\istqbnewsubstitutedunicodechar{⁴}{\textsuperscript{4}}
\istqbnewsubstitutedunicodechar{⁵}{\textsuperscript{5}}
\istqbnewsubstitutedunicodechar{⁶}{\textsuperscript{6}}
\istqbnewsubstitutedunicodechar{⁷}{\textsuperscript{7}}
\istqbnewsubstitutedunicodechar{⁸}{\textsuperscript{8}}
\istqbnewsubstitutedunicodechar{⁹}{\textsuperscript{9}}
\istqbnewsubstitutedunicodechar{ⁱ}{\textsuperscript{i}}
\istqbnewsubstitutedunicodechar{ⁿ}{\textsuperscript{n}}
\istqbnewsubstitutedunicodechar{⁺}{\textsuperscript{+}}
\istqbnewsubstitutedunicodechar{⁻}{\textsuperscript{-}}
\istqbnewsubstitutedunicodechar{⁼}{\textsuperscript{=}}
\istqbnewsubstitutedunicodechar{⁽}{\textsuperscript{(}}
\istqbnewsubstitutedunicodechar{⁾}{\textsuperscript{)}}
%% Punctuation
\newunicodechar{−}{--}  % Render the minus sign as an en-dash, assuming that the author mistyped.
%% Math
\newunicodechar{≤}{\ensuremath{\leq}}
\newunicodechar{≥}{\ensuremath{\geq}}
\newunicodechar{≠}{\ensuremath{\neq}}
%% Spacing
\istqbnewsubstitutedunicodechar{ }{\,}
\istqbnewsubstitutedunicodechar{ }{\,}
\newunicodechar{​}{}
%% Box-drawing characters from old code pages (e.g. CP437)
\RequirePackage{pmboxdraw}
\newunicodechar{─}{\textSFx}
\newunicodechar{━}{\pmboxdrawuni{2501}}
\newunicodechar{│}{\textSFxi}
\newunicodechar{┃}{\pmboxdrawuni{2503}}
\newunicodechar{┌}{\textSFi}
\newunicodechar{┍}{\pmboxdrawuni{250D}}
\newunicodechar{┎}{\pmboxdrawuni{250E}}
\newunicodechar{┏}{\pmboxdrawuni{250F}}
\newunicodechar{┐}{\textSFiii}
\newunicodechar{┑}{\pmboxdrawuni{2511}}
\newunicodechar{┒}{\pmboxdrawuni{2512}}
\newunicodechar{┓}{\pmboxdrawuni{2513}}
\newunicodechar{└}{\textSFii}
\newunicodechar{┕}{\pmboxdrawuni{2515}}
\newunicodechar{┖}{\pmboxdrawuni{2516}}
\newunicodechar{┗}{\pmboxdrawuni{2517}}
\newunicodechar{┘}{\textSFiv}
\newunicodechar{┙}{\pmboxdrawuni{2519}}
\newunicodechar{┚}{\pmboxdrawuni{251A}}
\newunicodechar{┛}{\pmboxdrawuni{251B}}
\newunicodechar{├}{\textSFviii}
\newunicodechar{┝}{\pmboxdrawuni{251D}}
\newunicodechar{┞}{\pmboxdrawuni{251E}}
\newunicodechar{┟}{\pmboxdrawuni{251F}}
\newunicodechar{┠}{\pmboxdrawuni{2520}}
\newunicodechar{┡}{\pmboxdrawuni{2521}}
\newunicodechar{┢}{\pmboxdrawuni{2522}}
\newunicodechar{┣}{\pmboxdrawuni{2523}}
\newunicodechar{┤}{\textSFix}
\newunicodechar{┥}{\pmboxdrawuni{2525}}
\newunicodechar{┦}{\pmboxdrawuni{2526}}
\newunicodechar{┧}{\pmboxdrawuni{2527}}
\newunicodechar{┨}{\pmboxdrawuni{2528}}
\newunicodechar{┩}{\pmboxdrawuni{2529}}
\newunicodechar{┪}{\pmboxdrawuni{252A}}
\newunicodechar{┫}{\pmboxdrawuni{252B}}
\newunicodechar{┬}{\textSFvi}
\newunicodechar{┭}{\pmboxdrawuni{252D}}
\newunicodechar{┮}{\pmboxdrawuni{252E}}
\newunicodechar{┯}{\pmboxdrawuni{252F}}
\newunicodechar{┰}{\pmboxdrawuni{2530}}
\newunicodechar{┱}{\pmboxdrawuni{2531}}
\newunicodechar{┲}{\pmboxdrawuni{2532}}
\newunicodechar{┳}{\pmboxdrawuni{2533}}
\newunicodechar{┴}{\textSFvii}
\newunicodechar{┵}{\pmboxdrawuni{2535}}
\newunicodechar{┶}{\pmboxdrawuni{2536}}
\newunicodechar{┷}{\pmboxdrawuni{2537}}
\newunicodechar{┸}{\pmboxdrawuni{2538}}
\newunicodechar{┹}{\pmboxdrawuni{2539}}
\newunicodechar{┺}{\pmboxdrawuni{253A}}
\newunicodechar{┻}{\pmboxdrawuni{253B}}
\newunicodechar{┼}{\textSFv}
\newunicodechar{┽}{\pmboxdrawuni{253D}}
\newunicodechar{┾}{\pmboxdrawuni{253E}}
\newunicodechar{┿}{\pmboxdrawuni{253F}}
\newunicodechar{╀}{\pmboxdrawuni{2540}}
\newunicodechar{╁}{\pmboxdrawuni{2541}}
\newunicodechar{╂}{\pmboxdrawuni{2542}}
\newunicodechar{╃}{\pmboxdrawuni{2543}}
\newunicodechar{╄}{\pmboxdrawuni{2544}}
\newunicodechar{╅}{\pmboxdrawuni{2545}}
\newunicodechar{╆}{\pmboxdrawuni{2546}}
\newunicodechar{╇}{\pmboxdrawuni{2547}}
\newunicodechar{╈}{\pmboxdrawuni{2548}}
\newunicodechar{╉}{\pmboxdrawuni{2549}}
\newunicodechar{╊}{\pmboxdrawuni{254A}}
\newunicodechar{╋}{\pmboxdrawuni{254B}}
\newunicodechar{═}{\textSFxliii}
\newunicodechar{║}{\textSFxxiv}
\newunicodechar{╒}{\textSFli}
\newunicodechar{╓}{\textSFlii}
\newunicodechar{╔}{\textSFxxxix}
\newunicodechar{╕}{\textSFxxii}
\newunicodechar{╖}{\textSFxxi}
\newunicodechar{╗}{\textSFxxv}
\newunicodechar{╘}{\textSFl}
\newunicodechar{╙}{\textSFxlix}
\newunicodechar{╚}{\textSFxxxviii}
\newunicodechar{╛}{\textSFxxviii}
\newunicodechar{╜}{\textSFxxvii}
\newunicodechar{╝}{\textSFxxvi}
\newunicodechar{╞}{\textSFxxxvi}
\newunicodechar{╟}{\textSFxxxvii}
\newunicodechar{╠}{\textSFxlii}
\newunicodechar{╡}{\textSFxix}
\newunicodechar{╢}{\textSFxx}
\newunicodechar{╣}{\textSFxxiii}
\newunicodechar{╤}{\textSFxlvii}
\newunicodechar{╥}{\textSFxlviii}
\newunicodechar{╦}{\textSFxli}
\newunicodechar{╧}{\textSFxlv}
\newunicodechar{╨}{\textSFxlvi}
\newunicodechar{╩}{\textSFxl}
\newunicodechar{╪}{\textSFliv}
\newunicodechar{╫}{\textSFliii}
\newunicodechar{╬}{\textSFxliv}
\newunicodechar{╴}{\pmboxdrawuni{2574}}
\newunicodechar{╵}{\pmboxdrawuni{2575}}
\newunicodechar{╶}{\pmboxdrawuni{2576}}
\newunicodechar{╷}{\pmboxdrawuni{2577}}
\newunicodechar{╸}{\pmboxdrawuni{2578}}
\newunicodechar{╹}{\pmboxdrawuni{2579}}
\newunicodechar{╺}{\pmboxdrawuni{257A}}
\newunicodechar{╻}{\pmboxdrawuni{257B}}
\newunicodechar{╼}{\pmboxdrawuni{257C}}
\newunicodechar{╽}{\pmboxdrawuni{257D}}
\newunicodechar{╾}{\pmboxdrawuni{257E}}
\newunicodechar{╿}{\pmboxdrawuni{257F}}
\newunicodechar{▀}{\textupblock}
\newunicodechar{▁}{\pmboxdrawuni{2581}}
\newunicodechar{▂}{\pmboxdrawuni{2582}}
\newunicodechar{▃}{\pmboxdrawuni{2583}}
\newunicodechar{▄}{\textdnblock}
\newunicodechar{▅}{\pmboxdrawuni{2585}}
\newunicodechar{▆}{\pmboxdrawuni{2586}}
\newunicodechar{▇}{\pmboxdrawuni{2587}}
\newunicodechar{█}{\textblock}
\newunicodechar{▉}{\pmboxdrawuni{2589}}
\newunicodechar{▊}{\pmboxdrawuni{258A}}
\newunicodechar{▋}{\pmboxdrawuni{258B}}
\newunicodechar{▌}{\textlfblock}
\newunicodechar{▍}{\pmboxdrawuni{258D}}
\newunicodechar{▎}{\pmboxdrawuni{258E}}
\newunicodechar{▏}{\pmboxdrawuni{258F}}
\newunicodechar{▐}{\textrtblock}
\newunicodechar{░}{\textltshade}
\newunicodechar{▒}{\textshade}
\newunicodechar{▓}{\textdkshade}
\newunicodechar{▔}{\pmboxdrawuni{2594}}
\newunicodechar{▕}{\pmboxdrawuni{2595}}
\newunicodechar{▖}{\pmboxdrawuni{2596}}
\newunicodechar{▗}{\pmboxdrawuni{2597}}
\newunicodechar{▘}{\pmboxdrawuni{2598}}
\newunicodechar{▙}{\pmboxdrawuni{2599}}
\newunicodechar{▚}{\pmboxdrawuni{259A}}
\newunicodechar{▛}{\pmboxdrawuni{259B}}
\newunicodechar{▜}{\pmboxdrawuni{259C}}
\newunicodechar{▝}{\pmboxdrawuni{259D}}
\newunicodechar{▞}{\pmboxdrawuni{259E}}
\newunicodechar{▟}{\pmboxdrawuni{259F}}
%% Miscellaneous
\newunicodechar{®}{\textsuperscript{\textregistered}}
\newunicodechar{►}{\makebox[\fontcharwd\font`0][c]{\ensuremath{\blacktriangleright}}}

% Miscellaneous
\RequirePackage{lipsum}  % The `lipsum` package is used in a complex table from the example document.
