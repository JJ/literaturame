library(ggplot2)
library(dplyr)

words.granada <- read.csv('../data/books/words-granada-off.csv')
words.nyc <- read.csv('../data/books/words-nyc-42-8.csv')
words.hoborg <- read.csv('../data/books/words-hoborg.csv')

words.granada$rel <- words.granada$Words/last(words.granada$Words)
words.nyc$rel <- words.nyc$Words/last(words.nyc$Words)
words.hoborg$rel <- words.hoborg$Words/last(words.hoborg$Words)

words.granada$idx <- words.granada$Commit/last(words.granada$Commit)
words.nyc$idx <- words.nyc$Commit/last(words.nyc$Commit)
words.hoborg$idx <- words.hoborg$Commit/last(words.hoborg$Commit)

ggplot()+geom_line(data=words.granada,aes(x=idx,y=rel,col='Granada On'))+geom_line(data=words.nyc,aes(x=idx,y=rel,col='Esquina'))+geom_line(data=words.hoborg,aes(x=idx,y=rel,col='Manuel'))
