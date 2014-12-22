GettingAndCleaningData
======================

Repo for Johns Hopkins : Getting and Cleaning Data assignment 

##Note
The code and filepaths in the attached "run_analysis.R" file assume
that the "UCI HAR Dataset" folder is located in the user's working directory. 
Hence, the "features.txt" file would be located as follows: "./UCI HAR Dataset/features.txt"

###Step 1: Loading the text files as data frames
The code first loads the following text files from the "UCI HAR Dataset" directory into data frames:

dataframe | text file | description
--------- | --------- | -----------
DF_ActivityLabels | "activity_labels.txt" | Activity Codes (1-6) and corresponing Labels
DF_Features | "features.txt" | Feature Codes (integers, 1-561) and corresponing (original) Labels
DF_SubjectTrain | "subject_train.txt" | 1 column of integers (1-30) identifying the volunteer for each measurement in training set
DF_TrainingLabels | "y_train.txt" | 1 column of integers (1-6) identifying the activity for each measurement in training set
DF_TrainingData | "X_train.txt" | 561 columns of measurement data, one for each feature variable in training set
DF_SubjectTest | "subject_test.txt" | 1 column of integers (1-30) identifying the volunteer for each measurement in testing set
DF_TestingLabels | "y_test.txt" | 1 column of integers (1-6) identifying the activity for each measurement in testing set
DF_TestingData | "X_test.txt" | 561 columns of measurement data, one for each feature variable in testing set

### Step 2: Get the variable names & indices which represent measurements on the mean
* mean_names <- grep(pattern="mean()", x=DF_Features$V2, value = TRUE, fixed=TRUE)
* mean_codes <- DF_Features$V1[match(mean_names,DF_Features$V2)]

### Step 2a: Correct some errors in the original names:
* remove "()" characters
  * mean_names <- gsub("[()]","",mean_names)
* replace any "-" characters with "."
  * mean_names <- gsub("-",".",mean_names)
* correct the error in the names where "Body" is repeated twice
  * mean_names <- gsub("BodyBody","Body",mean_names)

### Step 3: Get the variable names & indices which represent measurements on the standard deviation
* std_names <- grep(pattern="std()", x=DF_Features$V2, value = TRUE, fixed=TRUE)
* std_codes <- DF_Features$V1[match(std_names,DF_Features$V2)]

### Step 3a: Correct some errors in the original names:
* remove "()" characters
  * std_names <- gsub("[()]","",std_names)
* replace any "-" characters with "."
  * std_names <- gsub("-",".",std_names)
* correct the error in the names where "Body" is repeated twice
  * std_names <- gsub("BodyBody","Body",std_names)

### Step 4: Create Training dataset with only the mean & std measurements as variables
* DF_Training <- DF_TrainingData[,c(mean_codes,std_codes)]
* Then add the dataframes containing the volunteer and activity labels to the Training dataset
  DF_Training <- cbind(DF_SubjectTrain,
                       DF_TrainingLabels,
                       DF_Training)
* Give this dataframe descriptive names
  names(DF_Training) <- c("Volunteer","Activity",mean_names,std_names)
* Use the Activity Labels dataset (from "activity_labels.txt") to convert Activity from codes (int) to names (char)
  DF_Training$Activity <- DF_ActivityLabels$V2[match(DF_TrainingLabels$V1,DF_ActivityLabels$V1)]

### Step 5: Create Testing dataset with only the mean & std measurements as variables
* DF_Testing <- DF_TestingData[,c(mean_codes,std_codes)]
* Then add the dataframes containing the volunteer and activity labels to the Testing dataset
  DF_Testing <- cbind(DF_SubjectTest,
                      DF_TestingLabels,
                      DF_Testing)
* Give this dataframe descriptive names
  names(DF_Testing) <- c("Volunteer","Activity",mean_names,std_names)
* Use the Activity Labels dataset (from "activity_labels.txt") to convert Activity from codes (int) to names (char)
  DF_Testing$Activity <- DF_ActivityLabels$V2[match(DF_TestingLabels$V1,DF_ActivityLabels$V1)]

### Step 6: Merge the Training and Testing dataframes
#### Use rbind(), since both datasets have identical column structures
DF_MergedDataset <- rbind(DF_Training,DF_Testing)

### Step 7: Create the Tidy data set with the average of each variable for each subject ("Volunteer") and activity ("Activity"), using the aggregate() {stats} function
DF_Tidy <- aggregate(x = DF_MergedDataset[,c(mean_names,std_names)], 
                    by = list(DF_MergedDataset$Activity,DF_MergedDataset$Volunteer), 
                    FUN = "mean")
#### Switch the 1st 2 (grouping) variables so that Volunteer is the first column
DF_Tidy[,1:2] <- DF_Tidy[,2:1]
names(DF_Tidy)[1:2] <- c("Volunteer","Activity")

### Note on writing and reading of the tidy data set
* I used the following line to create the "TidyData.txt" text file in my working directory
  * *write.table(DF_Tidy, file = "TidyData.txt", row.names = FALSE)*
* You can use the command:  *read.table("TidyData.txt", header = TRUE)*
# to read the file to a data frame (assuming it is located in your home directory)
