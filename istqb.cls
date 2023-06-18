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

%% Text alignment
\raggedbottom
\RequirePackage{ragged2e}
\RaggedRight

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
\str_new:N \g_istqb_title_str
\str_gset:Nn
  \g_istqb_title_str
  { Title }
\str_new:N \g_istqb_subtitle_str
\str_gset:Nn
  \g_istqb_subtitle_str
  { Subtitle }
\lhead{%
  \kern 0.1in \mbox{\g_istqb_title_str} \\[0.025in] \leavevmode
  \kern 0.1in \mbox{\g_istqb_subtitle_str}%
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