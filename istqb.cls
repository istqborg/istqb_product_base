\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{istqb}[2023/06/18 LaTeX class for ISTQB Syllabi]
\LoadClass[10pt]{article}

% Page layout
%% Page geometry
\RequirePackage{geometry}
\ExplSyntaxOn
\tl_new:N \g_geometry_tl
\tl_gset:Nn
  \g_geometry_tl
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
  \g_geometry_tl
\ExplSyntaxOff

%% Text alignment
\raggedbottom
\RequirePackage{ragged2e}
\RaggedRight

%% Typefaces
\usepackage{tgheros}
\renewcommand*\familydefault{\sfdefault}

%% Microtypography
\usepackage{microtype}

%% Header and Footer
\RequirePackage{fancyhdr}
\pagestyle{fancy}
\fancyhf{}

%%% Header
\lhead{%
  \kern 0.1in \mbox{Certified Tester} \\[0.025in] \leavevmode
  \kern 0.1in \mbox{Foundation Level}%
}
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
\RequirePackage{hyperref}
\ExplSyntaxOn
\AtBeginDocument
  {
    \box_new:N \g_footer_box
    \vbox_gset:Nn
      \g_footer_box
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
          Version~2018~V3.1\hfill
          Page~\thepage{}~of~\pageref{LastPage}\hfill
          11~November~2019\\
          For~public~release\\[0.16in]
          \fontsize{6}{6}\selectfont
          \textcopyright{}~International~Software~Testing~Qualifications~Board
        \end{mdframed}
      }
    % Ensure that the footer is always the 0.8in from the bottom of the page regardless of its contents.
    \tl_new:N \l_geometry_tl
    \tl_gset:NV
      \l_geometry_tl
      \g_geometry_tl
    \tl_gput_right:Nn
      \l_geometry_tl
      {
        bottom = \dimexpr( 0.8in + \box_ht_plus_dp:N \g_footer_box ),
      }
    \exp_args:NV
      \newgeometry
      \l_geometry_tl
    \cfoot
      {
        \box_use:N \g_footer_box
      }
  }
\ExplSyntaxOff

% Graphics
\RequirePackage{graphicx}
\graphicspath{{./img}{.}}  % Look for images first in ./img and then in ./