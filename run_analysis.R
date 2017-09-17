#First, load the dplyr package from the library
library(dplyr)

#Read in all the revelant text files

trainingdata <- read.table("~/Desktop/UCI HAR Dataset/train/X_train.txt", sep="")

testdata <- read.table("~/Desktop/UCI HAR Dataset/test/X_test.txt", sep="")

training_labels <- read.table("~/Desktop/UCI HAR Dataset/train/y_train.txt")

test_labels <- read.table("~/Desktop/UCI HAR Dataset/test/y_test.txt")

test_subjects <- read.table("~/Desktop/UCI HAR Dataset/test/subject_test.txt")

training_subjects <- read.table("~/Desktop/UCI HAR Dataset/train/subject_train.txt")

#Combine train labels and subjects with train data after giving column names

colnames(training_labels) <- c("Activities")

trainingdata <- cbind(training_labels, trainingdata)

colnames(training_subjects) <- c("Subjects")

trainingdata <- cbind(training_subjects, trainingdata)

#Apply the same process to test data

colnames(test_labels) <- c("Activities")

testdata <- cbind(test_labels, testdata)

colnames(test_subjects) <- c("Subjects")

testdata <- cbind(test_subjects, testdata)

#Create one data set by combining train and test data using rbind()

totaldata <- rbind(trainingdata, testdata)

#Make the names of the variables a vector

variables <- read.table("~/Desktop/UCI HAR Dataset/features.txt", sep="")

#To avoid duplication errors in later phases, I have combined the order numbers with features name under column V3. 

variables$V3 <- paste(variables$V1, sep= "_", variables$V2)

col.names <- as.vector(variables[, 3])

colnames(totaldata) <- c("Subjects", "Activities", col.names) 

#Select only the column names that include "mean" or "std" without choosing "freq" and "angle"

totaldata <- select(totaldata, contains("Subject"), contains("Activities"), contains("mean"), contains("std"), -contains("freq"), -contains("angle"))

#Match the activity names using the activity_labels.txt file

activity.names <- read.table("~/Desktop/UCI HAR Dataset/activity_labels.txt", sep="")

totaldata[ , 2] <- as.character(activity.names[match(totaldata$Activities, activity.names$V1), 'V2'])

#Clean and tidy the data.

library(data.table)

setnames(totaldata, colnames(totaldata), gsub("-", "_", colnames(totaldata)))
setnames(totaldata, colnames(totaldata), gsub("BodyBody", "Body", colnames(totaldata)))
setnames(totaldata, colnames(totaldata), gsub(")", "", colnames(totaldata)))
setnames(totaldata, colnames(totaldata), gsub("\\(", "", colnames(totaldata)))


#Create independent data grouping by subjects and activities

summary_totaldata <- totaldata %>%group_by(Subjects, Activities)%>% summarise_all(funs(mean))

#Finally, write to table to a file

write.table(summary_totaldata, file= "summary_data.txt", row.name =FALSE)

