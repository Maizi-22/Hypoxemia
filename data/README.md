### There are data file:
#### 1.data_raw_6hr: raw data
#### 2.data_simple: average 6-timestamp-value for every variable(pre and post)
* You may want to use this for test(e.g wilcox test)
#### 3. data_std: data after interpolation,  missing value are replaced by the nearest value within 3 hr
* You may use this data for time series analysis. While there are lots of missing values, actually it only contains 44 complete cases.
