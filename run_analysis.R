# run_analisys.R
# Author: Henk van de Ridder
# Subject: Coursera Course: get-data-013, CourseProject
# 
# This script does the 5 steps in creating a tidy dataset
# for the "Human Activity Recognition Using Smartphones Data Set"
#

# needed libraries
library("dplyr")
library("reshape2")

# initialization
setwd("H:/Datascientist/03-GetData/CourseProject")

# base directory with the datasets (unzipped files)
rawDir="UCI_HAR_DATASET"

# resulting data (saved in each step)
stepsDir="steps_data"
if (!file.exists(stepsDir)) {
  dir.create(stepsDir)
}

##############################################################
# doStep1: merging the data sets
##############################################################
doStep1 <- function(fname) {
  # read test set
  set1 <- step1CombineRaw("test")
  # read train set
  set2 <- step1CombineRaw("train")
  # combine both
  mergedSet <- rbind(set1,set2)

  # write step result to file
  if (file.exists(fname)) {
    unlink(fname)
  }
  write.table(mergedSet, file = fname)
}

##############################################################
# step1CombineRaw: 
# - reading either train or test data
# - merging 
#   - X (measurements), 
#   - Y (activities),
#   - subject data
##############################################################
step1CombineRaw <- function(setName){
  # print(sprintf("start step1 for: %s %s",rawDir,setName))
  
  # fill n <- 10 for quicktesting
  n <- -1
  
  # measurements
  f1 <- sprintf("%s/%s/X_%s.txt",rawDir,setName,setName)
  dataX <- read.csv(f1,header=FALSE, sep="",nrows=n, strip.white = TRUE)
  #print(dataX[1,])
  
  # subjects
  f2 <- sprintf("%s/%s/subject_%s.txt",rawDir,setName,setName)
  dataS <- read.csv(f2,header=FALSE, sep="",nrows=n, strip.white = TRUE)
  names(dataS) <- c("Subject")
  #print(dataS)
  
  # activities
  f3 <- sprintf("%s/%s/Y_%s.txt",rawDir,setName,setName)
  dataA <- read.csv(f3,header=FALSE, sep="",nrows=n, strip.white = TRUE)
  names(dataA) <- c("Actnr")
  #print(dataA)
  
  # merge them to one data set
  all <- cbind(dataS,dataA,dataX)
  # print(all[1:2,1:5])
  
  return(all)
  
}

##############################################################
# doStep2: extracting mean() and std() measurements
##############################################################
doStep2 <- function(fIn,fOut) {
  
  # read previous step results
  set1 <- read.table(fIn)
  #print(set1[c(1,100,500),c(1,2,5)])
  
  # select the mean() and std() columns, see features.txt
  # Remark: could be made more sophisticated in selecting 
  #         both column names ending at mean() or std()
  #         See step 4
  set2 <- select(set1,Subject,Actnr,
                V1,V2,V3,V4,V5,V6,
                V41,V42,V43,V44,V45,V46,
                V81,V82,V83,V84,V85,V86,
                V121,V122,V123,V124,V125,V126,
                V161,V162,V163,V164,V165,V166,
                V201,V202,V214,V215,V227,V228,
                V240,V241,V253,V254,
                V266,V267,V268,V269,V270,V271,
                V345,V346,V347,V348,V349,V350,
                V424,V425,V426,V427,V428,V429,
                V503,V504,V516,V517,V529,V530,V542,V543)
  # print(set2[1,])

  # write step result to file
  if (file.exists(fOut)) {
    unlink(fOut)
  }
  write.table(set2, file = fOut)
  
}

##############################################################
# doStep3: use descriptive activity names
##############################################################
doStep3 <- function(fIn,fOut) {

  # read results of previous step
  set2 <- read.table(fIn)
  # print(set2[1:3,])
  
  # read file with activity label names
  fLabels <- sprintf("%s/activity_labels.txt",rawDir)
  actLabels <- read.csv(fLabels,header=FALSE, sep="")
  # print(actLabels)
  
  # check if rows with activty <1 > 6
  # print(set2[which(set2$Actnr < 1),1:5])
  # print(set2[which(set2$Actnr > 6),1:5])
  # nothing found

  # add activity names column to the set
  set3a <- within(set2, { Activity = actLabels[Actnr,2] })
  # print(set3a[108:114,"Activity"])
  
  # place Activity column as second column 
  set3b <- select(set3a,Subject,Activity,starts_with("V"))
  # print(set3b[1:3,])
  
  # write step result to file
  if (file.exists(fOut)) {
    unlink(fOut)
  }
  write.table(set3b, file = fOut)

}

##############################################################
# doStep4: label the variables with descriptive names
##############################################################
doStep4 <- function(fIn,fOut) {

  # read results of previous step
  set3 <- read.table(fIn)
  #print(set3[1:1,])
  
  # read Lablenames from file
  fLabels <- sprintf("%s/features.txt",rawDir)
  feaLabels <- read.csv(fLabels,header=FALSE, sep="")
  #print(FeaLabels)
  
  # make friendly lable names: remove ()-, characters
  friendlyLabels <- gsub("-","",gsub("[(),]","",feaLabels$V2))
  #print(friendlyLabels)
  
  # extract current label names 
  set3names <- names(set3)
  #print(set3names)

  # function replacing one Vnnn columnname with friendlYLabelname
  # e.g. V543 with fBodyBodyGyroJerkMagstd
  makeNames <- function(oldName) {
    newName <- oldName
    if (substr(oldName,1,1) == "V") {
      fldNr = as.integer(substr(oldName,2,nchar(oldName)))
      newName = friendlyLabels[fldNr]
    } 
    
    return(newName)
  }

  # make all columnnames friendly
  set3Newnames <- as.vector(sapply(set3names,makeNames))
  #print(set3Newnames)

  #replace V-columnnnames with friendlynames
  names(set3) <- set3Newnames
  #print(set3[1:2,])

  # for checking rows and cols
  #print(nrow(set3)) #10299
  #print(ncol(set3)) #68
  
  # write step result to file
  if (file.exists(fOut)) {
    unlink(fOut)
  }
  write.table(set3, file = fOut)
  
}

##############################################################
# doStep5: Form tidy data set
##############################################################
doStep5 <- function(fIn,fOut) {

  # read results of previous step
  set5 <- read.table(fIn)
  
  # melt set to split id variables and measurements
  set5Melt <- melt(set5,id=c("Subject","Activity"))
  # print(head(set5Melt,n=5))
  # print(tail(set5Melt,n=5))
  
  # casting data frame to variable averages 
  # for each subject and activity combination
  set5Data <- dcast(set5Melt,Subject + Activity ~ variable, mean)

  # information output
  # print(set5Data[1:10,])
  
  # write step result to file
  if (file.exists(fOut)) {
    unlink(fOut)
  }
  write.table(set5Data, file = fOut)
  
}

##############################################################
# main programm
##############################################################

f1 <- sprintf("%s/%s",stepsDir,"step1.RData")
doStep1(f1)
f2 <- sprintf("%s/%s",stepsDir,"step2.RData")
doStep2(f1,f2)
f3 <- sprintf("%s/%s",stepsDir,"step3.RData")
doStep3(f2,f3)
f4 <- sprintf("%s/%s",stepsDir,"step4.RData")
doStep4(f3,f4)
f5 <- sprintf("%s/%s",stepsDir,"step5.RData")
doStep5(f4,f5)

# final result
fresult <- sprintf("%s","tidy_dataset.txt")
results <- read.table(f5)
if (file.exists(fresult)) {
  unlink(fresult)
}
write.table(results, file = fresult, row.name = FALSE)

## THE END ###