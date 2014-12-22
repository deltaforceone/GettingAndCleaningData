# Note: The following code and filepaths assume that the "UCI HAR Dataset" folder
# is located in the user's working directory. Hence, the "features.txt" file would be
# located as follows: "./UCI HAR Dataset/features.txt"

#-------------------- LOAD TEXT FILES ----------------------------
# Load Activity Codes (1-6) and corresponing Labels to data frame
DF_ActivityLabels <- read.table(file="./UCI HAR Dataset/activity_labels.txt", header = FALSE, sep = " ", quote = "")
# Load Feature Codes (1-561) and corresponing (original) Labels to data frame
DF_Features <- read.table(file="./UCI HAR Dataset/features.txt", header = FALSE, sep = " ", quote = "")

# Load Training Data into data frames
DF_SubjectTrain <- read.table(file="./UCI HAR Dataset/train/subject_train.txt", header = FALSE, sep = " ", quote = "")
DF_TrainingLabels <- read.table(file="./UCI HAR Dataset/train/y_train.txt", header = FALSE, sep = " ", quote = "")
DF_TrainingData <- read.table(file="./UCI HAR Dataset/train/X_train.txt", header = FALSE, sep = "", quote = "")

# Load Testing Data into data frames
DF_SubjectTest <- read.table(file="./UCI HAR Dataset/test/subject_test.txt", header = FALSE, sep = " ", quote = "")
DF_TestingLabels <- read.table(file="./UCI HAR Dataset/test/y_test.txt", header = FALSE, sep = " ", quote = "")
DF_TestingData <- read.table(file="./UCI HAR Dataset/test/X_test.txt", header = FALSE, sep = "", quote = "")
#-----------------------------------------------------------------

# Get the variable names & indices which represent measurements on the mean
mean_names <- grep(pattern="mean()", x=DF_Features$V2, value = TRUE, fixed=TRUE)
mean_codes <- DF_Features$V1[match(mean_names,DF_Features$V2)]
# Correct some errors in the original names:
# 1. remove "()" characters
mean_names <- gsub("[()]","",mean_names)
# 2. replace any "-" characters with "."
mean_names <- gsub("-",".",mean_names)
# 3. correct the error in the names where "Body" is repeated twice
mean_names <- gsub("BodyBody","Body",mean_names)

# Get the variable names & indices which represent measurements on the standard deviation
std_names <- grep(pattern="std()", x=DF_Features$V2, value = TRUE, fixed=TRUE)
std_codes <- DF_Features$V1[match(std_names,DF_Features$V2)]
# Correct some errors in the original names:
# 1. remove "()" characters
std_names <- gsub("[()]","",std_names)
# 2. replace any "-" characters with "."
std_names <- gsub("-",".",std_names)
# 3. correct the error in the names where "Body" is repeated twice
std_names <- gsub("BodyBody","Body",std_names)

# Create Training dataset with only the mean & std measurements as variables
DF_Training <- DF_TrainingData[,c(mean_codes,std_codes)]
# Add the dataframes containing the volunteer and activity labels to the Training dataset
DF_Training <- cbind(DF_SubjectTrain,
                     DF_TrainingLabels,
                     DF_Training)
# Give this dataframe descriptive names
names(DF_Training) <- c("Volunteer","Activity",mean_names,std_names)
# Use the Activity Labels dataset (from "activity_labels.txt") to convert Activity from codes (int)
# to names (char)
DF_Training$Activity <- DF_ActivityLabels$V2[match(DF_TrainingLabels$V1,DF_ActivityLabels$V1)]

# Create Testing dataset with only the mean & std measurements as variables
DF_Testing <- DF_TestingData[,c(mean_codes,std_codes)]
# Add the dataframes containing the volunteer and activity labels to the Testing dataset
DF_Testing <- cbind(DF_SubjectTest,
                    DF_TestingLabels,
                    DF_Testing)
# Give this dataframe descriptive names
names(DF_Testing) <- c("Volunteer","Activity",mean_names,std_names)
# Use the Activity Labels dataset (from "activity_labels.txt") to convert Activity from codes (int)
# to names (char)
DF_Testing$Activity <- DF_ActivityLabels$V2[match(DF_TestingLabels$V1,DF_ActivityLabels$V1)]

# Merge the Training and Testing dataframes. Use rbind(), since both datasets have identical column
# structures
DF_MergedDataset <- rbind(DF_Training,DF_Testing)

# Step 5: Create the Tidy data set with the average of each variable for each subject ("Volunteer")
# and activity ("Activity"), using the aggregate() {stats} function
DF_Tidy <- aggregate(x = DF_MergedDataset[,c(mean_names,std_names)], 
                    by = list(DF_MergedDataset$Activity,DF_MergedDataset$Volunteer), 
                    FUN = "mean")
# Switch the 1st 2 (grouping) variables so that Volunteer is the first column
DF_Tidy[,1:2] <- DF_Tidy[,2:1]
names(DF_Tidy)[1:2] <- c("Volunteer","Activity")

# I used the following line to create the "TidyData.txt" text file in my working directory
# This is the file that I have uploaded in my assigment submission
##  write.table(DF_Tidy, file = "TidyData.txt", row.names = FALSE)

# You can use the command:
# read.table("TidyData.txt", header = TRUE)
# to read the file to a data frame (assuming it is located in your home directory)

