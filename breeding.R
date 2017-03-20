# northward migration

limit=-3.355408

b<-mxy %>% group_by(Animal) %>% filter(y>limit) 

b %>% group_by(Animal) %>% summarize(difftime(max(timestamp),min(timestamp),units="days"))


b %>% group_by(Animal) %>% summarize(max(timestamp))

bb<-bbox(SpatialPoints(cbind(b$x,b$y)))
ggplot(b,aes(x=x,y=y))  + geom_path(size=1.5) + borders(fill="grey90") + theme_bw() + coord_cartesian(xlim=bb[1,],ylim=bb[2,]) + mytheme + theme(panel.background= element_rect(colour = "lightblue")) +geom_point(aes(x=x,y=y),col='red',size=.4) + facet_wrap(~Animal)

mytheme<-theme(axis.text.x=element_blank(),axis.ticks.x=element_blank(),axis.text.y=element_blank(),axis.ticks.y=element_blank(),axis.title.x=element_blank(),axis.title.y=element_blank(),panel.grid=element_blank())
