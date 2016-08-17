library(ggplot2)

words <- read.csv("../data/books/words-nyc-42-8.csv")
words.less1 <- words[-1,]
gg.words <- ggplot(words.less1)
