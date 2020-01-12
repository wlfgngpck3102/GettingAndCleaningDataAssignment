# Running The Assignment Code
To run the assignment, please download this repository and place it in your working directory.

From there, source in the script "run_analysis.R"; if you have placed the downloaded files in your working directory, this should be doable by just typing source("run_analysis.R").

From here, simply execute the function main().  This function collects together all of the embedded functionality in downloading and cleaning the assignment data set.

# Loading In The Tidy Data
To load in the tidyData.txt file, simply execute the function loadTidyData() after having sourced in "run_analysis.R".  This will do a quick check to see if the dataset exists; if it does, it will be loaded in (just assign it to a variable in your work space), and if it doesn't, the code will throw with instructions for you to first run the main() function.

# A Brief Description Of The Functions Run By Main()

The main function executes several underlying functions that perform the various components of the assignment.  Below is a brief description of each:

downloadAndUnzip - This function checks to see if the assignment data has been downloaded and, if it hasn't been, then it downloads the data from the link provided in the assignment description.  Similarly, it checks if the folder has already been unzipped and, if it hasn't, it unzips the data.

loadRawData - This function loads in all of the raw data from the unzipped file, by searching through each of the folders for the relevant file types.  The column names were determined by examination of the data itself and reading the README file and info files; therefore, the column names couldn't be dynamically determined.  The function then aggregates the subject, X, and Y data and merges them into one single data frame.  The output of this function is a list with an activities data frame and a rawData data frame; the latter data frame accomplishes Step 1 of the assignment.

extractMeanAndStd - This function converts rawData to a data table using the dplyr library, and then filters the data by selecting only the columns that contain either "mean" or "std"; this function performs Step 2 of the assignment.

cleanDataNames - This function drastically cleans up the column names and replaces activity code with the actual activity names.  The resulting data set is now consistent with the tidy data principles, and each row and column are now more easily identifiable and understandable.  This function accomplishes both Step 3 and Step 4 of the assignment.

tidyDataPrint - This function groups the input data set by subject and activity, and then applies a mean lambda on each column to accomplish Step 5 of the assignment, where each column now represents the average of that metric.  This function also prints out the tidyData data frame as a txt file and, before executing, it deletes any previously existing tidyData.txt file.
