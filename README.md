Getting and Cleaning Data
=========================

   In this repository optocom/CleaningData there are a few files as follows:

* _README.md_ -- this file to briefly explain this project and how the script works.
* _CodeBook.md_ -- to describe the variables, the data and the process to collect and to clean up the data.
* _run_analysis.R_ -- the R script to perform all tasks.
* _average.txt_ -- the final tidy dataset output from the R script.

Project
-------

   The goal of this project is to prepare tidy dataset.

   One of the most exciting areas in all of data science right now is wearable computing - see for example [**this article**](http://www.insideactivitytracking.com/data-science-activity-tracking-and-the-battle-for-the-worlds-top-sports-brand/). 

   Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at [**this site**](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) where the original data was obtained.

   The data of a zip file of this project is from [**this link**](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).

R Script
--------

   The R script performs the following tasks:

1. Collects the raw data.
1. Imports and merges the training and the test sets to create one data set.
1. Extracts only the measurements on the mean and standard deviation for each measurement; Appropriately labels the data set with descriptive variable names.
1. Uses descriptive activity names to name the activities in the data set.
1. Stores the variable names for use in code book.
1. Loads the necessary library.
1. Generates a tidy data set for calculating the average of each variable for each activity and each subject.
1. Computes the averages by using the tidy dataset.
1. Creates a second, independent tidy data set from the output of the previous step.

#### :one: Collecting Data and Setting Up Directory

   `download.file` is used to download the data file from the given URL. The zip was unzipped (`unzip`) to the same directory and the working directory was set to the folder _UCI HAR Dataset_.

#### :two: Importing and Merging Datasets

   `read.table` were used to read the datasets.

   `rbind` was used to append the test dataset to the training dataset to create complete datasets. The datasets were saved to files in folder _all_.

   The variable or data frame _x_ contains the complete dataset. The column names from _features_ were added to the data frame _x_.

#### :three: Extracting Mean and Standard Deviation from Features and Adding to Dataset

   `grep` with the regexp pattern was used to find the locations of the means and the standard deviations in the variable _features_. The locations or indexes were stored in variable _found_. The results were extracted from variable _x_ by using the indexes _found_ and stored in the data frame _xFound_. The column names from _features_ with indexes _found_ were added to _xFound_.

#### :four: Adding Condition Columns to Dataset

   `cbind` was used to add columns _activity_ and _subject_ to the variable _xFound_. The descriptive names of the activity were obtained from variable *activity_label*.

#### :five: Save Variable Names for CodeBook

   `write.table` was used to save the variable names to a file, which will be used for the CodeBook. The output is a file having an integer column plus a character column.

#### :six: Loading the Library

   _reshape2_ was loaded to create the tidy dataset and to calculate the averages.

#### :seven: Creating Tidy Dataset

   `melt` was used to create the tidy data _xFoundMelt_.

#### :eight: Computing the Averages

   `dcast` was used to calculate the averages from the tidy dataset. The results in data frame _avg_ have values in multiple columns.

## (ignore the following paragraph)
#### :nine: Preparing the Final Output

   `melt` was used again to create the second tidy data _avgMelt_, which was saved to file _average.txt_ without row names. The columns of the data are as follows:

   1. Activity
   1. Subject
   1. Variable
   1. Value

:smile:
