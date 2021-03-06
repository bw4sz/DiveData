# Humpback distribution and sea ice
Ben Weinstein  
February 21, 2017  

# Project Description 
  
  * Global changes in climate will lead to new environments
  
  * A key question is how sensitive animals are to changes in environmental conditions
  
  * When favorable conditions arise, how quickly can animals respond to the availability of new habitat?
  
  * Polar marine ecosystems are particularly vulnerable, given the pronounced effects of climate on local conditions, variable environments, and lack of information on species distributions
  
  * We evaluate the response of two cetacean species to changes in sea-ice cover.
  
##	Our aims

  * Sea ice trends, by month, over the last 5 years

  * Determine the threshold of sea-ice concentration and proximity on whale presence
  
  * Evaluate the phenology of sea-ice timing and whale movement
  
  * Highlight anomalous sea ice conditions  
  * % Change in available habitat based on variable ice conditions





# Occupancy and ice concentration.

What is the probability of occupancy of a cell as a function of % ice cover.

Associate each argos location with ice cell.





![](IceAnalysis_files/figure-html/unnamed-chunk-5-1.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-5-2.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-5-3.png)<!-- -->

![](IceAnalysis_files/figure-html/unnamed-chunk-6-1.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-6-2.png)<!-- -->

##Time integration

Each observation is not independent. In the above analysis a whale popping up 4 times in an hour will recieve the same weight as 4 observations in one day. One approach is to take the average ice concentration among observations and multiply it be the time difference.

![](IceAnalysis_files/figure-html/unnamed-chunk-7-1.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-7-2.png)<!-- -->

# Null models

## Random use

Null use map

For each day, sample randomly in the background points for null values of sea ice concentration.



![](IceAnalysis_files/figure-html/unnamed-chunk-9-1.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-9-2.png)<!-- -->

#Distance to ice edge

![](IceAnalysis_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

![](IceAnalysis_files/figure-html/unnamed-chunk-11-1.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-11-2.png)<!-- -->

### Zoom in 

![](IceAnalysis_files/figure-html/unnamed-chunk-12-1.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-12-2.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-12-3.png)<!-- -->

# Temperal window

Sample the cells in a sliding 10 day window

![](IceAnalysis_files/figure-html/unnamed-chunk-13-1.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-13-2.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-13-3.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-13-4.png)<!-- -->



