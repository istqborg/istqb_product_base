\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{istqb}[2023/10/16 LaTeX class for ISTQB Documents]
\LoadClass[10pt]{article}

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
\tl_gset:Nn
  \g_istqb_logo_tl
  { istqb-logo-default }
\lhead{%
  \kern 0.1in
  \fontsize{9}{10.8}\selectfont
  \begin{minipage}[b]{0.7\linewidth}
    \tl_if_empty:NF
      \g_istqb_schema_tl
      {
        \mbox { \g_istqb_schema_tl }
      }
    \tl_if_empty:NF
      \g_istqb_level_tl
      {
        \tl_if_empty:NF
          \g_istqb_schema_tl
          { ~ }
        \mbox { \g_istqb_level_tl }
      }
    \tl_if_empty:NF
      \g_istqb_title_tl
      {
        \tl_if_empty:NTF
          \g_istqb_schema_tl
          {
            \tl_if_empty:NF
              \g_istqb_level_tl
              { \\ }
          }
          { \\ }
        \g_istqb_title_tl
        \tl_if_empty:NF
          \g_istqb_code_tl
          {
            \mbox { ~(\g_istqb_code_tl) }
          }
      }
  \end{minipage}
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
\RequirePackage{xcolor}
\RequirePackage{mdframed}
\RequirePackage{lastpage}
\ExplSyntaxOn
\tl_new:N \g_istqb_version_tl
\tl_new:N \g_istqb_date_tl
\tl_new:N \g_istqb_release_tl
\tl_new:N \g_istqb_footer_tl
\tl_gset:Nn
  \g_istqb_footer_tl
  {
    \begin{mdframed}[
      linewidth=0.75pt,
      linecolor=black!25!white,
      innerleftmargin=0.08in,
      innerrightmargin=8pt,
      innertopmargin=3pt,
      innerbottommargin=3pt,
      skipabove=\baselineskip,
      leftmargin=-8pt,
      rightmargin=-8pt,
    ]
      \fontsize{9}{10.8}\selectfont
      \begin{minipage}{0.4\linewidth}
      \mbox{\g_istqb_version_tl}
      \end{minipage}
      \begin{minipage}{0.2\linewidth}
      \centering
      \mbox{Page~\thepage{}~of~\pageref{LastPage}}
      \end{minipage}
      \begin{minipage}{0.4\linewidth}
      \hfill
      \mbox{\g_istqb_date_tl}
      \end{minipage}
      \\
      \mbox{\g_istqb_release_tl}
    \end{mdframed}
    \begin{mdframed}[
      linewidth=0.75pt,
      linecolor=black!25!white,
      innerleftmargin=0.08in,
      innerrightmargin=8pt,
      innertopmargin=3pt,
      innerbottommargin=3pt,
      skipabove=\baselineskip,
      rightmargin=-8pt,
    ]
      \fontsize{6}{6}\selectfont
      \textcopyright{}~International~Software~Testing~Qualifications~Board
    \end{mdframed}
  }
\box_new:N \l_istqb_footer_box
\AtBeginDocument
  {
    \cs_generate_variant:Nn
      \vbox_gset:Nn
      { NV }
    \vbox_gset:NV
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

% Table of Contents
\setcounter{tocdepth}{3}  % Show level 1 up to level 3 of headings.
\setcounter{section}{-1}  % Start sections from 0.

% Bibliography
\RequirePackage{csquotes}
\PassOptionsToPackage{style=iso-authoryear, citetracker=true}{biblatex}
\RequirePackage{biblatex}
\urlstyle{same}
\setlength\bibitemsep{0.5\baselineskip}

%% Bibliographic categories
\DeclareBibliographyCategory{uncited}
\AtEveryBibitem{\ifciteseen{}{\addtocategory{uncited}{\thefield{entrykey}}}}

%% Bibliographic filters
\defbibfilter{standards}{type=report and not category=uncited}
\defbibfilter{istqb-documents}{type=misc and keyword=istqb and not category=uncited}
\defbibfilter{books}{type=book and not category=uncited}
\defbibfilter{articles}{type=article and not category=uncited}
\defbibfilter{further-reading}{not ( type=report or ( type=misc and keyword=istqb ) or type=book or type=article ) or category=uncited}

%% Reference printing
\newcommand\printistqbbibliography{%
  \clearpage
  \section{References}%
  \begingroup
  \defbibheading{bibliography}{%
    \normalfont
    \mdseries
    \fontsize{14}{16.8}\selectfont
    ##1%
  }%
  \printbibliography[filter=standards, title=Standards]%
  \printbibliography[filter=istqb-documents, title=ISTQB\textsuperscript{\textregistered} Documents]%
  \printbibliography[filter=books, title=Books]%
  \printbibliography[filter=articles, title=Articles]%
  \endgroup
  \begingroup
  \defbibheading{bibliography}{\section{##1}}%
  \printbibliography[filter=further-reading, title=Further Reading]%
  \endgroup
}

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
    International~Software~Testing~Qualifications~Board
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
        Provided~by~
        \int_compare:nNnTF
          { \seq_count:N \g_istqb_third_parties_seq } = { 1 }
          {
            % A single third party organization
            \seq_get_left:NN
              \g_istqb_third_parties_seq
              \l_tmpa_tl
            \tl_use:N
              \l_tmpa_tl
          }
          {
            % Several third party organizations
            \par \vfill
            \seq_use:Nnnn
              \g_istqb_third_parties_seq
              { ~and~ }
              { ,~ }
              { ,~and~ }
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
%% Sections, subsections, and subsubsections
\RequirePackage{xpatch, mdframed}
\xpatchcmd{\section}{\normalfont\Large\bfseries}{\istqbsectionbox}{}{\PatchFailed}
\xpatchcmd{\subsection}{\normalfont\large\bfseries}{\istqbsubsectionbox}{}{\PatchFailed}
\RequirePackage{titlesec}
\newcommand\istqbsectionbox[1]{%
  \clearpage
  \begin{mdframed}[
    linewidth=0.95pt,
    linecolor=black,
    innerleftmargin=0.08in,
    innerrightmargin=0.2in,
    innertopmargin=0.05in,
    innerbottommargin=0in,
    leftmargin=0in,
    rightmargin=0in,
  ]%
    \normalfont
    \bfseries
    \fontsize{16}{19.2}\selectfont
    \phantomsection
    \begingroup
    \titlelabel{\thetitle\kern0.3em}
    #1%
    \endgroup
  \end{mdframed}%
}
\newcommand\istqbsubsectionbox[1]{%
  \begin{mdframed}[
    linewidth=0.63pt,
    linecolor=black,
    innerleftmargin=0.08in,
    innerrightmargin=0.2in,
    innertopmargin=0.035in,
    innerbottommargin=0in,
    leftmargin=0in,
    rightmargin=0in,
  ]%
    \normalfont
    \mdseries
    \fontsize{14}{16.8}\selectfont
    \phantomsection
    \begingroup
    \titlelabel{\thetitle\kern0.3em}
    #1%
    \endgroup
  \end{mdframed}%
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
\titlespacing\section{0pt}{0pt}{*3.2}
\titlespacing\subsection{0pt}{*5.5}{*0.8}
\titlespacing\subsubsection{0pt}{*3.25}{*1}
\newcommand\istqbunnumberedsection[1]{%
  \section*{#1}%
  \markboth{#1}{#1}%
  \addcontentsline{toc}{section}{#1}%
}
\newcommand\istqbunnumberedsubsection[1]{%
  \subsection*{#1}%
  \addcontentsline{toc}{subsection}{#1}%
}
\newcommand\istqbunnumberedsubsubsection[1]{%
  \subsubsection*{#1}%
  \addcontentsline{toc}{subsubsection}{#1}%
}

%% Learning objectives
\RequirePackage{longtable}
\newcounter{istqbobjective}[section]
\newcounter{istqbsubobjective}[istqbobjective]
\newenvironment{istqbobjectives}{%
  \kern 0.175in\relax
  \def\istqbobjective##1{%
    \stepcounter{istqbobjective}%
    \par\kern -0.03in
    \paragraph{\thesection.\theistqbobjective\enspace##1}%
    \par\leavevmode
  }%
}{%
  \setcounter{istqbobjective}{0}%
  \par\kern 0.12in
}
\ExplSyntaxOn
\tl_new:N \g_istqb_prefix_tl
\tl_gset:Nn \g_istqb_prefix_tl { ?? }
\newenvironment{istqbsubobjectives}{
  \def\istqbsubobjective##1{
    \stepcounter{istqbsubobjective}
    \g_istqb_prefix_tl-\thesection.\theistqbobjective.\theistqbsubobjective & ##1 \\[0.07in]
  }
  \LTpre=0.08in
  \LTpost=0.12in
  \begin{longtable}{@{}p{1in}@{}p{\dimexpr(\linewidth - 1in)}@{}}
}{
  \end{longtable}
  \setcounter{istqbsubobjective}{0}
  \par\kern -0.2in
}
\ExplSyntaxOff

%% Appendices
\newcounter{istqbappendix}
\newenvironment{istqbappendices}{%
  \begingroup
  \let\istqboldsection\section
  \def\section##1{%
    \stepcounter{istqbappendix}%
    \istqboldsection{Appendix~\Alph{istqbappendix}~--~##1}}%
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
\RequirePackage{tabularx, array}
\RequirePackage{xcolor, colortbl}
\definecolor{istqbtableheader}{HTML}{D9D9D9}
\ExplSyntaxOn
\long\def\beginistqbtable#1#2\endistqbtable{
  \renewcommand{\arraystretch}{1.5}  % Increase line spread
  \str_if_in:nnTF
    { #1 }
    { X }
    {
      \begin{tabularx}\linewidth{#1}\hline
      \rowcolor{istqbtableheader}
      #2
      \end{tabularx}
    }
    {
      \group_begin:
      \centering
      \begin{tabular}{#1}\hline
      \rowcolor{istqbtableheader}
      #2
      \end{tabular}
      \par
      \group_end:
    }
}
\ExplSyntaxOff

%% Revision History
\long\def\beginistqbrevisionhistory#1\endistqbrevisionhistory{%
  \beginistqbtable{|l|l|X|}#1\endistqbtable
}

% Table of Contents
\newcommand\istqbtableofcontents{%
  \phantomsection
  \currentpdfbookmark{\contentsname}{istqbtoc}%
  \tableofcontents
}

% Unicode characters
\RequirePackage{newunicodechar}
\newunicodechar{®}{\textsuperscript{\textregistered}}
\newunicodechar{−}{--}  % Render the minus sign as an en-dash, assuming that the author mistyped.
\newunicodechar{≤}{\ensuremath{\leq}}
\newunicodechar{≥}{\ensuremath{\geq}}
\newunicodechar{​}{}
