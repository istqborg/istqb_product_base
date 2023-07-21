\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{istqb}[2023/06/18 LaTeX class for ISTQB Syllabi]
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

%% Paragraphs and text alignment
\raggedbottom  % Do not try to equalize the number of lines on a page by increasing vertical spaces.
\RequirePackage{ragged2e}
\RaggedRight  % Do not try to justify text by increasing horizontal spaces.
\usepackage{parskip}  % Put half of line height between paragraphs.

%% Typefaces
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
\str_new:N \g_istqb_schema_str
\str_new:N \g_istqb_level_str
\lhead{%
  \tl_if_empty:NTF
    \g_istqb_schema_str
    {
      \tl_if_empty:NF
        \g_istqb_level_str
        {
          \kern 0.1in \mbox{\g_istqb_level_str}
        }
    }
    {
      \tl_if_empty:NTF
        \g_istqb_level_str
        {
          \kern 0.1in \mbox{\g_istqb_schema_str}
        }
        {
          \kern 0.1in \mbox{\g_istqb_schema_str} \\[0.025in] \leavevmode
          \kern 0.1in \mbox{\g_istqb_level_str}
        }
    }
}
\ExplSyntaxOff
\rhead{%
  \includegraphics[height=\headheight]{istqb-logo}%
}
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
\str_new:N \g_istqb_version_str
\str_gset:Nn
  \g_istqb_version_str
  { vM.mm }
\str_new:N \g_istqb_date_str
\str_gset:Nn
  \g_istqb_date_str
  { Development~Phase~or~YYYY/MM/DD }
\str_new:N \g_istqb_release_str
\str_gset:Nn
  \g_istqb_release_str
  { For~public~release }
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
      leftmargin=-8pt,
      rightmargin=-8pt,
    ]
      \begin{minipage}{0.4\linewidth}
      \mbox{\g_istqb_version_str}
      \end{minipage}
      \begin{minipage}{0.2\linewidth}
      \centering
      \mbox{Page~\thepage{}~of~\pageref{LastPage}}
      \end{minipage}
      \begin{minipage}{0.4\linewidth}
      \hfill
      \mbox{\g_istqb_date_str}
      \end{minipage}
      \\
      \mbox{\g_istqb_release_str}
      \\[0.16in]
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
    \tl_new:N \l_istqb_geometry_tl
    \tl_gset:NV
      \l_istqb_geometry_tl
      \g_istqb_geometry_tl
    \tl_gput_right:Nn
      \l_istqb_geometry_tl
      {
        bottom = \dimexpr( 0.8in + \box_ht_plus_dp:N \l_istqb_footer_box ),
      }
    \exp_args:NV
      \newgeometry
      \l_istqb_geometry_tl
    \cfoot
      {
        \tl_use:N \g_istqb_footer_tl
      }
  }
\ExplSyntaxOff

% Graphics
\RequirePackage{graphicx}
\graphicspath{{./img}{.}}  % Look for images first in ./img and then in ./
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
\str_new:N \g_istqb_title_str
\str_new:N \g_istqb_code_str
\newcommand
  \istqblandingpage
  {
    \group_begin:
    \parskip=0pt
    \centering
    \leavevmode \par \vfill
    \normalfont
    \bfseries
    \fontsize { 24 } { 28.8 } \selectfont
    \g_istqb_schema_str \\
    \tl_if_empty:NF
      \g_istqb_title_str
      {
        \g_istqb_title_str
        \tl_if_empty:NF
          \g_istqb_code_str
          {
            {}~(\g_istqb_code_str)
          }
        \\
      }
    \g_istqb_level_str \\
    Syllabus
    \par \vfill
    \normalfont
    \itshape
    \fontsize { 18 } { 21.6 } \selectfont
    \g_istqb_version_str
    \par \vfill \vfill
    \leaders \vrule width \textwidth \vskip 1pt
    \par \vspace { 0.2in }
    \normalfont
    \fontsize { 18 } { 21.6 } \selectfont
    International~Software~Testing~Qualifications~Board
    \par \vspace { 0.3in }
    \leaders \vrule width \textwidth \vskip 1pt
    \par \vspace { 0.45in }
    \includegraphics [ height = 1.2in ] { istqb-logo }
    \par \vspace { 1.45in }
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
    innerrightmargin=0.08in,
    innertopmargin=0.05in,
    innerbottommargin=0in,
    leftmargin=0.06in,
    rightmargin=-0.1in,
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
    innerrightmargin=0.08in,
    innertopmargin=0.035in,
    innerbottommargin=0in,
    leftmargin=0.06in,
    rightmargin=-0.1in,
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
  \clearpage
}
\newenvironment{istqbsubobjectives}{%
  \def\istqbsubobjective##1{%
    \stepcounter{istqbsubobjective}%
    FL-\thesection.\theistqbobjective.\theistqbsubobjective & ##1 \\[0.07in]
  }%
  \LTpre=0.08in
  \LTpost=0.12in
  \begin{longtable}{@{}p{1in}@{}p{\dimexpr(\linewidth - 1in)}@{}}%
}{%
  \end{longtable}%
  \setcounter{istqbsubobjective}{0}%
  \par\kern -0.2in
}

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
%% Ensure that the index is numbered and part of the table of contents.
\renewcommand\imki@indexlevel{\section}
%% Remove spaces between indexed items.
\RequirePackage{etoolbox}
\apptocmd\theindex{\let\indexspace=\relax}{}{\PatchFailed}

% Hyperlinks
\PassOptionsToPackage{hidelinks}{hyperref}
\RequirePackage{hyperref}

% Revision History
\RequirePackage{tabularx, array}
\RequirePackage{xcolor, colortbl}
\definecolor{istqbrevisionhistoryheader}{HTML}{D9D9D9}
\long\def\beginistqbrevisionhistory#1\endistqbrevisionhistory{%
  \leavevmode \kern 0.08in\relax % Indent the table
  \renewcommand{\arraystretch}{1.5}% Increase line spread
  \begin{tabularx}\linewidth{|l|l|X|}\hline
  \rowcolor{istqbrevisionhistoryheader}
  #1%
  \end{tabularx}%
}