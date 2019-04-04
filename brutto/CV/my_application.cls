\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{my_application}[2018/09/19 My custom application class]
% 
\LoadClass{article}
%
\RequirePackage{geometry}
%
\geometry{
 a4paper,
 left=20mm,
 top=20mm,
 headheight=10mm,
 right = 20mm,
 marginparwidth = 0mm,
 marginparsep = 0mm,
 }
%
\RequirePackage{xcolor} % Used to color text in header
%
\RequirePackage{fontawesome} % Contains lots os symbols
%
\RequirePackage{tikz}
%
\RequirePackage{etoolbox}
%
\RequirePackage{array}
%
\RequirePackage{fancyhdr}
%
\RequirePackage{enumitem}
%
\RequirePackage{lipsum}
%
\RequirePackage{calc}
%
\usepackage{scrextend}
%
\usepackage[ddmmyyyy]{datetime}
%
% Name and address formating
\newcommand{\emailsymbol}{\faAt}
\newcommand{\phonesymbol}{\faPhone}
%
% Name function
\newcommand{\name}[1]{
  \raggedright{\Huge{#1}}
}
% Title function
\newcommand{\degree}[1]{
	\raggedright{\Large{\textbf{#1}}}
}
% Address function
\newcommand{\contact}[3]{
	\noindent
    \textcolor{black}{
    Venlig hilsen,\\
    \newline
    #1\\
    Mail: #2 Tlf: #3\\
    }
    \par\vspace{\baselineskip}%
}
%
% Page style for first page
\newcommand{\firstpagestyle}[1]{
\thispagestyle{fancy}
\fancyhf{}
\chead{#1}	% Address
%\rhead{#2}	% Address
%\rfoot{Page \thepage}
\renewcommand{\headrulewidth}{0pt}
}
%
% packaged to costumize section headers
\RequirePackage{titlesec}
% Costum section header
\titleformat{\section}         % Customise the \section command 
  {\bfseries\large\raggedright} % Make the \section headers large (\Large),
                               % small capitals (\scshape) and left aligned (\raggedright)
  {}{0em}                      % Can be used to give a prefix to all sections, like 'Section ...'
  {}                           % Can be used to insert code before the heading
  %[\titlerule]                 % Inserts a horizontal line after the heading
%
% Add date to section header
\newcommand{\datedsection}[2]{%
  \section[#2]{#1~#2}%
}
%
% Costum subsection header
\titleformat{\subsection}
  {\large\scshape\raggedright}
  {}{0em}
  {}
%
% Add date to subsection header
\newcommand{\datedsubsection}[2]{%
  \subsection[#2]{#1~#2}%
}
%
% Costum subsubsection header
\titleformat{\subsubsection}         % Customise the \section command 
  {\normalsize} % Make the \section headers large (\Large),
               % small capitals (\scshape) and left aligned (\raggedright)
  {}{0em}      % Can be used to give a prefix to all sections, like 'Section ...'
  {}
%\titlespacing{command}{left spacing}{before spacing}{after spacing}[right]  
\titlespacing*{\subsubsection}{\parindent}{0ex}{1ex}
%
% Project subsubsection
\newcommand{\project}[1]{%
	\subsubsection*{Projekt:~#1}
}
%
\newlength{\myl}
\settowidth{\myl}{Fagligt foku}
%
\newenvironment{focusitem}{
%\newcommand{\topic}[2]{ \item{##1 / ##2\} }
\setitemize[1]{label=-}
%\hspace*{\parindent}
	\begin{addmargin}[\parindent]{0pt}
		Fagligt focus:
		\begin{itemize}[leftmargin=\myl]
		}
		{
		\end{itemize}
	\end{addmargin}
	\par\vspace{\baselineskip}%
	}
%
\newlength{\columnOneWidth}
\settowidth{\columnOneWidth}{Metode(r)}
\newlength{\columnTwoWidth}
\settowidth{\columnTwoWidth}{:}
\newlength{\columnThreeWidth}
\setlength{\columnThreeWidth}{\dimexpr(\textwidth-\parindent-\columnOneWidth-\columnTwoWidth-27pt)\relax}
%
\newenvironment{projectTable}{
	%\begin{addmargin}[\parindent]{0pt}
		%\par\vspace{\baselineskip}%
		%\begin{tabular}{@{\hskip0pt} p{\columnOneWidth} @{\hskip7pt} p{\columnTwoWidth} @{\hskip5pt} p{\columnThreeWidth}}
		%\begin{tabular}{@{\hskip0pt} l @{\hskip7pt} l @{\hskip5pt} l}
		\begin{tabular}{ p{\columnOneWidth} @{} >{${}}c<{{}$} @{} p{\columnThreeWidth}}
	}
	{
		\end{tabular}
	%\end{addmargin}
	\par\vspace{\baselineskip}%
	}
%
\newcommand{\ratingmarker}{\faCircle}
%
%\colorlet{accent}{blue!70!black}
\colorlet{accent}{black}
\colorlet{emphasis}{black}
%\colorlet{body}{blue!80!white}
\colorlet{body}{black}
%
\newcommand{\cvskill}[2]{%
	\textcolor{emphasis}{\textbf{#1}}\hspace*{\parindent}%\hfill
	\foreach \x in {1,...,5}{%
  	\space{\ifnumgreater{\x}{#2}{\color{body!30}}{\color{accent}}\ratingmarker}}\par%
}
%
\newcommand{\rating}[1]{%
	\foreach \x in {1,...,5}{%
  	\space{\ifnumgreater{\x}{#1}{\color{body!20}}{\color{accent!50}}\ratingmarker}}%\par%
}
%
\newcommand{\skill}[2]{%
	%\begin{addmargin}[\parindent]{0pt}
		\parbox[t]{2cm}{#1} \rating{#2}
	%\end{addmargin}
}
\newenvironment{skillTable}[2]{
	\newlength{\columnWidth}
	\setlength{\columnWidth}{\dimexpr(\textwidth/#1)\relax}
	\begin{tabular}{#2}
}
{
	\end{tabular}
	\par\vspace{\baselineskip}%
}
%
\newcommand{\skipline}{
    \\[\baselineskip]
}
