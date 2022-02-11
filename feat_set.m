function features = feat_set(data, flag_load, flag_save, filename)
% this function creates a feature set for a givven data, ussing
% feat_extract_norm and feat_extract_unnorm.
%
% Input:    - data: a data set generated by extract_data function
%           - flag_load: int, specifies if you want to load data from saved mat
%           file (1) or compute fefatures from the data set (0)
%           - flag_save: int, specifies if you want to save the feature matrice
%           (1) or not (0).
%           - filename: a string with the name of the mat file to save the data to.
%
% Output:   - features: a feature and label matrice, each column is a
%           feature where the last column is the labels.

if flag_load
    load(strcat('mat files/',filename), 'features');
    return
end
features = [];
for i = 1:length(data)
    feat_norm = feat_extract_norm(data{i}); % includes the label in the last idx
    feat = feat_extract_unnorm(data{i});
    temp_feat = [feat, feat_norm];
    features = [features; temp_feat];
end
if flag_save
    save(strcat('mat files/',filename), 'features')
end
end

