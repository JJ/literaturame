## ----setup, include=FALSE------------------------------------------------
library(ggplot2)
library("ggfortify")
library(dplyr)
library(TTR)
#use 
file <- '/home/jmerelo/proyectos/literaturame/data/software/lines_catalyst-runtime_ALL_p[ml]_ALL_ALL_p[ml]_ALL_ALL_t_ALL_ALL_ALL_t_ALL_ALL_ALL_ALL_t_ALL_ALL_ALL_pm_ALL_ALL_ALL_ALL_pm_ALL_ALL_ALL_ALL_ALL_pm.csv'
# for testing here
lines <- read.csv(file) # File should be established from an R script
lines$SMA5 <- SMA(lines$Lines.changed,n=5)
lines$SMA10 <- SMA(lines$Lines.changed,n=10)

## ----summary-------------------------------------------------------------
summary(lines)

## ----timeline, echo=FALSE------------------------------------------------
lines$x = as.numeric(row.names(lines))
gg.lines = ggplot(lines)
gg.lines+geom_point(aes(x=x,y=Lines.changed))
gg.lines+geom_line(aes(x=x,y=Lines.changed,group=1))
gg.lines+geom_point(aes(x=x,y=Lines.changed))+scale_y_log10()
gg.lines+geom_line(aes(x=x,y=Lines.changed,group=1))+scale_y_log10()

## ----smoothie, echo=FALSE------------------------------------------------
gg.lines+geom_line(aes(x=x,y=SMA5,color='SMA5'))+geom_line(aes(x=x,y=SMA10,color='SMA10'))+scale_y_log10()

## ----linecount, echo=FALSE-----------------------------------------------
by.lines <- group_by(lines,Lines.changed)
lines.count <- summarize(by.lines, count=n())
sizes.fit <- lm(log(1+lines.count$Lines.changed) ~ log(lines.count$count))
print(sizes.fit)
ggplot(lines.count, aes(x=Lines.changed, y=count))+geom_point()+scale_x_log10()+scale_y_log10()+stat_smooth()
ggsave('catalyst-sizes-log.png',width=3,height=2.5)
## ----powerlaw, echo=FALSE------------------------------------------------
ggplot(data=lines, aes(lines$Lines.changed)) + geom_histogram(bins=100)+scale_x_log10()
sorted.lines <- data.frame(x=1:length(lines$Lines.changed),Lines.changed=as.numeric(lines[order(-lines$Lines.changed),]$Lines.changed))
ggplot()+geom_point(data=sorted.lines,aes(x=x,y=Lines.changed))
ggplot()+geom_point(data=sorted.lines,aes(x=x,y=Lines.changed))+scale_y_log10()
sorted.lines.no0 <- sorted.lines[sorted.lines$Lines.changed>0,]
zipf.fit <- lm(log(sorted.lines.no0$Lines.changed) ~ sorted.lines.no0$x)

## ----autocorrelation, echo=FALSE-----------------------------------------
autoplot(pacf(lines$Lines.changed, plot=FALSE) )
ggsave('catalyst-acf.png',width=3,height=2.5)
## ----spectrum, echo=FALSE------------------------------------------------
autoplot(spectrum(lines$Lines.changed, plot=FALSE) )
ggsave('catalyst-pink.png',width=3,height=2.5)
