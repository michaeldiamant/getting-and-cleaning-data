require('reshape2')

datasetHome <- 'UCI HAR Dataset'

datasetPath <- function(relativePath) {
  paste(datasetHome, '/', relativePath, sep = '')
}

sourceRawDataIfMissing <- function () {
  datasetFilename <- 'uci_har_dataset.zip'
  if (!file.exists(datasetFilename)) {
    message('Downloading dataset archive')
    download.file(
      url = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', 
      destfile = datasetFilename,
      method = 'curl')
  } else 
    message(paste('Skipping dataset archive download because', datasetFilename, 'exists'))

  if (!file.exists(datasetHome)) {
    message('Extracting dataset archive')
    unzip(datasetFilename)   
  } else 
     message(paste('Skipping dataset archive extraction because', datasetHome, 'dir exists'))
}

# Ensures feature names are valid R column names and additionally appends 
# unique identifier to disambiguate duplicate column names.
loadFeatureNames <- function() {
  features <- read.table(
    file = datasetPath('features.txt'), 
    header = F, 
    col.names = c('index', 'name'), 
    colClasses = 'character')
  make.names(features$name, unique = T)
}

loadTestData <- function(featureNames) {
  message('Loading test data into memory')
  testData <- read.table(
    file = datasetPath('test/X_test.txt'), 
    header = F, 
    col.names = featureNames)
  testLabels <- read.table(
    file = datasetPath('test/y_test.txt'), 
    header = F, 
    col.names = c('activityLabelId'))
  testSubjects <- read.table(
    file = datasetPath('test/subject_test.txt'), 
    header = F, 
    col.names = c('subjectId'))
  cbind(testData, testLabels, testSubjects)
}

loadTrainingData <- function(featureNames) {
  message('Loading training data into memory')
  trainData <- read.table(
    file = datasetPath('train/X_train.txt'), 
    header = F, 
    col.names = featureNames)
  trainLabels <- read.table(
    file = datasetPath('train/y_train.txt'), 
    header = F, 
    col.names = c('activityLabelId'))
  trainSubjects <- read.table(
    file = datasetPath('train/subject_train.txt'), 
    header = F, 
    col.names = c('subjectId'))
  cbind(trainData, trainLabels, trainSubjects)  
}

loadActivityLabels <- function() {
  read.table(
    file = datasetPath('activity_labels.txt'),
    header = F, 
    col.names = c('activityLabelId', 'activityLabel'))
}

applyActivityLabels <- function (activityLabels, df)  {
  message('Replacing activity label IDs with corresponding activity labels')
  labeledDf <- merge(
    x = df, 
    y = activityLabels, 
    by.x = 'activityLabelId', 
    by.y = 'activityLabelId')
  labeledDf <- labeledDf[,ncol(labeledDf):1] # Move subject and activity to front
  labeledDf$activityLabelId <- NULL # Remove activity label ID
  labeledDf
}

sourceRawDataIfMissing()
featureNames <- loadFeatureNames()

training <- loadTrainingData(featureNames)
test <- loadTestData(featureNames)

message('Combining test and training data')
combined <- rbind(training, test)

message('Selecting subject ID, activity label, and all mean/standard deviation features')
meansAndStdDevs <- combined[, grep('subjectId|activityLabelId|mean|std', colnames(combined))]

labeledMeansAndStdDevs <- applyActivityLabels(loadActivityLabels(), meansAndStdDevs)

message('Computing mean of all mean/standard deviation features per subject ID per activity')
meltedMeansAndStdDevs <- melt(
  data = labeledMeansAndStdDevs, 
  id = c('subjectId', 'activityLabel'))
subjectActivityMeans <- dcast(
  data = meltedMeansAndStdDevs, 
  formula = subjectId + activityLabel ~ variable, 
  fun.aggregate = mean)  
tidySubjectActivityMeans <- melt(
  data = subjectActivityMeans,
  id.vars = c('subjectId', 'activityLabel'),
  value.name = 'mean') 

message('Writing subject activity means to disk')
outputFilename <- 'subject_activity_means.txt'
write.table(tidySubjectActivityMeans, row.names = F, file = outputFilename)
message(paste('Dataset written to', paste(getwd(), '/', outputFilename, sep = '')))
