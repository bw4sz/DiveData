# Humpback distribution and sea ice
Ben Weinstein  
February 21, 2017  




#Argos Observations


# Dive Data



# Geographic Data
![](IceAnalysis_files/figure-html/unnamed-chunk-3-1.png)<!-- -->

## Bind the geographic and dive data



## Occupancy and ice concentration.

What is the probability of occupancy of a cell as a function of % ice cover.

Associate each argos location with ice cell.







![](IceAnalysis_files/figure-html/unnamed-chunk-7-1.png)<!-- -->

![](IceAnalysis_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

# Null models

## Random use

Null use map

For each day, sample randomly in the background points for null values of sea ice concentration.



![](IceAnalysis_files/figure-html/unnamed-chunk-10-1.png)<!-- -->![](IceAnalysis_files/figure-html/unnamed-chunk-10-2.png)<!-- -->

## Temperal window

Sample the cells in a sliding window


* we are allowed to sample any cells that have been occupied in the dataset, we know that whales can disperse to those sites. This ignores the inhenerent spatial autocorrelation in movement.



