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
\PassOptionsToPackage{hidelinks}{hyperref}
\RequirePackage{hyperref}
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
    % Ensure that the footer is always the 0.8in from the bottom of the page regardless of its contents.
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
\RequirePackage{etoolbox}
\pretocmd{\listoffigures}{\clearpage}{}{}  % Ensure List of Figures starts on a new page.
\pretocmd{\listoftables}{\clearpage}{}{}  % Ensure List of Tables starts on a new page.

% Table of Contents
\setcounter{tocdepth}{3}  % Show level 1 up to level 3 of headings.
\setcounter{section}{-1}  % Start sections from 0.

% Bibliography
\RequirePackage{csquotes}
\PassOptionsToPackage{style=iso-authoryear}{biblatex}
\RequirePackage{biblatex}
\defbibheading{bibliography}[Bibliography]{%
  \clearpage
  \section{#1}%
  \addcontentsline{toc}{section}{#1}%
}
