## ----setup, cache=FALSE,echo=FALSE,warning=FALSE,message=FALSE-----------
library(ggplot2)
library("ggfortify")
library(ggthemes)
library(dplyr)
library(TTR)
library(xtable)
                                        #use 
pref <- '../data/software/lines_'
files <- c('ejabberd_3-erl hrl yrl escript ex exs','tensorflow_2-py cc h',
           'mojo_2-pl pm PL','tty_2-rb','cask_5-el py','webpack_2-js','language-perl6fe_4-coffee p6',
           'tpot_5-py','scalatra_2-scala','Moose_2-pl pm xs t','django_8-py','docker_2-go',
           'fission_4-go py js','vue_2-js','Dancer2_2-pl pm t','rakudo_4-pm pm6 pl pl6 nqp')

urls <- c('processone/ejabberd','tensorflow/tensorflow',
          'kraih/mojo','piotrmurach/tty','cask/cask','webpack/webpack','perl6/atom-language-perl6',
          'rhiever/tpot','scalatra/scalatra','moose/Moose','django/django','docker/docker',
          'fission/fission','vuejs/vue','PerlDancer/Dancer2','rakudo/rakudo')

languages <- c('erlang','Python','Perl','Ruby','Emacs Lisp','JavaScript',
               'CoffeeScript','Python','Scala','Perl','Python','Go','Go','JavaScript','Perl','Perl')

age <-  data.frame(Name = character(),
                   file = character(),
                   language = character(),
                   age = integer(),
                   Median = double(),
                   Mean = double(),
                   SD = double())
url.list <- list()
for (i in 1:length(files) ) {
    file.name = paste0(pref,files[i],'.csv')
    these.lines <-  read.csv(file.name)
    url.list[[file.name]] <- urls[i]
    age <- rbind( age,
                 data.frame(Name = urls[i],
                            file = file.name,
                            language = languages[i],
                            age = length(these.lines$Lines.changed),
                            Median =  as.double(median(these.lines$Lines.changed)),
                            Mean = as.double(mean(these.lines$Lines.changed)),
                            SD = as.double(sd(these.lines$Lines.changed) )))
}
summary <- age[order(age$age),]
lines <- list()
# Read again in order because I am useless in R
for (i in 1:length(summary$file) ) {
    lines[[i]] <-  read.csv(as.character(summary[[i,'file']]))
    lines[[i]]$url <- url.list[[summary[[i,'file']]]]
    lines[[i]]$SMA10 <- SMA(lines[[i]]$Lines.changed,n=10)
    lines[[i]]$SMA20 <- SMA(lines[[i]]$Lines.changed,n=20)
}

## ----linecount,message=FALSE, fig.subcap=summary$Name, echo=FALSE,warning=FALSE,fig.height=4,out.width='.245\\linewidth'----
sizes.fit.df <- data.frame(Name = character(),
                           Coefficient = double(),
                           Intercept = double())
for (i in 1:length(lines) ) {
    by.lines <- group_by(lines[[i]],Lines.changed)
    lines.count <- summarize(by.lines, count=n())
    sizes.fit <- lm(log(1+lines.count$Lines.changed) ~ log(lines.count$count))
    repo <- strsplit(paste(summary[[1]][i],""),"_",fixed=T)
    sizes.fit.df <- rbind( sizes.fit.df,
                          data.frame( Name = repo[[1]][1],
                                     Intercept = summary(sizes.fit)$coefficients[1],
                                     Coefficient = summary(sizes.fit)$coefficients[2] ))
    ggplot(lines.count, aes(x=Lines.changed, y=count))+geom_point()+scale_x_log10()+scale_y_log10()+stat_smooth() + theme(legend.position="none",axis.title.x=element_blank(),axis.title.y=element_blank()) + ggtitle(lines[[i]]$url)
    lines[[i]]$repo = gsub("/","_",trimws(repo[[1]][1]))
    ggsave(paste0("figure/ecal2017-linecount-",lines[[i]]$repo,".png"),device='png')
}


## ----powerlaw,message=FALSE, fig.subcap=summary$Name,echo=FALSE,warning=FALSE,fig.height=4,out.width='.115\\linewidth'----
zipf.fit.df <- data.frame(Name = character(),
                          Coefficient = double(),
                          Intercept = double())
for (i in 1:length(lines) ) {
    sorted.lines <- data.frame(x=1:length(lines[[i]]$Lines.changed),Lines.changed=as.numeric(lines[[i]][order(-lines[[i]]$Lines.changed),]$Lines.changed))
    ggplot()+geom_point(data=sorted.lines,aes(x=x,y=Lines.changed))+scale_y_log10()
    ggsave(paste0("figure/ecal2017-powerlaw-",lines[[i]]$repo,".png"),device='png')
    sorted.lines.no0 <- sorted.lines[sorted.lines$Lines.changed>0,]
    repo <- strsplit(paste(summary[[1]][i],""),"_")
    zipf.fit <- lm(log(sorted.lines.no0$Lines.changed) ~ sorted.lines.no0$x)
    zipf.fit.df <- rbind( zipf.fit.df,
                         data.frame( Name = repo[[1]][1],
                                    Intercept = summary(zipf.fit)$coefficients[1],
                                    Coefficient = summary(zipf.fit)$coefficients[2] ))
}

## ----autocorrelation,message=FALSE, cache=FALSE,echo=FALSE,fig.height=4,fig.subcap=summary$Name,out.width='.115\\linewidth'----
for (i in 1:length(lines) ) {
    autoplot(pacf(lines[[i]]$Lines.changed, plot=FALSE) )
    ggsave(paste0("figure/ecal2017-auto-",lines[[i]]$repo,".png"),device='png')
}

## ----spectrum,message=FALSE, cache=FALSE,echo=FALSE,fig.height=4,fig.subcap=summary$Name,out.width='.245\\linewidth'----
spec.fit.df <- data.frame(Name = character(),
                          Coefficient = double(),
                          p = double())
for (i in 1:length(lines) ) {
    this.spectrum <- spectrum(lines[[i]]$Lines.changed, plot=FALSE)
    autoplot( this.spectrum ) + scale_x_log10() + theme(legend.position="none",axis.title.x=element_blank(),axis.title.y=element_blank()) + ggtitle(lines[[i]]$url)
    ggsave(paste0("figure/ecal2017-pinknoise-",lines[[i]]$repo,".png"),device='png')
    spec.fit <- lm(log(this.spectrum$spec) ~ log(this.spectrum$freq**2))
    repo <- strsplit(paste(summary[[1]][i],""),"_")
    f <- summary(spec.fit)$fstatistic
    p <- pf(f[1],f[2],f[3],lower.tail=F)
    attributes(p) <- NULL
    spec.fit.df <- rbind( spec.fit.df,
                         data.frame( Name = repo[[1]][1],
                                    p = p,
                                    Coefficient = summary(spec.fit)$coefficients[2] ))
}



