
library(ggplot2)
library(chron)
library(dplyr)

dat<-read.csv("C:/Users/Ben/Desktop/131136/131136/131136-Behavior.csv")
dat$timestamp<-as.POSIXct(dat$Start,format="%H:%M:%S %d-%b-%Y")
dat$Month<-months(dat$timestamp)
dat$Hour<-strftime(dat$timestamp,format="%H")

dive<-dat[dat$What=="Dive",]

#dive depth and time
ggplot(dive,aes(x=timestamp,y=DepthMax)) + geom_point() + geom_smooth() + scale_x_datetime(date_breaks = "1 week") + scale_y_reverse()
ggsave("Figures/Depth_Time.jpg",height=5,width=5)

#dive data and dutation, colored by month
ggplot(data=dive,aes(x=DurationMax, y=DepthMax,col=Month)) + geom_point() + theme_bw()

#average depth over time
dive %>% group_by(Month) %>% summarize(mean(DepthMax))

#timestamp
ggplot(data=dive,aes(x=Hour,y=DepthMax)) + geom_point() + geom_smooth() + scale_y_reverse() + facet_wrap(~Month)
