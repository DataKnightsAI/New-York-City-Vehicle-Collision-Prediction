crashes_data_clean <- read.csv('../data/motor_vehicle_collisions_crashes_cleaned.csv')

#crashes_data_clean <- crashes_data[!(is.na(crashes_data$ZIP.CODE)),]

library(dplyr)



## Drop 3rd,4th and 5th columns of the dataframe
crashes_data_select <- select(crashes_data_clean,-c(1,3, 9, 10))
crash_nocrash <- crashes_data_clean$did_crash_happen

##round to 3 decimal places
#crashes_data_select$LATITUDE <- round(crashes_data_select$LATITUDE, digits=3)
#crashes_data_select$LONGITUDE <- round(crashes_data_select$LONGITUDE, digits=3)

##Concat lat and long columns into one
c#rashes_data_select$POINT.LOCATION = paste(crashes_data_select$LATITUDE,",",crashes_data_select$LONGITUDE)

##DROP YEAR FROM DATE

#crashes_data_select$CRASH.DATE <- as.Date(crashes_data_select$CRASH.DATE, "%m/%d/%Y")
#crashes_data_select$CRASH.DATE <- format(crashes_data_select$CRASH.DATE, format="%m/%d")
#crashes_data_select$CRASH.DATE <- as.Date(crashes_data_select$CRASH.DATE, "%m/%d")
#table(crashes_data_select$CRASH.DATE)

##round times
#library(lubridate)
##crashes_data_select$CRASH.ROUNDTIME <- as.Date(crashes_data_select$CRASH.TIME, "%H:%M")
#crashes_data_select$CRASH.ROUNDTIME <- strptime(crashes_data_select$CRASH.TIME, "%HH:%M")
#crashes_data_select$CRASH.ROUNDTIME <- round_date(crashes_data_select$CRASH.ROUNDTIME, unit="30 minutes")
#crashes_data_select$CRASH.ROUNDTIME <- format(crashes_data_select$CRASH.ROUNDTIME, format="%H:%M")

# library(caTools)
# set.seed(123)
# data_sample = sample.split(crashes_data_select$precinct,SplitRatio=0.80)
# train_data = subset(crashes_data_select,data_sample==TRUE)
# test_data = subset(crashes_data_select,data_sample==FALSE)

set.seed(123) # set the seed to make the partition reproducible

# 80% of the sample size
smp_size <- floor(0.80 * nrow(crashes_data_select))

train_ind <- sample(seq_len(nrow(crashes_data_select)), size = smp_size)

# creating test and training sets that contain all of the predictors
crashes_pred_test <- crashes_data_select[train_ind, ]
crashes_pred_train <- crashes_data_select[-train_ind, ]

crash_nocrash <- as.data.frame(crash_nocrash)

#Split outcome variable into training and test sets using the same partition as above.
crash_nocrash_test <- crash_nocrash[train_ind, ]
crash_nocrash_train <- crash_nocrash[-train_ind, ]

library(FNN)
knn_output <- knn.reg(crashes_pred_train, crashes_pred_test, crash_nocrash_train, k = 4)
print(knn_output)


#plot(crashes_pred_test, knn_output$pred, xlab="y", ylab=expression(hat(y)))

plot(crash_nocrash_test, knn_output$pred, xlab="y", ylab=expression(hat(y)))


##create confusion matrix
tab <- table(knn_output$pred,crash_nocrash_test)

##this function divides the correct predictions by total number of predictions that tell us how accurate teh model is.

accuracy <- function(x){sum(diag(x)/(sum(rowSums(x)))) * 100}
accuracy(tab)

#mean square prediction error
mean((crash_nocrash_test - knn_output$pred) ^ 2)

table(tab)

# Num of zip codes in clean data
#as.data.frame(table(crashes_data_clean$ZIP.CODE))

#DECISION TREE ALGO

# Next, we will implement a decision tree algorithm. Decision Trees to plot the outcomes of a decision. These outcomes are basically a consequence through
# which we can conclude as to what class the object belongs to. We will now implement our decision tree model and will plot it using the rpart.plot()
# function. We will specifically use the recursive parting to plot the decision tree.

# library(rpart)
# library(rpart.plot)
# decisionTree_model <- rpart(ZIP.CODE ~ . , train_data, method = 'class')
# predicted_val <- predict(decisionTree_model, test_data, type = 'class')
# probability <- predict(decisionTree_model, test_data, type = 'prob')
# rpart.plot(decisionTree_model)
# auc.rp = roc(test_data$Class, factor(predicted_val, ordered = TRUE), plot = TRUE, col = "blue")
# auc.rp
