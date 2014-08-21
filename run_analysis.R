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
features <- unlist(strsplit(readLines("features.txt"),split=" "))  # unlist to make a vector
features <- features[c(seq(from=2, to=length(features), by=2))]  # pick the names only

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
x <- readLines("test/X_test.txt")
n <- length(x)  # number of obs. 2947L
x <- unlist(strsplit(x,split=" "))  # extract numbers from a string
x <- as.numeric(x[nchar(x[1:length(x)])!=0])  # remove empty string
dim(x) <- c(n,length(x)/n)  # convert to matrix
x_test <- as.data.frame(x)  # convert to data.frame
names(x_test) <- features  # add column names

# Read the Train data file
x <- readLines("train/X_train.txt")
n <- length(x)  # number of obs. 7352L
x <- unlist(strsplit(x,split=" "))  # extract numbers from a string
x <- as.numeric(x[nchar(x[1:length(x)])!=0])  # remove empty string
dim(x) <- c(n,length(x)/n)  # convert to matrix
x_train <- as.data.frame(x)  # convert to data.frame
names(x_train) <- features  # add column names

x <- rbind(x_train,x_test)  # bind train and test X
write.table(x,"all/X.txt",sep="\t",row.name=FALSE)

# The following is to combine the Train and Test data in folder Inertial Signals
### It is not needed for this project so I added 'if (FALSE)' block to skip them
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
    x_test <- readLines(paste(dirTest,fileTest[counter],sep=""))
    n <- length(x_test)
    x_test <- unlist(strsplit(x_test,split=" "))
    x_test <- as.numeric(x_test[nchar(x_test[1:length(x_test)])!=0])
    dim(x_test) <- c(n,length(x_test)/n)  # convert to matrix
    x_test <- as.data.frame(x_test)  # convert to data.frame

    # Read the data from the Train file
    x_train <- readLines(paste(dirTrain,fileTrain[counter],sep=""))
    n <- length(x_train)
    x_train <- unlist(strsplit(x_train,split=" "))
    x_train <- as.numeric(x_train[nchar(x_train[1:length(x_train)])!=0])
    dim(x_train) <- c(n,length(x_train)/n)
    x_train <- as.data.frame(x_train)

    # Combine two data frames
    y <- rbind(x_train,x_test)
    names(y) <- c(1:128)  # add column names
    # Write to file
    write.table(y,file=paste(dirAll,fileName,sep="/"),sep="\t",row.name=FALSE)
}
# Remove unnecessary variables
rm(list=c("x_train","x_test","fileTest","fileTrain","n","y","fileName"))

} ### end of skip block ###

# Find the columns with mean and standard deviation in features
found <- grep("mean|std",features)  # including meanFreq()
  # found <- grep("mean[(]|std",features)  # not including meanFreq()

# Extract the mean and std data from x to xFound
xFound <- x[,found]  # Extract the data from x to xFound
names(xFound) <- features[found]  # Add the names to the columns
# Combine the activity, the subject and the data into one dataset xFound
xFound <- cbind(activity=as.character(activity_label[activity[,1],2]),subject=subject,xFound)

# Load the package to make tidy data
library(reshape2)

# Use melt to form a tidy dataset
xFoundMelt <- melt(xFound,id.vars=c("activity","subject"),measure.vars=features[found])

# Use dcast to get the average of each variable by each activity and each subject
avg <- dcast(xFoundMelt, activity + subject ~ variable, mean)

# Use melt to form a tidy dataset of the average
avgMelt <- melt(avg,id=c("activity","subject"),measure.vars=features[found])

# Write the output to a file "average.txt" without row.name, using default sep
write.table(avgMelt,file="average.txt",row.name=FALSE)
