R -e 'library(knitr);knit("analyzing-repos.Rnw")'
pdflatex analyzing-repos
bibtex analyzing-repos
pdflatex analyzing-repos
