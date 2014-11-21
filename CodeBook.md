----
## Introduction
The code book provides additional details about modifications made to the raw dataset to generate the output dataset.  Reviewing the code book in advance of reviewing the solution will provide useful context.

----
## Data Source
Details about the dataset are available at the [UCI ML repository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).  The raw data is provided as a zip archive.  The R script is self-contained in that it handles downloading the archived dataset and unzipping it.

----
## Study Design
I refer the reader to the raw data's README and associated documentation to learn about how the data are collected.

----
## Code Book
Before reading about how the output datset, I encourage review of the README and associated txt files provided with the raw dataset.  It explains how the raw data were collected and describes what data are available.  The rest of this description assumes familiarity with the raw data set.

Each row in the dataset output by this script is keyed by subject ID and activity label.  Each of the remaining 79 columns represents the mean value of a feature measured by the accelerometer.  The feature columns are limited to any column from the original data set that measures either a mean or standard deviation value.  That is, the output dataset provides the mean of the mean value or the mean value of the stand deviation.  Each feature is prefixed with either an 'f' or a 't'.  'f' indicates a frequency domain measurement, while 't' indicates a time domain measurement.  Further discussion about frequency vs time domain measurements in available in features_info.txt.

It is important to note the units of the output columns.  Instead of duplicating this information, I again refer the reader to features_info.txt.  This document defines the collection process and provides the intuition for the units of measure.

----
## Implementation Design Choices
I chose to alter the sequence in which I completed the assignment steps.  I decided to perform step 4, descriptively naming the dataset when the data are first loaded into memory.  I find labeling columns when loading a data table to be a logical choice because the data table invocation supports naming columns.  This ensures the data are valid (i.e. columns named) as soon as the data enter the system (i.e. R).

Modulo the above change, the flow of the R script is similar to the steps documented in the course project description.  One other choice worth hilighting is the use of merge() to associate the activity label ID with its activity label.  The use of merge reorders columns.  This potentially malignant side-effect is benign in this case because the merge is applied after training and test data are combined.  If the activity labels were merged in prior to combining training and test data, it is likely the subsequent rbind() would create an undesirable result because the columns are misaligned.
