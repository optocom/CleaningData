fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawData <- "data.zip"
if (!file.exists(rawData)) download.file(fileUrl,destfile=rawData,mode="wb")
rawDir <- "UCI HAR Dataset"
if (!file.exists(rawDir)) unzip(rawData)
setwd("./UCI HAR Dataset")

allDir <- "all"
if (!file.exists(allDir)) dir.create(allDir)

features <- strsplit(readLines("features.txt"),split=" ")
features <- unlist(features)
features <- features[c(seq(from=2, to=length(features), by=2))]

subject_test <- read.table("test/subject_test.txt",sep="\t")
activity_test <- read.table("test/y_test.txt",sep="\t")
subject_train <- read.table("train/subject_train.txt",sep="\t")
activity_train <- read.table("train/y_train.txt",sep="\t")
activity_label <- read.table("activity_labels.txt",sep=" ")

subject <- rbind(subject_train, subject_test)
names(subject) <- "subject"
activity <- rbind(activity_train, activity_test)
names(activity) <- "activity"
rm(list=c(ls(pattern=".*_test"),ls(pattern=".*_train")))

write.table(subject,"all/subject.txt",sep="\t",row.names=FALSE)
write.table(activity,"all/activity.txt",sep="\t",row.names=FALSE)

x <- readLines("test/X_test.txt")
n <- length(x)  # number of obs. 2947L
x <- unlist(strsplit(x,split=" "))  # extract numbers from a string
x <- as.numeric(x[nchar(x[1:length(x)])!=0])  # remove empty string
dim(x) <- c(n,length(x)/n)  # convert to matrix
x_test <- as.data.frame(x)  # convert to data.frame
names(x_test) <- features  # add column names

x <- readLines("train/X_train.txt")
n <- length(x)  # number of obs.
x <- unlist(strsplit(x,split=" "))  # extract numbers from a string
x <- as.numeric(x[nchar(x[1:length(x)])!=0])  # remove empty string
dim(x) <- c(n,length(x)/n)  # convert to matrix
x_train <- as.data.frame(x)  # convert to data.frame
names(x_train) <- features  # add column names

x <- rbind(x_train,x_test)  # bind train and test X
write.table(x,"all/X.txt",sep="\t",row.name=FALSE)

dirTest <- "test/Inertial Signals/"
dirTrain <- "train/Inertial Signals/"
dirAll <- "all/Signals"  # dir including all data
if (!file.exists(dirAll)) dir.create(dirAll)

fileTest <- dir(dirTest)  # all files in the directory
nFiles <- length(fileTest)  # number of files
fileTrain <- dir(dirTrain)
#data <- vector("list",length=nFiles)  # empty list of data
for (counter in 1:nFiles) {
    fileName <- substr(fileTest[counter],1,nchar(fileTest[counter])-9)
    fileName <- paste(fileName,".txt",sep="")
    x_test <- readLines(paste(dirTest,fileTest[counter],sep=""))
    n <- length(x_test)
    x_test <- unlist(strsplit(x_test,split=" "))
    x_test <- as.numeric(x_test[nchar(x_test[1:length(x_test)])!=0])
    dim(x_test) <- c(n,length(x_test)/n)
    x_test <- as.data.frame(x_test)

    x_train <- readLines(paste(dirTrain,fileTrain[counter],sep=""))
    n <- length(x_train)
    x_train <- unlist(strsplit(x_train,split=" "))
    x_train <- as.numeric(x_train[nchar(x_train[1:length(x_train)])!=0])
    dim(x_train) <- c(n,length(x_train)/n)
    x_train <- as.data.frame(x_train)

    y <- rbind(x_train,x_test)
    names(y) <- c(1:128)
    write.table(y,file=paste(dirAll,fileName,sep="/"),sep="\t",row.name=FALSE)

#    data[counter] <- list(x)
#    names(data[counter]) <- fileName
}
rm(list=c("x_train","x_test","fileTest","fileTrain","n","y","fileName"))


found <- sort(c(grep("mean",features),grep("std",features)))
xFound <- x[,found]
names(xFound) <- features[found]
xFound <- cbind(subject=subject,activity=as.character(activity_label[activity[,1],2]),xFound)

library(reshape2)

xFoundMelt <- melt(xFound,id=c("activity","subject"),measure.vars=features[found])
avg <- dcast(xFoundMelt, activity + subject ~ variable, mean)
avgMelt <- melt(avg,id=c("activity","subject"),measure.vars=features[found])
write.table(avgMelt,file="average.txt",row.name=FALSE)
