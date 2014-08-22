# Get the data and unzip it
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawData <- "data.zip"
if (!file.exists(rawData)) download.file(fileUrl,destfile=rawData,mode="wb")
rawDir <- "UCI HAR Dataset"
if (!file.exists(rawDir)) unzip(rawData)

# Set the working directory
setwd("./UCI HAR Dataset")

# Create a folder to store the combined Train and Test data
allDir <- "all"
if (!file.exists(allDir)) dir.create(allDir)

# Get all variables in text file features
features <- read.table("features.txt", colClasses=c("integer","character"))
features <- features[,2]  # features: character vector (not factor since colClasses is specified)

# Read various files
subject_test <- read.table("test/subject_test.txt",sep="\t")
activity_test <- read.table("test/y_test.txt",sep="\t")
subject_train <- read.table("train/subject_train.txt",sep="\t")
activity_train <- read.table("train/y_train.txt",sep="\t")
activity_label <- read.table("activity_labels.txt",sep=" ")  # data.frame with 2 columns

# Combine the Train and the Test data
subject <- rbind(subject_train, subject_test)  # data.frame of all subjects
names(subject) <- "subject"
activity <- rbind(activity_train, activity_test)  # data.frame of all activities
names(activity) <- "activity"
rm(list=c(ls(pattern=".*_test"),ls(pattern=".*_train")))  # keep useful variables only

# Save to files in "all" folder
write.table(subject,"all/subject.txt",row.names=FALSE)
write.table(activity,"all/activity.txt",row.names=FALSE)

# Read the Test data file
x_test <- read.table("test/X_test.txt", colClasses="numeric")
## if readLines is used as below, it requires more processing.
## x <- readLines("test/X_test.txt")
## n <- length(x)  # number of obs. 2947L
## x <- unlist(strsplit(x,split=" "))  # extract numbers from a string
## x <- as.numeric(x[nchar(x[1:length(x)])!=0])  # remove empty string
## dim(x) <- c(n,length(x)/n)  # convert to matrix
## x_test <- as.data.frame(x)  # convert to data.frame

# Read the Train data file
x_train <- read.table("train/X_train.txt", colClasses="numeric")
## if readLines is used as below, it requires more processing.
## x <- readLines("train/X_train.txt")
## n <- length(x)  # number of obs. 7352L
## x <- unlist(strsplit(x,split=" "))  # extract numbers from a string
## x <- as.numeric(x[nchar(x[1:length(x)])!=0])  # remove empty string
## dim(x) <- c(n,length(x)/n)  # convert to matrix
## x_train <- as.data.frame(x)  # convert to data.frame

x <- rbind(x_train,x_test)  # bind train and test X
names(x) <- features  # add column names
write.table(x,"all/X.txt",sep="\t",row.name=FALSE)
rm(x_test, x_train)  # remove variables

# The following is to combine the Train and Test data in folder Inertial Signals
### It isn't needed for this project so I added 'if (FALSE)' block to skip them
if (FALSE)
{ ### start of block ###
dirTest <- "test/Inertial Signals/"
dirTrain <- "train/Inertial Signals/"
dirAll <- "all/Signals"  # dir including all data
if (!file.exists(dirAll)) dir.create(dirAll)  # create the folder

# Get the file names
fileTest <- dir(dirTest)  # all files in the directory
nFiles <- length(fileTest)  # number of files
fileTrain <- dir(dirTrain)

# Work on each data file at a time
for (counter in 1:nFiles) {
    # filename without test
    fileName <- substr(fileTest[counter],1,nchar(fileTest[counter])-9)
    fileName <- paste(fileName,".txt",sep="")  # add .txt

    # Read the data from the Test file
    x_test <- read.table(paste(dirTest,fileTest[counter],sep=""), colClasses="numeric")

    # Read the data from the Train file
    x_train <- read.table(paste(dirTrain,fileTrain[counter],sep=""), colClasses="numeric")

    # Combine two data frames
    y <- rbind(x_train,x_test)
    names(y) <- c(1:128)  # add column names
    # Write to file
    write.table(y,file=paste(dirAll,fileName,sep="/"),sep="\t",row.name=FALSE)
}
# Remove unnecessary variables
rm(list=c("fileTest","fileTrain","y","fileName","counter","nFiles"))

} ### end of skip block ###

# Find the columns with mean and standard deviation in features
found <- grep("mean|std",features)  # including meanFreq()
## found <- grep("mean[(]|std",features)  # not including meanFreq()

# Extract the mean and std data from x to xFound
xFound <- x[,found]  # Extract the data from x to xFound
names(xFound) <- features[found]  # Add the names to the columns
# Combine the activity, the subject and the data into one dataset xFound
xFound <- cbind(activity=as.character(activity_label[activity[,1],2]),subject=subject,xFound)
# Save the variables to a text file for CodeBook
write.table(cbind(1L:length(found), data.frame(features[found])), file="features_avg.txt", row.names=FALSE, col.names=FALSE)
# Remove unnecessary variables
rm(x,activity,subject,activity_label)

# Load the package to make tidy data
library(reshape2)

# Use melt to form a tidy dataset
xFoundMelt <- melt(xFound, id.vars=c("activity","subject"), measure.vars=features[found])

# Use dcast to get the average of each variable by each activity and each subject
avg <- dcast(xFoundMelt, activity + subject ~ variable, mean)

# Use melt to form a tidy dataset of the average
avgMelt <- melt(avg,id=c("activity","subject"), measure.vars=features[found])

# Write the output to a file "average.txt" without row.name, using default sep
write.table(avgMelt, file="average.txt", row.name=FALSE)
