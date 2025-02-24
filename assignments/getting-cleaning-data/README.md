# Peer-graded Assignment: Getting and Cleaning Data Course Project

## Johns Hopkins Coursera Data Science Specialisation: Course 3

### Author: Hiten Pragji

This repository contains the required files for the Getting and Cleaning Data course project.

### Project Description

The purpose of this project is to demonstrate the ability to collect and clean a dataset by preparing a tidy dataset that can be used for later analysis. The data provided is a Human Activity Recognition database built from the recordings of 30 subjects performing activities of daily living (ADL) while carrying a waist-mounted smartphone with embedded inertial sensors.

### Source data

The source data can be found on the UCI Machine Learning Repository [here](https://archive.ics.uci.edu/dataset/240/human+activity+recognition+using+smartphones).

### Files

-   `run_analysis.R` is an R script which retrieves and cleans the data from the source and prepares a tidy dataset by:
    -   Merging the training and test datasets to create one dataset
    -   Extracting the measurements on the mean and standard deviation
    -   Using descriptive activity names to name the activities in the dataset
    -   Appropriately labelling the dataset with descriptive variable names
    -   Creating a second, independent tidy dataset with the average of each variable for each activity and subject.
-   `tidyHARdata.txt` contains the final tidy dataset as a result of the above data cleaning and transformation.
-   `codebook.md` describes all the dataset variables and the transformations taking place in the `run_analysis.R` script.
-   `getting_cleaning_data_assignment.Rmd` documents the cleaning/transformation process and includes the code chunks which make up the `run_analysis.R` script.

### Execution instructions

The R script `run_analysis.R` was written as a reproducible analytical pipeline (RAP), therefore, it should be easy for collaborators to run the analysis on their machines. To reproduce the analysis, simply open the `run_analysis.R` file and run it. There is no need to manually download the data as the script will do it for you.
