This is a README file for Tomer and Ilay's second project in Continous Sensoring of Physiological Parmeters.

#################
###BHQ PROJECT###
#################

Classification problem tackled: Classifing Weekdays vs. Weekends.

##############################################Important###################################################
hhentschke/measures-of-effect-size-toolbox was used for computing Cramer's V during correlations analysis.
If you want the whole code to work, make sure to download this toolbox first.
##########################################################################################################

Objects and Functions in the submission file:

The submission files consists of 'main' function, helper functions, this 'README' file, and a mat file, 
as was asked in the task instructions.

'main' is the main function of the code. Running it with the file path of the given xlsx data files as input,
outputs a confusion matrix of the classified data, using the classifier that was decided as the best classifier
during research and testing of the given data.

The mat file, is the confusion matrix obtained on our test set through the best classifier.

Helper Functions:

1) 'extract_data' extracts the data from the xlsx files, to a comfortable data set.
2) 'feat_extract_norm' extracts features from the dataset, which need a normalization process.
3) 'feat_extract_unnorm' extracts features from the dataset, which don't need a normalization process.
4) 'feat_set' creates a unified dataset of both normed and not normed features.
5) 'corr_analysis' computes feature-feature correlations,then adds a relieff process, to remove redundant features.
    Moreover, it removes features which had over 15% Nan values.
6) 'main_workflow' is the main script in which we constructed our whole pipeline of the project - data preprocessing, feature extraction,
   feature selection, building and optimizing a model and more. Both confusion matrices in PPV and Sensitivity of 90% are displayed when you run the script.

how to work with the code:

in the 'main_workflow' change the flags as you wish, each flag has its own explanation in the same code line.
if its your first time running the code make sure all load flags are set to 0 or an error will occur because there is no mat files in 'mat files' folder.
the 'mat files' folder contains all the mat files saved when the script is executed.
if you wish to load mat files and save computation time make sure you have run the script befor with all save flags set to 1, only then you can change the load flags to 1 for the next script execution.
the variable 'files_filepath' determies the path of the xlsx files to train and evaluate the model, so change it to where all the xlsx files are (relative path).

we are uploading our code with the saved mat files we got when we run the script, feel free to delete them but make sure you are changing the flags appropriately.

the use of 'main' function is the same as instructed, the only input is the files path.
