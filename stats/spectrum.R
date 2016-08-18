library(ggplot2)

words <- read.csv("../data/books/words-nyc-42-8.csv")
words.less1 <- words[-1,]
gg.words <- ggplot(words.less1)

trend <- lm( words.less1$Delta ~ words.less1$Commit )
gg.words+geom_line(aes(x=Commit,y=Delta))
