# Author: Ali Khaddour

# Objective:
# 1. Combine training and test datasets into a unified dataset.
# 2. Extract measurements for mean and standard deviation.
# 3. Assign descriptive activity names to the dataset.
# 4. Label the dataset with clear variable names.
# 5. Generate a tidy dataset with the average of each variable grouped by activity and subject.

# Load necessary libraries and download data
library(data.table)
library(reshape2)

working_dir <- getwd()
dataset_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataset_url, file.path(working_dir, "dataset.zip"))
unzip("dataset.zip")

# Load activity labels and features
activity_labels <- fread(file.path(working_dir, "UCI HAR Dataset/activity_labels.txt"),
                         col.names = c("ClassID", "Activity"))
features <- fread(file.path(working_dir, "UCI HAR Dataset/features.txt"),
                  col.names = c("Index", "FeatureName"))
selected_features <- grep("(mean|std)\\(\\)", features$FeatureName)
selected_feature_names <- gsub("[()]", "", features[selected_features, FeatureName])

# Load training dataset
training_data <- fread(file.path(working_dir, "UCI HAR Dataset/train/X_train.txt"))[, selected_features, with = FALSE]
setnames(training_data, names(training_data), selected_feature_names)
training_activities <- fread(file.path(working_dir, "UCI HAR Dataset/train/Y_train.txt"),
                             col.names = "ActivityID")
training_subjects <- fread(file.path(working_dir, "UCI HAR Dataset/train/subject_train.txt"),
                           col.names = "SubjectID")
training_set <- cbind(training_subjects, training_activities, training_data)

# Load test dataset
test_data <- fread(file.path(working_dir, "UCI HAR Dataset/test/X_test.txt"))[, selected_features, with = FALSE]
setnames(test_data, names(test_data), selected_feature_names)
test_activities <- fread(file.path(working_dir, "UCI HAR Dataset/test/Y_test.txt"),
                         col.names = "ActivityID")
test_subjects <- fread(file.path(working_dir, "UCI HAR Dataset/test/subject_test.txt"),
                       col.names = "SubjectID")
test_set <- cbind(test_subjects, test_activities, test_data)

# Combine training and test datasets
full_dataset <- rbind(training_set, test_set)

# Replace activity IDs with descriptive names
full_dataset$ActivityID <- factor(full_dataset$ActivityID,
                                  levels = activity_labels$ClassID,
                                  labels = activity_labels$Activity)

# Reshape dataset to create a tidy format
full_dataset$SubjectID <- as.factor(full_dataset$SubjectID)
melted_data <- melt(full_dataset, id.vars = c("SubjectID", "ActivityID"))
tidy_data <- dcast(melted_data, SubjectID + ActivityID ~ variable, mean)

# Save the tidy dataset to a file
fwrite(tidy_data, file = "tidy_dataset.txt", quote = FALSE)
