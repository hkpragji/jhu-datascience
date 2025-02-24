## ----setup, include = FALSE----------------------------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = FALSE)


## ----load-libraries, include = FALSE-------------------------------------------------------------------------------------------------------------
# Load required libraries
library(dplyr)
library(knitr)
library(tinytex)


## ----run-analysis-1, cache = TRUE----------------------------------------------------------------------------------------------------------------
# Create data subdirectory if it does not already exist
if (!file.exists("./assignments/getting-cleaning-data/data")) {
  dir.create("./assignments/getting-cleaning-data/data")
}
# Downlaod and extract the zip folder containing the data
zip_file <- "./assignments/getting-cleaning-data/data/har_dataset.zip"
if (!file.exists(zip_file)) {
  data_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(data_url, destfile = zip_file, mode = "wb")
  unzip(zip_file, exdir = "./data")
}

# List all files in the data directory
list.files("./assignments/getting-cleaning-data/data/UCI HAR Dataset/",
  recursive = TRUE
)


## ----run-analysis-2, cache = TRUE----------------------------------------------------------------------------------------------------------------
# Read test datasets into data frames
test_x <- read.table("assignments/getting-cleaning-data/data/UCI HAR Dataset/test/X_test.txt")
test_y <- read.table("assignments/getting-cleaning-data/data/UCI HAR Dataset/test/y_test.txt")
test_subject <- read.table("assignments/getting-cleaning-data/data/UCI HAR Dataset/test/subject_test.txt")
# Read training datasets into data frames
train_x <- read.table("assignments/getting-cleaning-data/data/UCI HAR Dataset/train/X_train.txt")
train_y <- read.table("assignments/getting-cleaning-data/data/UCI HAR Dataset/train/y_train.txt")
train_subject <- read.table("assignments/getting-cleaning-data/data/UCI HAR Dataset/train/subject_train.txt")
# Read features and activity label datasets into data frames
feature_data <- read.table("assignments/getting-cleaning-data/data/UCI HAR Dataset/features.txt")
activity_labels <- read.table("assignments/getting-cleaning-data/data/UCI HAR Dataset/activity_labels.txt")


## ----run-analysis-3------------------------------------------------------------------------------------------------------------------------------
# Rename column headers appropriately
activities <- activity_labels %>%
  dplyr::rename(activity_id = V1, activity_type = V2)
features <- feature_data %>%
  dplyr::rename(activity_id = V1, activity_type = V2)
subject_test <- test_subject %>%
  dplyr::rename(subject_id = V1)
subject_train <- train_subject %>%
  dplyr::rename(subject_id = V1)
test_y_cleaned <- test_y %>%
  purrr::set_names(colnames(activities[1]))
train_y_cleaned <- train_y %>%
  purrr::set_names(colnames(activities[1]))


## ----run-analysis-4------------------------------------------------------------------------------------------------------------------------------
# First check that the nrow(features) matches ncol(test_x) and ncol(train_x)
feature_count <- features %>%
  dplyr::summarise(n = n()) %>%
  dplyr::pull(n)
col_count_df <- dplyr::tibble(
  dataset = c("test_x", "test_y", "train_x", "train_y"),
  ncols = c(ncol(test_x), ncol(test_y), ncol(train_x), ncol(train_y))
)

if (feature_count == ncol(test_x) && feature_count == ncol(train_x)) {
  
  test_x_cleaned <- test_x %>%
    purrr::set_names(features$activity_type)

  train_x_cleaned <- train_x %>%
    purrr::set_names(features$activity_type)

} else {
  print("The number of observations in the features data frame does not match \n
  the number of variables in the test/train data frames.")
}


## ----run-analysis-5------------------------------------------------------------------------------------------------------------------------------
all_test_merged <- dplyr::bind_cols(
  test_y_cleaned,
  subject_test,
  test_x_cleaned,
  .name_repair = "unique"
)

all_train_merged <- dplyr::bind_cols(
  train_y_cleaned,
  subject_train,
  train_x_cleaned,
  .name_repair = "unique"
)

ml_data <- dplyr::bind_rows(all_test_merged, all_train_merged)


## ----run-analysis-6------------------------------------------------------------------------------------------------------------------------------
columns <- colnames(ml_data)
mean_sd_colnames <- stringr::str_detect(columns, "activity|subject|mean(?!Freq)|std")
ml_data_filtered <- ml_data[, mean_sd_colnames]


## ----run-analysis-7------------------------------------------------------------------------------------------------------------------------------
ml_merged <- ml_data_filtered %>%
  dplyr::left_join(activities,
    by = "activity_id"
  ) %>%
  dplyr::relocate(
    activity_type,
    .after = activity_id
  )


## ----run-analysis-8------------------------------------------------------------------------------------------------------------------------------
# View all variable names in the dataset
colnames(ml_merged)
# Apply transformations directly to variable names
new_colnames <- purrr::map_chr(
  names(ml_merged), ~ .x %>%
    stringr::str_replace_all("^t", "time") %>%
    stringr::str_replace_all("^f", "frequency") %>%
    stringr::str_replace_all("Acc", "Accelerometer") %>%
    stringr::str_replace_all("Gyro", "Gyroscope") %>%
    stringr::str_replace_all("Mag", "Magnitude")
)
# Assign the new variable names to the data frame
colnames(ml_merged) <- new_colnames


## ----run-analysis-9------------------------------------------------------------------------------------------------------------------------------
# Create tidy dataset
ml_cleaned <- ml_merged %>%
  dplyr::group_by(activity_type, subject_id) %>%
  dplyr::summarise_all(.funs = mean)
# Write results to file in directory
write.table(ml_cleaned,
            "assignments/getting-cleaning-data/tidyHARdata.txt",
            row.names = FALSE)


## ----run-analysis-10-----------------------------------------------------------------------------------------------------------------------------
knitr::purl(
  "assignments/getting-cleaning-data/codebook.Rmd",
  output = "assignments/getting-cleaning-data/run_analysis.R"
)


## ----variables, include=FALSE, results='asis'----------------------------------------------------------------------------------------------------


