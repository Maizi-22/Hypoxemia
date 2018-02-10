### There are data file:
#### Four are raw data got from sql code directly
#### 1.data_raw100: raw data when defined hyppxemia cutoff as OI = 100
#### 2.data_raw200: raw data when defined hyppxemia cutoff as OI = 200
#### 3.data_raw100_limited: raw data when defined hyppxemia cutoff as OI = 100 and limit OI before the cutoff between (100, 200), after between (0, 100) in 6 hours
#### 4.data_raw200_limited: raw data when defined hyppxemia cutoff as OI = 200 and limit OI before the cutoff between (200, 300), after between (100, 200) in 6 hours

#### Four are pre-precessed in R regards to four csv file above
#### average 6-timestamp-value for every variable(pre and post)
#### 1.data_simple100: for data_raw100
#### 2.data_simple200: for data_raw200
#### 3.data_simple100_limited: for data_raw100_limited
#### 4.data_simple200_limited: for data_raw200_limited
* You may want to use the processed data for test(e.g wilcox test)

* You may use further processed data for time series analysis which are not included for now. 

