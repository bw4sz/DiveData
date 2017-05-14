# First passage time

```{r}
mdat<-read.csv("C:/Users/Ben/Documents/DiveData/Data/Humpback Whales Megaptera novaeangliae West Antarctic Peninsula-3343066988628153526.csv")

#standardize column names to match the simulation
#Create an animal tag.
mxy <- as(mdat, "data.frame")
mxy$Animal<-mxy$individual.local.identifier
mxy$x<-mxy$location.long
mxy$y<-mxy$location.lat

mxy$argos.lc<-mxy$argos.iq
mxy$argos.iq<-NULL
#grab set of animals
#mxy<-mxy[mxy$Animal %in% c("131143","131142","123232","123236"),]

#get rid of z class 
mxy<-mxy[!mxy$argos.lc %in% c("Z"),]

#crop by extent
d<-SpatialPointsDataFrame(cbind(mxy$x,mxy$y),data=mxy,proj4string=CRS("+proj=longlat +datum=WGS84"))

#set datestamp
mxy$timestamp<-as.POSIXct(mxy$timestamp,format="%Y-%m-%d %H:%M:%S.000")

#month and year columns
mxy$Month<-months(mxy$timestamp)
mxy$Year<-years(mxy$timestamp)

#remove duplicates
#mxy<-mxy[!duplicated(data.frame(mxy$timestamp,mxy$Animal)),]


#overlay data
mxy<-mxy %>% filter(Year==2015,Month %in% c("January","February","March","April","May","June"),location.long> -64.5,location.long < -64,location.lat < -64.7,location.lat > -65.5 ) %>% arrange(Animal,timestamp) 
```

```{r}
#get a sample raster
r<-raster("C:\\Users\\Ben\\Dropbox\\Whales\\AMSR2\\2016\\may\\AntarcticPeninsula\\asi-AMSR2-s3125-20160531.grd")

#get points in projection
longlat<-SpatialPoints(cbind(mxy$location.long,mxy$location.lat),proj4string=CRS("+proj=longlat +datum=WGS84"))
#long lat
polarstereo<-spTransform(x=longlat,CRSobj=crs(r))
mxy[,c("stereo.x","stereo.y")]<-coordinates(polarstereo)
```

```{r}
tr<-as.ltraj(xy=mxy[,c("stereo.x","stereo.y")],id=as.character(mxy$Animal),date=mxy$timestamp,typeII=T)
tr<-rec(tr)
i<-fpt(tr,radii=seq(500,10000,500),units="hours")
plot(i,scale=1000)
```

## Associate with specific points
```{r}
out<-list()
for(x in 1:length(i)){
  colnames(i[[x]])<-seq(500,10000,500)
  j<-as.data.frame(i[[x]])
  j$ID<-rownames(i[[x]])
  out[[x]]<-j
}
names(out)<-unique(mxy$Animal)
out<-melt(out,id.vars = c("Animal","ID"))
colnames(out)<-c("radius","fpt","Animal")

f500<-out %>% filter(radius == 5000)

```

```{r}
meanfpt(i)
#variance in passage time
vi<-varlogfpt(i,graph=T)
colnames(vi)<-seq(500,10000,500)
vi<-as.data.frame(vi)
vi$Animal<-rownames(vi)
mvi<-melt(vi)
mvi$variable<-as.numeric(as.character(mvi$variable))/1000

ggplot(data=mvi,aes(x=variable,y=value)) + geom_line(aes(group=Animal)) + geom_point(size=0.5) + geom_smooth() + theme_bw() + labs(x="Scale(km)",y="First Passage Time (Hours)")
```

For the full dataset

```{r}
#read data
mdat<-read.csv("Data/Humpback Whales Megaptera novaeangliae West Antarctic Peninsula-3343066988628153526.csv")
#standardize column names to match the simulation
#Create an animal tag.
mxy <- as(mdat, "data.frame")
mxy$Animal<-mxy$individual.local.identifier
mxy$x<-mxy$location.long
mxy$y<-mxy$location.lat

mxy$argos.lc<-mxy$argos.iq
mxy$argos.iq<-NULL

#grab set of animals
#mxy<-mxy[mxy$Animal %in% c("131143","131142","123232","123236"),]

#get rid of z class 
mxy<-mxy[!mxy$argos.lc %in% c("B","Z"),]

#crop by extent
d<-SpatialPointsDataFrame(cbind(mxy$x,mxy$y),data=mxy,proj4string=CRS("+proj=longlat +datum=WGS84"))

cropoly<-readShapePoly("Data/CutPolygon.shp",proj4string=CRS("+proj=longlat +datum=WGS84"))

b<-d[!is.na(d %over% cropoly)[,2],]

mxy<-b@data

#set datestamp
mxy$timestamp<-as.POSIXct(mxy$timestamp,format="%Y-%m-%d %H:%M:%S.000",tz="GMT")

#month and year columns
mxy$Month<-months(mxy$timestamp)
mxy$Year<-years(mxy$timestamp)

#remove migration events, create user cut polygon
migration<-data.frame(Animal=c("121207","121210","123224","131130","123236","123232","112699","131127","121208","131136","131132","131133"),timestamp=c("2013-05-07 12:16:26","2013-04-30 02:01:51","2013-05-23 01:23:55","2016-04-27 00:53:21","2013-03-16 05:35:06","2013-04-25 05:09:21","2012-06-15 03:28:15","2016-07-15 00:02:46","2013-02-12 00:51:28","2016-06-30 00:18:11","2016-05-09 03:57:47","2016-07-05 13:26:44"))
migration$timestamp<-as.POSIXct(migration$timestamp,format="%Y-%m-%d %H:%M:%S")

#mxy %>% group_by(Animal) %>% summarize(max(timestamp,na.rm=T)) %>% filter(Animal %in% migration$Animal)

for(x in 1:nrow(migration)){
  toremove<-which(mxy$Animal %in% migration$Animal[x] & mxy$timestamp > migration$timestamp[x])
  mxy<-mxy[!(1:nrow(mxy) %in% toremove),]
}           

#Only austral sping and summer, not enough data for june and july
#mxy<-mxy[mxy$Month %in% month.name[1:6],]

#remove empty timestamps
mxy<-mxy[!is.na(mxy$timestamp),]

#remove duplicates
mxy<-mxy[!duplicated(data.frame(mxy$timestamp,mxy$Animal)),]
```

```{r}
#get a sample raster
r<-raster("C:\\Users\\Ben\\Dropbox\\Whales\\AMSR2\\2016\\may\\AntarcticPeninsula\\asi-AMSR2-s3125-20160531.grd")

#get points in projection
longlat<-SpatialPoints(cbind(mxy$location.long,mxy$location.lat),proj4string=CRS("+proj=longlat +datum=WGS84"))
#long lat
polarstereo<-spTransform(x=longlat,CRSobj=crs(r))
mxy[,c("stereo.x","stereo.y")]<-coordinates(polarstereo)
```

```{r}
tr<-as.ltraj(xy=mxy[,c("stereo.x","stereo.y")],id=as.character(mxy$Animal),date=mxy$timestamp,typeII=T)
tr<-rec(tr)
i<-fpt(tr,radii=seq(1000,30000,1000),units="hours")
plot(i,scale=1000)
```

```{r}
#variance in passage time
vi<-varlogfpt(i,graph=F)
colnames(vi)<-seq(1000,30000,1000)
vi<-as.data.frame(vi)
vi$Animal<-rownames(vi)
mvi<-melt(vi)
mvi$variable<-as.numeric(as.character(mvi$variable))/1000

ggplot(data=mvi,aes(x=variable,y=value)) + geom_line(aes(group=Animal)) + geom_point(size=0.5) + geom_smooth() + theme_bw() + labs(x="Scale(km)",y="First Passage Time (Hours)")
```
