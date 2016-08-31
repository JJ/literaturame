 ## ----setup, include=FALSE------------------------------------------------
library(ggplot2)
library("ggfortify")
library(dplyr)
library(TTR)
library(plotly)
#use 
file <- "../data/books/words-hashslash.csv"
# for testing here
deltas <- read.csv(file) # File should be established from an R script
words <- deltas[-1,]
words$Delta <- abs(words$Delta)
words$SMA5 <- SMA(words$Delta,n=5)
words$SMA10 <- SMA(words$Delta,n=10)

## ----summary-------------------------------------------------------------
summary(words)

## ----timeline, echo=FALSE------------------------------------------------
gg.words = ggplot(words)
gg.words+geom_point(aes(x=Commit,y=Delta))
gg.words+geom_line(aes(x=Commit,y=Delta,group=1))
gg.words+geom_point(aes(x=Commit,y=Delta))+scale_y_log10()
gg.changes <- gg.words+geom_line(aes(x=Commit,y=Delta,group=1))+scale_y_log10()
gg.changes
ggsave('hashslash-word-changes.png',width=3,height=1.75)

## ----smoothie, echo=FALSE------------------------------------------------
gg.words+geom_line(aes(x=Commit,y=SMA5,color='SMA5'))+geom_line(aes(x=Commit,y=SMA10,color='SMA10'))+scale_y_log10()

## ----linecount, echo=FALSE-----------------------------------------------
by.words <- group_by(words,Delta)
words.count <- summarize(by.words, count=n())
pl.plot <- ggplot(words.count, aes(x=Delta, y=count))+stat_smooth()+geom_point()+scale_x_log10()+scale_y_log10()
(pl.ly <- ggplotly(pl.plot))

## ----powerlaw, echo=FALSE------------------------------------------------
ggplot(data=words, aes(words$Delta)) + geom_histogram(bins=100)+scale_x_log10()
sorted.words <- data.frame(x=1:length(words$Delta),Delta=as.numeric(words[order(-words$Delta),]$Delta))
ggplot()+geom_point(data=sorted.words,aes(x=x,y=Delta))
ggplot()+geom_point(data=sorted.words,aes(x=x,y=Delta))+scale_y_log10()
sorted.words.no0 <- sorted.words[sorted.words$Delta>0,]
zipf.fit <- lm(log(sorted.words.no0$Delta) ~ sorted.words.no0$x)
zipf.plot <- ggplot(sorted.words,aes(x=x,y=Delta)) +geom_point()+scale_y_log10()
(zp.ly <- ggplotly(zipf.plot))


## ----autocorrelation, echo=FALSE-----------------------------------------
autoplot(pacf(words$Delta, plot=FALSE) )
ggsave('hashslash-partial-acf.png',width=3,height=1.75)



## ----spectrum, echo=FALSE------------------------------------------------
autoplot(spectrum(words$Delta, plot=FALSE) )+geom_smooth()
ggsave('hashslash-power-spectrum.png',width=4,height=3)

