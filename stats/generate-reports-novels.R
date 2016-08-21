# References for automation 
# http://www.r-bloggers.com/how-to-source-an-r-script-automatically-on-a-mac-using-automator-and-ical/
# http://www.engadget.com/2013/03/18/triggering-applescripts-from-calendar-alerts-in-mountain-lion/

# File 1: Should be an R-Script 
    # contains a loop that iteratively calls an Rmarkdown file (i.e. File 2)

# load packages
library(knitr)
library(markdown)
library(rmarkdown)

# use first 5 rows of mtcars as example data
data.files <- c( '../data/books/words-nyc-42-8.csv',
                '../data/books/words-granada-off.csv',
                '../data/books/words-hoborg.csv',
                '../data/books/words-hashlash.csv')

# for each file create a report
# these reports are saved in output_dir with the name specified by output_file

for (file in data.files){
    print(file)
    report.file <- gsub('words','report',file)
    report.file <- gsub('csv','pdf',report.file)
    report.file <- gsub('../data','.',report.file)
    print(report.file)
    rmarkdown::render(input = 'creativity-novels.Rmd', 
                      output_format = "pdf_document",
                      output_file = report.file,
                      output_dir = '.')
}

