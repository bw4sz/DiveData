# Humpback distribution and sea ice
Ben Weinstein  
February 21, 2017  



#Argos Observations


## Occupancy and ice concentration.

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

## Temperal window

Sample the cells in a sliding window

* we are allowed to sample any cells that have been occupied in the dataset, we know that whales can disperse to those sites. This ignores the inhenerent spatial autocorrelation in movement.

#Distance to ice edge



![](IceAnalysis_files/figure-html/unnamed-chunk-11-1.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-11-2.png)<!-- -->



