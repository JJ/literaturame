
all: analyzing-repos.pdf

%.pdf: %.tex
	pdflatex $<
	bibtex $(basename $<)
	pdflatex $<
	pdflatex $<

analyzing-repos.tex: analyzing-repos.Rnw
	Rscript -e "library(knitr); knit('analyzing-repos.Rnw')"
