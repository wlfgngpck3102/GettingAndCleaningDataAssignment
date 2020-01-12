## This function downloads the data and unzips it to use in your workspace.  It should only need to be run once!
## Once the data is downloaded and unzipped, the function will trivially succeed.

downloadAndUnzip <- function() {
    zipName <- "getdata_projectfiles_UCI HAR Dataset.zip"
    
    # Downloads the zip file if not already downloaded
    if (!file.exists(zipName)){
        zipURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(zipURL, zipName, method="curl")
    }  
    
    # Unzips the folder if not already downloaded and unzipped
    if (!file.exists("UCI HAR Dataset")) { 
        unzip(zipName) 
    }
    
    print("The data has been downloaded and unzipped!")
}

## This function dynamically determines the paths to use, and then loads all datasets in to create the raw merged dataset.
## Raw data output from this is a list of activities and the merged test and train data
## This function's output "rawData" performs Step 1 of the assignment

loadRawData <- function() {
    mainFiles <- list.files("UCI HAR Dataset", pattern = ".txt")
    testFiles <- list.files("UCI HAR Dataset/test", pattern = ".txt")
    trainFiles <- list.files("UCI HAR Dataset/train", pattern = ".txt")
    filter1 <- grepl("_info", mainFiles)
    filtered <- mainFiles[!filter1]
    filter2 <- grepl("README", filtered)
    mainFiles <- filtered[!filter2]
    
    activities <- read.table(paste("UCI HAR Dataset/", mainFiles[1], sep=""), col.names = c("activity_code", "activity"))
    features <- read.table(paste("UCI HAR Dataset/", mainFiles[2], sep=""), col.names = c("feature_code", "feature"))
    test_subject <- read.table(paste("UCI HAR Dataset/test/", testFiles[1], sep=""), col.names = c("subject"))
    test_x <- read.table(paste("UCI HAR Dataset/test/", testFiles[2], sep=""), col.names = features$feature)
    test_y <- read.table(paste("UCI HAR Dataset/test/", testFiles[3], sep=""), col.names = c("activity_code"))
    train_subject <- read.table(paste("UCI HAR Dataset/train/", trainFiles[1], sep=""), col.names = c("subject"))
    train_x <- read.table(paste("UCI HAR Dataset/train/", trainFiles[2], sep=""), col.names = features$feature)
    train_y <- read.table(paste("UCI HAR Dataset/train/", trainFiles[3], sep=""), col.names = c("activity_code"))
    
    total_subject <- rbind(train_subject, test_subject)
    total_x <- rbind(train_x, test_x)
    total_y <- rbind(train_y, test_y)
    
    rawData <- cbind(total_subject, total_x, total_y)
    return(list(activities, rawData))
}

## This function takes in our rawData data frame and outputs a data table of subject and activity codes, as well as all features that
## contain either "mean" or "std" to allow us to flag features including either mean or std.
## This function's output filteredData performs Step 2 of the assignment

extractMeanAndStd <- function(rawData) {
    library(dplyr)
    rawData <- tbl_df(rawData)
    filteredData <- select(rawData, subject, activity_code, contains("mean"), contains("std"))
}

## This function cleans up the information in the data, by replacing the activity code with the actual activity and making the features
## more descriptive.  This function accomplishes Steps 3 and 4 of the assignment.

cleanDataNames <- function(activities, filteredData) {
    ##Replaces the activity code with a description of the activity according to the "activity_labels.txt" file
    
    cleanedData <- filteredData
    cleanedData$activity_code <- activities[filteredData$activity_code, 2]
    names(cleanedData)[2] <- names(activities)[2]
    
    ## The below substitutions are according to the information provided in "features_info.txt"
    
    ## Acc and Gryo indicates accelerometer and gyroscope 3-axial raw signals, respectively
    names(cleanedData) <- gsub("Acc", "Accelerometer", names(cleanedData))
    names(cleanedData) <- gsub("Gyro", "Gyroscope", names(cleanedData))
    
    ## Mean and Std aren't formatted nicely in features.txt.  Also reformatting meanFreq.
    names(cleanedData) <- gsub("mean", "Mean", names(cleanedData), ignore.case = TRUE)
    names(cleanedData) <- gsub("std", "Std", names(cleanedData), ignore.case = TRUE)
    names(cleanedData) <- gsub("meanFreq", "MeanFrequency", names(cleanedData), ignore.case = TRUE)
    
    ## Mag indicates magnitude
    names(cleanedData) <- gsub("Mag", "Magnitude", names(cleanedData))
    
    ## Prefix "t" indicates time, prefix "f" denotes frequency.
    names(cleanedData) <- gsub("^t", "Time", names(cleanedData))
    names(cleanedData) <- gsub("^f", "Frequency", names(cleanedData))
    
    ## In some cases, the prefix "t" comes after the word "angle" and thus the above prefix substitution will not address it.  
    ## We address those situations below.
    names(cleanedData) <- gsub("tBody", "TimeBody", names(cleanedData))
    
    ## Upon inpection, some of the labels include "BodyBody" which doesn't fit with the information provided in features_info.txt.
    ## I can only conclude this was an error on the part of the data collectors, and that they meant to label these with one body.
    names(cleanedData) <- gsub("BodyBody", "Body", names(cleanedData))
    
    ## Clean up the names, getting rid of all spaces and special characters in the names
    names(cleanedData) <- gsub("[[:space:]]", "", names(cleanedData))
    names(cleanedData) <- gsub("[[:punct:]]", "", names(cleanedData))
    
    return(cleanedData)
}

## This function groups cleanedData table by subject and activity, and then applies the mean to every metric.
## This then prints out that data in a standard txt file.  This function accomplishes Step 5 of the assignment.

tidyDataPrint <- function(cleanedData) {
    
    ## If the file already exists, delete it first, as we would not be invoking this function if we were already happy with the data
    if (file.exists("tidyData.txt")){
        print("Deleting existing tidyData.txt file...")
        file.remove("tidyData.txt")
        print("Existing tidyData.txt file has been deleted!")
    }
    
    print("Printing a new tidyData.txt file...")
    tidyData <- group_by(cleanedData, subject, activity)
    tidyData <- summarise_all(tidyData, ~ mean(.))
    write.table(tidyData, "tidyData.txt", row.name=FALSE)
    print("A new tidyData.txt file has been printed to the directory!")
}

## This main function is a single function that performs the cleaning by executing all steps end to end.
## To download the data and produce a tidy dataset, one needs only to execute this function.

main <- function() {
    ## Download and unzip the data
    downloadAndUnzip()
    
    ## Parse in the data and organize
    data <- loadRawData()
    activities <- data[[1]]
    rawData <- data[[2]]
    
    ## Extract only the columns with mean and std
    filteredData <- extractMeanAndStd(rawData)
    
    ## Clean up the data names to make meaningful
    cleanedData <- cleanDataNames(activities, filteredData)
    
    ## Summarize by taking mean of every metric, and print output
    tidyDataPrint(cleanedData)
}

## This final function is just for convenience, to load in the tidyData set if it exists.  Makes it easy to review final output.

loadTidyData <- function() {

    ## If the file doesn't exist, stop the function.
    if (!file.exists("tidyData.txt")){
        stop("The tidyData.txt file has not been created.  Please execute the main() function and then try again!")
    }
    
    tidyData <- read.table("tidyData.txt", header=TRUE)
}