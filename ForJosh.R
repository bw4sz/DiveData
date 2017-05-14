#For Josh 
library(moveHMM)
#read data
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
mxy<-mxy[!mxy$argos.lc %in% c("Z","A","B"),]

#crop by extent
d<-SpatialPointsDataFrame(cbind(mxy$x,mxy$y),data=mxy,proj4string=CRS("+proj=longlat +datum=WGS84"))

#set datestamp
mxy$timestamp<-as.POSIXct(mxy$timestamp,format="%Y-%m-%d %H:%M:%S.000")

#month and year columns
mxy$Month<-months(mxy$timestamp)
mxy$Year<-years(mxy$timestamp)

#overlay data
mxy<-mxy %>% filter(Year==2015,Month %in% c("January","February","March","April","May","June"),location.long> -64.5,location.long < -64,location.lat < -64.7,location.lat > -65.5 ) %>% arrange(Animal,timestamp) %>% select(Animal,x,y)
mxy$ID<-as.factor(mxy$Animal)
mxy$Animal<-NULL
md<-prepData(mxy,type="LL",coordNames=c("x","y"))

## initial parameters for gamma and von Mises distributions
mu0 <- c(0.1,1) # step mean (two parameters: one for each state)
sigma0 <- c(0.1,1) # step SD
zeromass0 <- c(0.1,0.05) # step zero-mass
stepPar0 <- c(mu0,sigma0,zeromass0)
angleMean0 <- c(pi,0) # angle mean
kappa0 <- c(1,1) # angle concentration
anglePar0 <- c(angleMean0,kappa0)
## call to fitting function
m <- fitHMM(data=data,nbStates=2,stepPar0=stepPar0,
            anglePar0=anglePar0,formula=~1)

plot(m)

states <- viterbi(m)

