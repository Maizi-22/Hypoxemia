library(readr)
# load data
data.raw100 <- read_csv("~/Documents/R-projects/Hypoxemia/data/data_raw100.csv")[, -1]

# # caculate mean value that omit na value
MeanCol <- function(x){
  mean(x, na.rm = T)
}

# first generate a simple form contain only cvp_pre and cvp_post etc.
GetSimpleData <- function(data){
  data.simple <- data[, c('icustay_id', 'onsettime', 'pao2fio2ratio', 'fio2')]
  # data.simple <- data.raw.6hr[, c(1:2, 39, 40)]
  # caculate mean value of 6 timestamp of every variable
  data.simple$cvp_pre <- apply(data[, c('cvp_pre1', 'cvp_pre2', 'cvp_pre3', 'cvp_pre4', 'cvp_pre5', 'cvp_pre6')], 1, MeanCol)
  data.simple$cvp_post <- apply(data[, c('cvp_post1', 'cvp_post2', 'cvp_post3', 'cvp_post4', 'cvp_post5', 'cvp_post6')], 1, MeanCol)
  data.simple$dbp_pre <- apply(data[, c('dbp_pre1', 'dbp_pre2', 'dbp_pre3', 'dbp_pre4', 'dbp_pre5', 'dbp_pre6')], 1, MeanCol)
  data.simple$dbp_post <- apply(data[, c('dbp_post1', 'dbp_post2', 'dbp_post3', 'dbp_post4', 'dbp_post5', 'dbp_post6')], 1, MeanCol)
  data.simple$peep_pre <- apply(data[, c('peep_pre1', 'peep_pre2', 'peep_pre3', 'peep_pre4', 'peep_pre5', 'peep_pre6')], 1, MeanCol)
  data.simple$peep_post <- apply(data[, c('peep_post1', 'peep_post2', 'peep_post3', 'peep_post4', 'peep_post5', 'peep_post6')], 1, MeanCol)
  data.simple$heartrate_pre <- apply(data[, c('heartrate_pre1', 'heartrate_pre2', 'heartrate_pre3', 'heartrate_pre4', 'heartrate_pre5', 'heartrate_pre6')], 1, MeanCol)
  data.simple$heartrate_post <- apply(data[, c('heartrate_post1', 'heartrate_post2', 'heartrate_post3', 'heartrate_post4', 'heartrate_post5', 'heartrate_post6')], 1, MeanCol)
  data.simple$cvp_dbp_pre <- data.simple$cvp_pre/data.simple$dbp_pre
  data.simple$cvp_dbp_post <- data.simple$cvp_post/data.simple$dbp_post
  # get a complete dataset of 650 cases
  data.simple <- data.simple[complete.cases(data.simple), ]
  return(data.simple)
}

data.simple100 <- GetSimpleData(data.raw100)
# write.csv(data.simple100, '~/Documents/R-projects/Hypoxemia/data/data_simple100.csv')

# set OI to 200 and process subgroup analysis
data.raw200 <- read_csv("~/Documents/R-projects/Hypoxemia/data/data_raw200.csv")[, -1]
data.simple200 <- GetSimpleData(data.raw200)
# write.csv(data.simple200, '~/Documents/R-projects/Hypoxemia/data/data_simple200.csv')

# set OI cutoff = 200 
# and limit OI between (200, 300) before cutoff
# OI between (100, 200) after cutoff
data.raw200.limited <- read_csv("~/Documents/R-projects/Hypoxemia/data/data_raw200_limited.csv")[, -1]
data.simple200.limited <- GetSimpleData(data.raw200.limited)
# write.csv(data.simple200.limited, '~/Documents/R-projects/Hypoxemia/data/data_simple200_limited.csv')

# set OI cutoff = 100 
# and limit OI between (100, 200) before cutoff
# OI between (0, 100) after cutoff
data.raw100.limited <- read_csv("~/Documents/R-projects/Hypoxemia/data/data_raw100_limited.csv")[, -1]
data.simple100.limited <- GetSimpleData(data.raw100.limited)
# write.csv(data.simple100.limited, '~/Documents/R-projects/Hypoxemia/data/data_simple100_limited.csv')

# wilcox test
wilcox.test(data.simple100$cvp_dbp_pre, data.simple100$cvp_dbp_post)
wilcox.test(data.simple100$peep_pre, data.simple100$peep_post)
# generate a time series dataset
# where missing value are replaced by the nearest value within 3 hr
# a function to interpolate missing data in cvp dbp and peep
# data should contain hadm_id and 6 value
MissingInterp <- function(data){
  for (i in 1:4){
    data[is.na(data[, 8-i]), 8-i] <- data[is.na(data[, 8-i]), 7-i]
  }
  data[is.na(data[, 3]), 3] <- data[is.na(data[, 3]), 2]
  for (i in 1:5){
    data[is.na(data[, 1+i]), 1+i] <- data[is.na(data[, 1+i]), 2+i]
  }
  return(data)
}
data.std <- data.raw100
for (i in 1:6){
  data.std[, c((3+6*(i-1)):(8+6*(i-1)))] <- MissingInterp(data.std[, c(1, (3+6*(i-1)):(8+6*(i-1)))])[, -1]
}
# write.csv(data.std, '~/Documents/R-projects/Hypoxemia/data/data_std.csv')
a <- data.std[complete.cases(data.std), ]