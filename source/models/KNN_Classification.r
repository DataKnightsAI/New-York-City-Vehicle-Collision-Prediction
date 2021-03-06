library(dplyr)
library(gbm)
library(caTools)
library(pROC)
library(doParallel)
library(caret)
#library(DMwR)
#library(ROSE)
library(MLmetrics)
library(class)

motor_collision_crash_clean_data <- read.csv("C:\\Users\\alexf\\Documents\\CSML1000\\Assignments\\CSML1000-Group-10-assignment-1\\data\\motor_vehicle_collisions_crashes_cleaned.csv")

#data <- select(motor_collision_crash_clean_data, -c(id, timestamp, total_number_of_crashes))
data <- select(motor_collision_crash_clean_data, -c(id, total_number_of_crashes))

data$timestamp = as.Date(data$timestamp)
data$precinct = as.numeric(as.factor(data$precinct))
data$month = as.numeric(data$month)
data$week = as.numeric(data$week)
data$day = as.numeric(data$day)
data$weekday = as.numeric(data$weekday)
data$hour = as.numeric(data$hour)
data$did_crash_happen = as.factor(
  ifelse(data$did_crash_happen ==  0, "no", "yes")
)

set.seed(123)
# data_newer = data[data$timestamp > '2016-01-27', ]
# data_sample = sample.split(data_newer$hour,SplitRatio=0.80)
# trainData = subset(data_newer, data_sample==TRUE)
# testData = subset(data_newer, data_sample==FALSE)
trainData = data[data$timestamp > '2017-01-27' & data$timestamp < '2019-01-27', ]
testData = data[data$timestamp > '2019-01-26', ]

trainData <- select(trainData, -c(timestamp))
testData <- select(testData, -c (timestamp))

set.seed(123)
columns = colnames(trainData)
trainData_upsampled = upSample(
  x = trainData[, columns[columns != "did_crash_happen"] ], 
  y = trainData$did_crash_happen, list = F, yname = "did_crash_happen"
)
print(table(trainData_upsampled$did_crash_happen))

#try downsampling instead...
trainData_downsampled = downSample(
  x = trainData[, columns[columns != "did_crash_happen"] ], 
  y = trainData$did_crash_happen, list = F, yname = "did_crash_happen"
)
print(table(trainData_downsampled$did_crash_happen))

#for KNN, we need to separate train response variable so it is put into cl 
trainData_downsampled_response_column = trainData_downsampled[, ncol(trainData_downsampled)] #last column should always be response variable
testData_response_column = testData[, ncol(testData)]

#remove response variable from trainData and testData
#and normalize the predictors
nor <- function(x) { (x -min(x))/(max(x)-min(x))   }
trainData_downsampled_without_response_var = as.data.frame(lapply(trainData_downsampled[, 1:ncol(trainData_downsampled) - 1], nor))
testData_without_response_var = as.data.frame(lapply(testData[, 1:ncol(testData) - 1], nor))

#PART 2: FOR LIBRARY-KNN ONLY
#remove unnecessary data objects for library-knn
rm(motor_collision_crash_clean_data, data, data_newer, data_sample, trainData)
rm(trainData_upsampled)
#rm(trainData_downsampled, testData)
gc()
memory.limit()
memory.limit(size=30000)

set.seed(123)
ptm_rf <- proc.time()
model_knn <- knn(
  trainData_downsampled_without_response_var,
  testData_without_response_var,
  cl = trainData_downsampled_response_column,
  k=5,
  prob = TRUE #create probabilities so we can plot ROC
)
proc.time() - ptm_rf

#probabilities 
attributes(model_knn)$prob

roc.model_knn = pROC::roc(
  testData$did_crash_happen, 
  as.vector(ifelse(attributes(model_knn)$prob >0.5, 1,0))
  #ifelse(attributes(model_knn)$prob
)
auc.model_knn = pROC::auc(roc.model_knn)
print(auc.model_knn)

#plot ROC curve
plot.roc(roc.model_knn, print.auc = TRUE, col = 'red' , print.thres = "best" )

confusionMatrix(model_knn, testData_response_column)

#summary of model_knn
summary(auc.model_knn)

# Save the model into a file
save(model_knn, file="model_knn_5.rda")
