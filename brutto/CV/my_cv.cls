\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{my_cv}[2018/09/19 My custom CV class]
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
% Name and address formating
\newcommand{\emailsymbol}{\faAt}
\newcommand{\phonesymbol}{\faPhone}
%
% Name function
\newcommand{\name}[1]{
  \raggedright{\Huge{#1}}\newline
}
% Title function
\newcommand{\degree}[1]{
	\raggedright{\large{#1}}	
}
% Address function
\newcommand{\contact}[5]{
    \textcolor{gray}{
    #1 {\large\textperiodcentered} #2 {\large\textperiodcentered} #3
    {\Large\textperiodcentered} #4 \ {\Large} #5
    }
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
  {\Large\raggedright} % Make the \section headers large (\Large),
                               % small capitals (\scshape) and left aligned (\raggedright)
  {}{0em}                      % Can be used to give a prefix to all sections, like 'Section ...'
  {}                           % Can be used to insert code before the heading
  [\titlerule]                 % Inserts a horizontal line after the heading
%\scshape
% Add date to section header
\newcommand{\datedsection}[2]{%
  \section[#2]{#1~#2}%
}
%
% Costum subsection header
\titleformat{\subsection}
  {\large\raggedright}
  {}{0em}
  {}
%
% Add date to subsection header
\newcommand{\datedsubsection}[2]{%
  \subsection[#2]{#1:~#2}%
  %\subsection[#2]{\textdb{#1:}~#2}%
}
%
% Costum subsubsection header
\titleformat{\subsubsection}         % Customise the \section command 
  {\normalsize} % Make the \section headers large (\Large),
               % small capitals (\scshape) and left aligned (\raggedright)
  {}{0em}      % Can be used to give a prefix to all sections, like 'Section ...'
  {}
%\titlespacing{command}{left spacing}{before spacing}{after spacing}[right]  
%\titlespacing*{\subsubsection}{\parindent}{0ex}{1ex}
%
% Project subsubsection
\newcommand{\project}[2]{%
	\subsubsection*{\textbf{Projekt~#1. semester:} #2}
	%\subsubsection*{\textbf{Projekt~#1. semester:} #2}
}
% focus subsubsection
\newcommand{\focus}{%
	\subsubsection*{Fagligt fokus:}
}
%
\newlength{\myl}
\settowidth{\myl}{Fagligt foku}
%
\newenvironment{focusitem}{
	\setitemize[1]{label=-}
	Fagligt focus:
	\begin{itemize}[leftmargin=\myl]
	}
	{
	\end{itemize}
}
%
\newlength{\columnOneWidth}
\settowidth{\columnOneWidth}{Metode(r)}
\newlength{\columnTwoWidth}
\settowidth{\columnTwoWidth}{~}
\newlength{\columnThreeWidth}
\setlength{\columnThreeWidth}{\dimexpr(\textwidth-\columnOneWidth-\columnTwoWidth-2\columnTwoWidth)\relax}
%
\newenvironment{projectTable}{
	\begin{tabular}{@{} p{\columnOneWidth} @{\hspace{\columnTwoWidth}-\hspace{\columnTwoWidth}} p{\columnThreeWidth}}
}
{
	\end{tabular}
	%\par\vspace{\baselineskip}%
	\par\vspace{-5pt}%
}
%
\newenvironment{focusTable}{
	\focus
	\begin{tabular}{@{} p{\columnOneWidth} @{\hspace{\columnTwoWidth}-\hspace{\columnTwoWidth}} p{\columnThreeWidth}}
	}
	{
	\end{tabular}
	%\par\vspace{\baselineskip}%
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
