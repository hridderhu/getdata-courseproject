# getdata-courseproject
CourseProject of Course Getting and Cleaning Data

## run\_analysis.R
The R-script for the getdata-courseproject fullfills the requirement for doing 5 steps in transforming the "Human Activity Recognition Using SmartPhones Data Set" into a tidy data set with the average measurements values for each combination of activity and human subject.

This transformation has been done in 5 steps:
- 1) Merging the training and the test sets to create one data set consisting of subject-numbers (1-30), activity-numbers(1-6) and 561 measurements 
- 2) Extracting only the measurements on the mean and standard deviation for each measurement. Resulting 66 measurements
- 3) Using descriptive activity names to name the activities in the data set. The names are extracted from the "activity\_labels.txt" file
- 4) Labeling the data set with descriptive variable names. The names are extracted from the "features.txt" file
- 5) Creating a tidy data set with the average of each variable for each activity and each subject The data is saved in "tidy\_dataset.txt"

Each step is implemented in it's own function: doStep1() - doStep5(). Each steps ends with saving the step results (write\_table) into a datafile named: step1.RData - step5.RData. From doStep2() the function starts first by reading the results of the previous step.

The main part of the R-script calls each doStepx() functions, ending with writing the "tidy\_dataset.txt" file.

### Step 1: merging raw sets
This step combines the raw datasets: test and train. These datasets both have the same structure so a function *step1CombineRaw()* is called twice. Then both datasets are merged by rbind(). The merged dataframe is a combination of the Subjectnumber, Activitynumber and 561 measurements

The function *step1CombineRaw()* first fills a dataframe with the measurements data (file X\_nnnn.txt (nnnn=train or test). The raw measurement data consists of lines with each 561 measurement values, separated with a space, so reading with read.csv() is possible.

Then the subjectnumbers are read from the subject\_nnnn.txt file. Each line correspondents with the measurement line.

The same is done with the activitynumber from y\_nnnn.txt.

The three datasets are combined into one dataframe using the cbind() function. So ultimaty a dataset is created with the following columns: Subject, Actnr, V1, ..., V561. 

### Step 2: extracting mean and std measurements
This steps extract only the measurements with the mean and std values.
The columns which have the mean and std measurements can be found in the "features.txt" file, the name ends with mean() or std(). 
The dataframe column names are "V1" upto "V561", where the number-part of the column name points to the variable-name in "features.txt". Using a select() function extracts the relevant column names and places them into the resulting dataframe for step 2.
Ultimately 66 measurements of 561 are extracted.

### Step 3: use descriptive activity names
This step changes the activitynumber column (Actnr) with the activityname (Activity). 
First the activitynames are read from the "activity\_labels.txt" file and placed in a datafame: actLabels. 
Using the within() functions a new column Activity is added to the dataframe. The Activity name is extracted from the dataframe actLables by using the Activity number (Actnr) as key.
Using the select() function selects the relevant columns: Subject, Activity and the measurement columns which names start with the "V".

### Step 4: label the variables
This step labels each measurement value with an appropiate name. The name is extracted from the "features.txt" file.
First the measurement names as read from from the "features.txt" file and placed in a dataframe: feaLabels. Because these labels are somewhat unclear: each name is beautified in removing the "(", ")", "-" and "," symbols and placed in "friednlyLabels" dataframe
The measurements colummn-names are formatted like V561. The numberpart "561" points to the variable name in the "features.txt" file. Using a function: makeNames() and sapply() replaces each column-name with the "friendlyLabel" name.

### step 5: create tidy data set
This step converts the measurements in calculating the average for each combination of subject and activity. 
First: using the melt() function the data is splitted in id-variables (Subject and activity) and measurement values.
Next using the dcast() function the melted data is converted to the averages. The parameter "Subject + Activity ~ variable" handles the combination of Subject and Activity as base for calculation the mean() for each variable.
This resuls into a tidydata of 180 rows and 68 variables:
- 180 rows is 30 subjects * 6 activities
- 68 variables: 1 subject + 1 activitie + 66 measurements 


