function main(folder_path)
% this function execute the pipeline of our data processing and then
% predicts on that data and creates a plot of the confusion matrice
%
% Input:    - folder_path: the folder path to where the xlsx files are stored

% set some usefull flags 
flag = 0;         % replacing all the falgs we used in main_workflow

% define our data matrix that contains sturctures
files_filepath = folder_path;
mat_filepath = 'mat files';

% extract data from xlsx files
all_data = extract_data(files_filepath, mat_filepath, flag, flag);

% extract features from the data
test_feat = feat_set(all_data,flag,flag,'no name');

% feature selection process - load the mat file and remove unnecessary features
load('mat files\logical features to remove.mat', 'features_not_removed_idx');
load('mat files/SFS data','Indx_sfs', 'history_sfs');

test_feat(:,~features_not_removed_idx) = [];
test_feat = [test_feat(:,Indx_sfs), test_feat(:,end)];

% classifier - load the Random forest model
load('mat files\BestMDL.mat', 'ensemble_MDL_all');

% predict on the data
prediction_test = predict(ensemble_MDL_all, test_feat(:,1:end-1)); % predictions on test set

C = confusionmat(test_feat(:,end),prediction_test);
figure;
confusionchart(C, {'weekdays', 'weekends'});
end