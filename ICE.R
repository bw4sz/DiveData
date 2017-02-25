####### ICE (AMSR-E and AMSR-2) #########
#http://www.iup.uni-bremen.de:8084/amsredata/asi_daygrid_swath/l1a/s3125/grid_coordinates/LongitudeLatitudeGrid-s3125-AntarcticPeninsula.hdf

#Download and import Ross Sea 3.125km polar stereographic grid cell locations 
#download.file(url=paste("http://www.iup.uni-bremen.de:8084/amsredata/asi_daygrid_swath/l1a/s3125/",
#                        "grid_coordinates/LongitudeLatitudeGrid-s3125-AntarcticPeninsula.hdf",sep=""), 
#              destfile=paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
#                             "LongitudeLatitudeGrid-s3125-AntarcticPeninsula.hdf",sep=""),mode="wb")

#Translate hdf4 format into ncdf (creates two .nc files based on two scientific data sets SDS, e.g. Lat,Long)
#library(gdalUtils)
#gdal_translate(paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
#                     "LongitudeLatitudeGrid-s3125-AntarcticPeninsula.hdf",sep=""),
#               paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
#                     "LongitudeLatitudeGrid-s3125-AntarcticPeninsula.nc",sep=""),sds=TRUE)

#Import Lat and Long coordinates of 800x800 cell grid (these are not regularly spaced geographically because of polar stereographic projection)
ICE_COORD_LONG=raster(readGDAL(paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                                     "LongitudeLatitudeGrid-s3125-AntarcticPeninsula_1.nc",sep="")))
ICE_COORD_LAT=raster(readGDAL(paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                                    "LongitudeLatitudeGrid-s3125-AntarcticPeninsula_2.nc",sep="")))


#Initialize the ICE loop by downloading the asi-AMSR2 .hdf file for the first day in DATES
#http://www.iup.uni-bremen.de/seaice/amsredata/asi_daygrid_swath/l1a/s3125/2010/feb/AntarcticPeninsula/asi-s3125-20100201.hdf
#http://www.iup.uni-bremen.de/seaice/amsredata/asi_daygrid_swath/l1a/s3125/2009/dec/AntarcticPeninsula/asi-s3125-20091201.hdf
#http://www.iup.uni-bremen.de:8084/amsr2data/asi_daygrid_swath/s3125/2016/jan/AntarcticPeninsula/asi-AMSR2-s3125-20160101.hdf
#http://www.iup.uni-bremen.de:8084/amsr2data/asi_daygrid_swath/s3125/2013/jan/AntarcticPeninsula/asi-AMSR2-s3125-20130101.hdf
#http://www.iup.uni-bremen.de:8084/amsr2data/asi_daygrid_swath/s3125/2012/dec/AntarcticPeninsula/asi-AMSR2-s3125-20121201.hdf

download.file(url=paste("http://www.iup.uni-bremen.de/seaice/amsredata/asi_daygrid_swath/l1a/s3125/",
                        DATES$YEAR[1],"/",DATES$MONTH_LONG[1],"/","AntarcticPeninsula",
                        "/asi-s3125-",DATES$YEAR[1],DATES$MONTH[1],DATES$DAY[1],".hdf",sep=""), 
              destfile=paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                             "asi-s3125-",DATES$YEAR[1],DATES$MONTH[1],DATES$DAY[1],".hdf",sep=""),mode="wb")

#Translate asi-AMSR2 .hdf file into NetCDF format which can be read as a raster
gdal_translate(paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                     "asi-s3125-",DATES$YEAR[1],DATES$MONTH[1],DATES$DAY[1],".hdf",sep=""),
               paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                     "asi-s3125-",DATES$YEAR[1],DATES$MONTH[1],DATES$DAY[1],".nc",sep=""),
               sds=TRUE)

#Import asi-AMSR2 NetCDF file for DATES$DATE[1] as a raster
ICE_temp=raster(readGDAL(paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                               "asi-s3125-",DATES$YEAR[1],DATES$MONTH[1],DATES$DAY[1],".nc",sep="")))

#Transform ICE_temp raster into SpatialPointsDataFrame by matching each ICE_temp CONCENTRATION 
#reading with it's LAT and LONG coordinates from the LongitudeLatitudeGrid file provided for the region
ICE_temp=data.frame(ICE_CONCENTRATION=as.numeric(as.matrix(ICE_temp)),
                    LONG=as.numeric(as.matrix(ICE_COORD_LONG)),
                    LAT=as.numeric(as.matrix(ICE_COORD_LAT)))
#Transform LONG coordinates from -180:180 to 0:360 to match ARGOS and BATHY
ICE_temp$LONG=ifelse(ICE_temp$LONG>0,ICE_temp$LONG,360+ICE_temp$LONG)
#Create SpatialPointsDataFrame
coordinates(ICE_temp)=~LONG+LAT

#Rasterize (i.e., sample points within a defined grid) from ICE_temp SpatialPointsDataFrame to create a raster
#in a geographic latlong WGS84 projection by calculating the mean of all values falling within each grid cell
#Note: resolution somewhat reduced from original 800x800 to minimize gaps caused by resampling an uneven grid of points
ICE_temp=rasterize(x=ICE_temp,
                   y=raster(ncols=750, nrows=750,
                            extent(floor(min(ICE_temp$LONG)),ceiling(max(ICE_temp$LONG)),
                                   floor(min(ICE_temp$LAT)),ceiling(max(ICE_temp$LAT)))),
                   field=ICE_temp$ICE_CONCENTRATION,fun=mean)
projection(ICE_temp)=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

#Rename raster for storage
names(ICE_temp)=paste(DATES$YEAR[1],DATES$MONTH[1],DATES$DAY[1],sep="_")
ICE=ICE_temp

#Loop to dowload, translate, reproject and archive rasters of asi-AMSRE Sea Ice Concentrations in a RasterStack
for(i in 2:(which(DATES$YEAR>=2012)[1]-1))
{#Dowload the asi-AMSR2 .hdf file for each day in DATES from the online repository 
  #ex. "http://www.iup.uni-bremen.de:8084/amsr2data/asi_daygrid_swath/s3125/2014/dec/_RossSea/asi-s3125-20141201.hdf"
  ICE_temp=try(download.file(url=paste("http://www.iup.uni-bremen.de/seaice/amsredata/asi_daygrid_swath/l1a/s3125/",
                                       DATES$YEAR[i],"/",DATES$MONTH_LONG[i],"/","AntarcticPeninsula",
                                       "/asi-s3125-",DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],".hdf",sep=""), 
                             destfile=paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                                            "asi-s3125-",DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],".hdf",sep=""),mode="wb"))
  if(class(ICE_temp)=="try-error"){next}
  
  #Translate asi-AMSR2 .hdf file into NetCDF format which can be read as a raster
  gdal_translate(paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                       "asi-s3125-",DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],".hdf",sep=""),
                 paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                       "asi-s3125-",DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],".nc",sep=""),
                 sds=TRUE)
  
  #Import asi-AMSR2 NetCDF file for DATES$DATE[i] as a raster
  ICE_temp=try(raster(readGDAL(paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                                     "asi-s3125-",DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],".nc",sep=""))))
  if(class(ICE_temp)=="try-error"){next}
  
  #Transform ICE_temp raster into SpatialPointsDataFrame by matching each ICE_temp CONCENTRATION 
  #reading with it's LAT and LONG coordinates from the LongitudeLatitudeGrid file provided for the region
  ICE_temp=data.frame(ICE_CONCENTRATION=as.numeric(as.matrix(ICE_temp)),
                      LONG=as.numeric(as.matrix(ICE_COORD_LONG)),
                      LAT=as.numeric(as.matrix(ICE_COORD_LAT)))
  #Transform LONG coordinates from -180:180 to 0:360 to match ARGOS and BATHY
  ICE_temp$LONG=ifelse(ICE_temp$LONG>0,ICE_temp$LONG,360+ICE_temp$LONG)
  #Create SpatialPointsDataFrame
  coordinates(ICE_temp)=~LONG+LAT
  
  #Rasterize (i.e., sample points within a defined grid) from ICE_temp SpatialPointsDataFrame to create a raster
  #in a geographic latlong WGS84 projection by calculating the mean of all values falling within each grid cell
  #Resolution somewhat reduced from original 800x800 to minimize gaps caused by resampling an uneven grid of points
  ICE_temp=rasterize(x=ICE_temp,
                     y=raster(ncols=750, nrows=750,
                              extent(floor(min(ICE_temp$LONG)),ceiling(max(ICE_temp$LONG)),
                                     floor(min(ICE_temp$LAT)),ceiling(max(ICE_temp$LAT)))),
                     field=ICE_temp$ICE_CONCENTRATION,fun=mean)
  projection(ICE_temp)=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
  
  names(ICE_temp)=paste(DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],sep="_")
  ICE=stack(ICE,ICE_temp)}
remove(ICE_temp)



#Loop to dowload, translate, reproject and archive rasters of asi-AMSR2 Sea Ice Concentrations in a RasterStack
for(i in which(DATES$YEAR>=2012)[1]:nrow(DATES))
{#Dowload the asi-AMSR2 .hdf file for each day in DATES from the online repository 
  #ex. "http://www.iup.uni-bremen.de:8084/amsr2data/asi_daygrid_swath/s3125/2014/dec/_RossSea/asi-AMSR2-s3125-20141201.hdf"
  ICE_temp=try(download.file(url=paste("http://www.iup.uni-bremen.de:8084/amsr2data/asi_daygrid_swath/s3125/",
                                       DATES$YEAR[i],"/",DATES$MONTH_LONG[i],"/","AntarcticPeninsula",
                                       "/asi-AMSR2-s3125-",DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],".hdf",sep=""), 
                             destfile=paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                                            "asi-AMSR2-s3125-",DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],".hdf",sep=""),mode="wb"))
  if(class(ICE_temp)=="try-error"){next}
  
  #Translate asi-AMSR2 .hdf file into NetCDF format which can be read as a raster
  gdal_translate(paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                       "asi-AMSR2-s3125-",DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],".hdf",sep=""),
                 paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                       "asi-AMSR2-s3125-",DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],".nc",sep=""),
                 sds=TRUE)
  
  #Import asi-AMSR2 NetCDF file for DATES$DATE[i] as a raster
  ICE_temp=try(raster(readGDAL(paste("/Users/trevorjoyce/Grad School/Research/1_2016_Antarctic Whale Tracking/Data/Ice Data/AMSR/",
                                     "asi-AMSR2-s3125-",DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],".nc",sep=""))))
  if(class(ICE_temp)=="try-error"){next}
  
  #Transform ICE_temp raster into SpatialPointsDataFrame by matching each ICE_temp CONCENTRATION 
  #reading with it's LAT and LONG coordinates from the LongitudeLatitudeGrid file provided for the region
  ICE_temp=data.frame(ICE_CONCENTRATION=as.numeric(as.matrix(ICE_temp)),
                      LONG=as.numeric(as.matrix(ICE_COORD_LONG)),
                      LAT=as.numeric(as.matrix(ICE_COORD_LAT)))
  #Transform LONG coordinates from -180:180 to 0:360 to match ARGOS and BATHY
  ICE_temp$LONG=ifelse(ICE_temp$LONG>0,ICE_temp$LONG,360+ICE_temp$LONG)
  #Create SpatialPointsDataFrame
  coordinates(ICE_temp)=~LONG+LAT
  
  #Rasterize (i.e., sample points within a defined grid) from ICE_temp SpatialPointsDataFrame to create a raster
  #in a geographic latlong WGS84 projection by calculating the mean of all values falling within each grid cell
  #Resolution somewhat reduced from original 800x800 to minimize gaps caused by resampling an uneven grid of points
  ICE_temp=rasterize(x=ICE_temp,
                     y=raster(ncols=750, nrows=750,
                              extent(floor(min(ICE_temp$LONG)),ceiling(max(ICE_temp$LONG)),
                                     floor(min(ICE_temp$LAT)),ceiling(max(ICE_temp$LAT)))),
                     field=ICE_temp$ICE_CONCENTRATION,fun=mean)
  projection(ICE_temp)=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
  
  names(ICE_temp)=paste(DATES$YEAR[i],DATES$MONTH[i],DATES$DAY[i],sep="_")
  ICE=stack(ICE,ICE_temp)}
remove(ICE_temp)
