---
title: "CodeBook"
author: "Adam"
date: "1/12/2020"
output: html_document
---

This codebook gives a more detailed description of how the data was cleaned, and how the cleaning produced a data set that met with the five steps of the assignment and conform to the tidy data principles.

The analysis is performed via running the run_analysis.R script; please see the README file for details on how this is run.  While the README provides instructions for running the data, this CodeBook provides details about how the cleaning was done, and why the resulting output addresses the ask of the assignment.

1. **Downloading the Data:** Before we can begin running analysis on the data, we have to download and unzip it.  We've seen several examples in class of how to take a URL and download data from said URL to our work space.  This function is a direct port of that implementation.  Note that we want to prevent downloading the data set every time the code is run, as that will quickly create multiple unnecessary copies of the data.  Therefore, we add a check that ensures the folder doesn't already exist; if it does already exist, the function simply skips that section of code.  Similarly, we want to unzip the downloaded file so that we can load data from it, but again we don't want to unzip it if it's already been unzipped.  So if the unzipped file doesn't already exist, we run the unzip() function on the zipped file; else, we simply skip this section of code.

2. **Loading In The Raw Data:** Once the data has been downloaded, we are able to start ingesting the data into R.  Examining the downloaded folder, we see that there are four txt files and two additional folders.  Inside each folder are a subject file, an X file, and a Y file.  The assignment asks us to merge the training and tests data sets into one single data set.  This function ultimately performs this task, satisfying the first step of the assignment.  The steps performed are the following:

    + **Dynamically Identify The Appropriate Text Files To Load:** The assignment requires that we load in the subject, X, and Y text files for both training and test data, and that we load in features and activities.  The features text file is the list of all the different types of analysis that are performed, activities maps the activity code to the actual activity, the subject file identifies subjects by number, the X files identify the results of each metric studied (as listed in feature), and the Y data matches that metric row to an activity.  The function dynamically identifies each of these files, knowing to exclude README.txt and features_info.txt.
    
    + **Load The Data In:** Once the files are identified, read.table() is called for each file path.  Since the column names are specific to the data in question and informed by the REAMDE file, we could not map it dynamically in an intelligent way; therefore, column names are unfortunately hardcoded.  Note that the features.text file was loaded in solely to allow us to easily refer to the named list of features that are measured in X.
    
    + **Combine Each Of X, Y, and Subject:** Using rbind() in each case, we create a total_subject, a total_x, and a total_y dataset by using rbind() on the training and test versions of each dataset.  This completely loads in both the test and training data set, part of the requirement of Step 1 of the assignment.
    
    + **Combine X, Y, and Subject Into A Single Data Set:** Finally, using cbind(), total_subject, total_x, and total_y are combined into one single data set.  The function then returns a list, where the first element is the activities data set (to be used later) and the second element is rawData, which is the data set that satisfies Step 1 of the assignment, which says that run_analysis.R "merges the training and the test sets to create one data set."
    
3. **Extract Mean And Standard Deviation:** Next, we take the raw data created in the previous step and apply a filter to it so that we only retain the subject column, the activity_code column, and any metric name that includes either the word "mean" or the word "std" as that flags mean and standard deviation according to the features_info.txt file.  At the end, we now have a filteredData data set which only includes metric columns for mean or standard deviation.  This accomplishes Step 2 of the assignment, which says that run_analysis.R "extracts only the measurements on the mean and standard deviation for each measurement."

4. **Improve Data Labels In Rows And Columns:** This cleaning is more involved, but ultimately accomplishes Steps 3 and 4 of the assignment.  This takes in the activities data set from Step 2 above and filteredData from Step 3 above to create a new data set with activities more accurately described and with measurements more accurately broken out.

    + **Replace Activity Codes with Descriptive Activities:** Using the activities data set, which maps activity code to the activity description, we simply replace the column of activity codes by using each code in the activities mapping.  The result is a column of descriptive activities, which we then insert into a new variable called cleanedData.  Finally, we change the column name from "activity_code" to "activity."  This accmplishes Step 3 of the assignment, which says that run_analysis.R "uses descriptive activity names to name the activities in the data set."
    
    + **Make Data Set Column Names More Descriptive:** As written, it's not clear what something like "tBodyAcc-mean()-X" means without reading through the features_info.txt file and doing a lot of work.  Therefore, we do a lot of regular expression substitutions based on information contained in features_info.txt.  Acc is mapped to Accelerometer, Gyro is mapped to Gyroscope, mean/meanFreq/std are mapped to Mean/MeanFrequency/Std, and mag is mapped to magnitude.  The features_info.txt file tells us that the prefix of "t" denotes Time and "f" denotes Frequency, so we replace "t" and "f" prefixes with "Time" and "Frequency," respectively.  In cases where "angle" was used, the prefix of "t" wasn't captured by the previous substitution because it no longer occurred at the beginning of a line.  To address those cases, we instead replaced "tBody" with "TimeBody" which is what would have resulted had the previous prefix substitution worked on those cases.
    
    + **Clean Up Naming Issues Identified In The Column Names:** After the above substitutions were made, a few issues were identified and addressed.  First, some of the columns labels came in with "BodyBody" instead of "Body;" having read through features_info.txt, I can only conclude that was an unintentional error on the part of the data collector, so I substituted "BodyBody" with "Body" to be consistent with the other column names.  The other issues arose due to weird formatting of spaces and special characters in the names.  These were removed by using substitutions of regular expressions representing any type of space or any type of special character and replacing it with nothing at all.  After these changes, we find that "tBodyAcc-mean()-X" has become "TimeBodyAccelerometerMeanX" which is far more descriptive.  This accomplishes Step 4 of the assignment, which says that run_analysis.R "appropriately labels the data set with descriptive variable names."
    
5. **Groups Data By Subject And Activity And Takes Average Of All Measurements:** Finally, having created the cleanedData data set in Step 4 above, we apply a group_by using subject and activity, and then summarise using a "~ mean(.)" lambda.  The result is a data set called tidyData that has the average of every measurement in cleanedData, grouped by subject and activity.  This accomplishes Step 5 of the assignment, which says that run_analysis.R "creates a second, independent tidy data set with the average of each variable for each activity and each subject."

6. **Prints Out TidyData To A Text File:** Finally, the code prints out the tidyData data set to a text file so that it can be submitted for this assignment or otherwise reviewed.  The script also includes a load function that allows a user to load the tidyData.txt file back in, for easy review within R itself, if desired (please see README file for instructions).


# Description Of The Data

This section gives details on what the variables themselves mean, by describing each component.

* **Time** denotes it's a time domain signal

* **Frequency** denotes that a Fast Fourier Transform was applied to the signal

* **Accelerometer** means that an accelerometer signal was used

* **Gyroscope** means that a gyroscope signal was used

* **Body** indicates a body movement acceleration signal

* **Gravity** indicates a gravity acceleration signal

* **Jerk** denotes a jerk signal

* **Magnitude** denotes the Euclidean norm magnitude

* **Mean** denotes the arithmatic mean

* **Std** denotes the usual standard deviation

* **X/Y/Z** denote the axis of movement