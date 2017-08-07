library(igraph)
library(ggplot2)
library(ggthemes)

data = read.csv("red-pedro-páramo.csv", header=TRUE)
comala.matrix <- as.matrix(data)
g = graph.edgelist(comala.matrix,directed=F)
bet.comala.df = data.frame(betweenness(g))
bet.comala.df$personajes = rownames(bet.comala.df)
bet.comala.df <- bet.comala.df[bet.comala.df$betweenness.g.> 0, ]
ggplot(bet.comala.df,aes(x=reorder(personajes,-betweenness.g.),y=betweenness.g.))+geom_point(shape=23)+ scale_y_log10()+ylab('betweenness')+theme_tufte()+geom_text(aes(label=personajes,y=betweenness.g.),hjust=0, vjust=0, nudge_x = -0.2, nudge_y = 0.1, angle=-45,size=12)+theme(axis.title.x=element_blank(), axis.text.x=element_blank())

