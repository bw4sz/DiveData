#Download ice
#test case
library(raster)
library(curl)
library(rgdal)
library(gdalUtils)
library(dplyr)

#Build registry
baseurl<-'http://www.iup.uni-bremen.de:8084/amsr2data/asi_daygrid_swath/s3125'

#sample raster for coordinates
r<-raster("Data/sampleAMSR2.tif")

#coordinate frame
proj_string<-projection(r)

#Date range
#mk10 data
mdat<-read.csv("Data/Humpback Whales Megaptera novaeangliae West Antarctic Peninsula-3343066988628153526.csv")

#unique days
#set datestamp
mdat$timestamp<-as.POSIXct(mdat$timestamp,format="%Y-%m-%d %H:%M:%S.000")
udays<-unique(strptime(mdat$timestamp,format="%Y-%m-%d",tz="GMT"))

region='AntarcticPeninsula'

#for each of these unique days, get the sea ice data 
for (x in 1:length(udays)){
  datep<-udays[x]
  #split into components
  mn<-format(datep,format="%m")
  
  #month abbreciation
  mnabb<-tolower(month.abb[as.numeric(mn)])
  
  day<-format(datep,format="%d")
  year<-format(datep,format="%Y")
  fl<-paste('asi-AMSR2-s3125-',year,mn,day,".hdf",sep="")
  
  #look up month day format
  full_url<-paste(baseurl,year,mnabb,region,fl,sep="/")
  filname<-paste("C:/Users/Ben/Dropbox/Whales/AMSR2",year,mnabb,region,fl,sep="/")
  
  #create directory if needed
  dir_check<-paste("C:/Users/Ben/Dropbox/Whales/AMSR2",year,mnabb,region,sep="/")
  if(!dir.exists(dir_check)){
    dir.create(dir_check,recursive=T)
  }
  
  tryCatch(
    {
    curl_download(url=full_url,destfile=filname)
    #create gdal version
    flnc<-paste('asi-AMSR2-s3125-',year,mn,day,'.nc',sep="")
    newfl<-paste("C:/Users/Ben/Dropbox/Whales/AMSR2",year,mnabb,region,flnc,sep="/")
    
    #netcdf transfer
    gdal_translate(filname,newfl,sds=T)
    
    #read in 
    s<-raster(readGDAL(newfl))
    
    #assign coords
    proj4string(s) <- proj4string(r)
    extent(s) <- extent(r)
    
    #assign coordinates
    s<-flip(s,direction="y")

    fl_final<-paste('asi-AMSR2-s3125-',year,mn,day,'.grd',sep="")
    savefile<-paste("C:/Users/Ben/Dropbox/Whales/AMSR2",year,mnabb,region,fl_final,sep="/")
    writeRaster(s,savefile)
    
    #remove hdf and nc
    file.remove(filname)
    file.remove(newfl)
    
    }, error=function(e) {
      print("no hdf found")
      return(NA) 
    })
  }


## Get the 10 day interval within all ice day observations
daysec = 60*60*24

newdays<-list()
for (x in 1:10){
  newdays[[x]]<-udays + (x * daysec)
}

#bind and get unique set
newdays<-unique(do.call("c",newdays))
#for soem reason that resets the time zone
newdays<-unique(strptime(newdays,format="%Y-%m-%d",tz="GMT"))

#remove days that were already in the original download
newdays<-newdays[!newdays %in% udays]

#download those newdays
#for each of these unique days, get the sea ice data 
for (x in 1:length(newdays)){
  datep<-newdays[x]
  #split into components
  mn<-format(datep,format="%m")
  
  #month abbreciation
  mnabb<-tolower(month.abb[as.numeric(mn)])
  
  day<-format(datep,format="%d")
  year<-format(datep,format="%Y")
  fl<-paste('asi-AMSR2-s3125-',year,mn,day,".hdf",sep="")
  
  #look up month day format
  full_url<-paste(baseurl,year,mnabb,region,fl,sep="/")
  filname<-paste("C:/Users/Ben/Dropbox/Whales/AMSR2",year,mnabb,region,fl,sep="/")
  
  #create directory if needed
  dir_check<-paste("C:/Users/Ben/Dropbox/Whales/AMSR2",year,mnabb,region,sep="/")
  if(!dir.exists(dir_check)){
    dir.create(dir_check,recursive=T)
  }
  
  tryCatch(
    {
      curl_download(url=full_url,destfile=filname)
      #create gdal version
      flnc<-paste('asi-AMSR2-s3125-',year,mn,day,'.nc',sep="")
      newfl<-paste("C:/Users/Ben/Dropbox/Whales/AMSR2",year,mnabb,region,flnc,sep="/")
      
      #netcdf transfer
      gdal_translate(filname,newfl,sds=T)
      
      #read in 
      s<-raster(readGDAL(newfl))
      
      #assign coords
      proj4string(s) <- proj4string(r)
      extent(s) <- extent(r)
      
      #assign coordinates
      s<-flip(s,direction="y")
      
      fl_final<-paste('asi-AMSR2-s3125-',year,mn,day,'.grd',sep="")
      savefile<-paste("C:/Users/Ben/Dropbox/Whales/AMSR2",year,mnabb,region,fl_final,sep="/")
      writeRaster(s,savefile)
      
      #remove hdf and nc
      file.remove(filname)
      file.remove(newfl)
      
    }, error=function(e) {
      print("no hdf found")
      return(NA) 
    })
}
