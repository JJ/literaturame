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
data.files <- c('../data/books/lines_curso-git_texto_ALL_md.csv',
'../data/books/lines_granada-off_text_ALL_md.csv',
'../data/books/lines_HashSlash_texto_HashSlash_md.csv',
'../data/books/lines_hoborg_text_text_md.csv',
'../data/books/lines_nyc-42-8_text_nyc-42-8_md.csv',
'../data/papers/lines_2015_books_paper_tex.csv',
'../data/papers/lines_2016-ea-languages-PPSN_ea-languages_Rnw.csv',
'../data/software/lines_Algorithm-Evolutionary_ALL_PL_ALL_ALL_pm_ALL_ALL_ALL_pm_ALL_ALL_ALL_ALL_pm_ALL_ALL_t.csv',
'../data/software/lines_Algorithm-Evolutionary_lib_Algorithm_ALL_pm_lib_Algorithm_Evolutionary_ALL_pm_lib_Algorithm_Evolutionary_ALL_ALL_pm.csv',
'../data/software/lines_nodeo_lib_ALL_js_lib_nodeo_ALL_js_lib_nodeo_ALL_ALL_js.csv',
'../data/software/lines_nqp_src_ALL_ALL_nqp.csv',
'../data/software/lines_polleitor_ALL_js_app_ALL_js_public_ALL_html_public_js_ALL_js_test_ALL_js.csv',
'../data/software/lines_tweepy_ALL_py_ALL_ALL_py_ALL_ALL_ALL_py.csv')

# for each file create a report
# these reports are saved in output_dir with the name specified by output_file

for (file in data.files){
    print(file)
    report.file <- gsub('lines','report',file)
    report.file <- gsub('csv','pdf',report.file)
    report.file <- gsub('../data','.',report.file)
    print(report.file)
    rmarkdown::render(input = 'creativity.Rmd', 
                      output_format = "pdf_document",
                      output_file = report.file,
                      output_dir = '.')
}

