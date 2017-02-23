# Getting and cleaning Data Course project
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# setwd("R_Projects/dataCleaning/project/")
# install.packages("plyr")
# install.packages("reshape2")
library("plyr")
library(reshape2)

# download zip file containing data if needed
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI HAR Dataset.zip"

if (!file.exists(zipFile)) {
    download.file(zipUrl, zipFile, mode = "wb")
}

# unzip zip file containing data if nedded
dataPath <- "UCI HAR Dataset"
if (!file.exists(dataPath)) {
    unzip(zipFile)
}

# 1. Merges the training and the test sets to create one data set.
#
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
subjectData <- rbind(subjectTrain, subjectTest)

activityTest <- read.table("UCI HAR Dataset/test/y_test.txt")
activityTrain <- read.table("UCI HAR Dataset/train/y_train.txt")
activityData <- rbind(activityTrain, activityTest)

measureTest <- read.table("UCI HAR Dataset/test/X_test.txt")
measureTrain <- read.table("UCI HAR Dataset/train/X_train.txt")
measureData <- rbind(measureTrain, measureTest)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
#
features <- read.table("UCI HAR Dataset/features.txt")
featuresToExtract <- grep (".*mean.*|.*std.*", features[,2])
featuresToExtractNames <- features[featuresToExtract,2]
measureData <- measureData[,featuresToExtract]

# 3. Uses descriptive activity names to name the activities in the data set
#
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
activityData <- join(activityData, activities)
colnames(activityData) <- c("activityID", "activityLabel")
# remove unnecessary column activityID
activityData <- activityData[, c("activityLabel")]

# 4 Appropriately labels the data set with descriptive variable names.
#
featuresToExtractNames <- gsub('-mean', 'Mean', featuresToExtractNames)
featuresToExtractNames <- gsub('-std', 'Std', featuresToExtractNames)
featuresToExtractNames <- gsub('[()]', '', featuresToExtractNames)
featuresToExtractNames <- gsub('-', '', featuresToExtractNames)
#write.table(featuresToExtractNames, "featuresNames.txt", row.names = FALSE, quote = FALSE)
colnames(measureData) <- featuresToExtractNames
colnames(sujectData) <- c("subjectID")
measureData <- cbind(sujectData, activityData, measureData)

#5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#
measureData_melted <- melt(measureData, id.vars = c("subjectID","activityID", "activityLabel"))

measureData_Mean <- dcast(measureData_melted, subjectID + activityID + activityLabel ~ variable, fun.aggregate = mean)

write.table(measureData_Mean, "tidy.txt", row.names = FALSE, quote = FALSE)
