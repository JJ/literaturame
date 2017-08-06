library(igraph)
library(ggplot2)
library(ggthemes)

data = read.csv("red-pedro-páramo.csv", header=TRUE)
comala.matrix <- as.matrix(data)
g = graph.edgelist(comala.matrix,directed=F)
bet.comala.df = data.frame(betweenness(g))
bet.comala.df$personajes = rownames(bet.comala.df)
bet.comala.df <- bet.comala.df[bet.comala.df$betweenness.g.> 0, ]
ggplot()+geom_point(data=bet.comala.df,aes(x=reorder(personajes,-betweenness.g.),y=betweenness.g.))+scale_y_log10()+theme_tufte()+ theme(axis.text.x = element_text(size=25,angle = 90, hjust = 1))

