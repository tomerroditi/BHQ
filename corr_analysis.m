function [feat_feat_corr, weights, best_feat_label, features_removed_names,...
    features_not_removed_idx, highest_corr_under_thresh, feat_names_nans]...
    = corr_analysis(feat_label_mat, feat_names, categorical)
% this function removes redundant features due to high correlations.
%
% Input:    - feat_label_mat - a matrice of features and labels, the labes are in the last column.
%           - feat_names - a cell array of the features names corresponding
%           to their location in the feat_label_mat.
%           - categorical - an array of the catagorical features indices in feat_label_mat.
%
% Output:   - feat_feat_corr - a correlation matrix of the remaining features
%           - weights - the weights computed by the relieff algorithm
%           corresponding to the remaining features.
%           - best_feat_label - a cell array containing information about
%           the feature with the highest weight from the relieff algorithm.
%           - features_removed_names - a cell array containing the names of
%           the removed features 
%           - features_not_removed_idx - a logical array containing 0 where
%           there is a feature to remove and 1 where there is a feature to maintain
%           - highest_corr_under_thresh - a cecll array containing
%           information about the two features with highest correlation
%           after removing the redundant features.
%           - feat_names_nans - a cell array containing the names of
%           removed features due to having more than 15% nan values.
         

all_names = feat_names;

% Slice the data to features and labels
label_vec = feat_label_mat(:,end);         % Separate the Labels from matrix
feat_mat = feat_label_mat(:, 1:end - 1);    % Separate Features from labels

% define new feature matrix for categorial and numeric features
catg_feat_mat = feat_mat(:,categorical); % categorial features
num_feat_mat = feat_mat;
num_feat_mat(:,categorical) = []; % numeric features

% define names of num and catg features
names_catg = feat_names(categorical);
names_num = feat_names;
names_num(categorical) = [];

%% reject features with too many nans
% categorial
nan_feat_idx  = sum(isnan(catg_feat_mat),1);
reject = nan_feat_idx > size(catg_feat_mat,1)*0.15;
catg_feat_mat = catg_feat_mat(:,~reject);
feat_names_nans_catg = names_catg(reject);
names_catg(reject) = [];

% numeric
nan_feat_idx  = sum(isnan(num_feat_mat),1);
reject = nan_feat_idx > size(num_feat_mat,1)*0.15;
num_feat_mat = num_feat_mat(:,~reject);
feat_names_nans_num = names_num(reject);
names_num(reject) = [];

feat_names_nans = [feat_names_nans_num; feat_names_nans_catg];


%% Compute feat label corr
nan_exmpl_idx_num = logical(sum(isnan(num_feat_mat),2)); % find examples with nans values
nan_exmpl_idx_catg = logical(sum(isnan(catg_feat_mat),2)); % find examples with nans values
nan_idx = (nan_exmpl_idx_num | nan_exmpl_idx_catg);

k = 7;     % num of neighbors for relieff
[~, weights_num] = relieff(num_feat_mat(~nan_idx,:), label_vec(~nan_idx,:), k, 'method', 'classification');   % Features-Labels correlation for numeric
[~, weights_catg] = relieff(catg_feat_mat(~nan_idx,:), label_vec(~nan_idx,:), k, 'method', 'classification','categoricalx', 'on');   % Features-Labels correlation for categorial
weights = [weights_num, weights_catg];
weights_sorted = sort([weights_num, weights_catg], "descend");
idx_1_num = weights_num == weights_sorted(1);
idx_1_catg = weights_catg == weights_sorted(1);
idx_2_num = weights_num == weights_sorted(2);
idx_2_catg = weights_catg == weights_sorted(2);
name_1 = [names_catg(idx_1_catg), names_num(idx_1_num)];
name_2 = [names_catg(idx_2_catg), names_num(idx_2_num)];

% extract the two features with highest feature label correlation
best_feat_label{1} = [weights_sorted(1), weights_sorted(2)];    % value of relieff
best_feat_label{2} = {name_1, name_2};            % feature name


% Compute feat feat corr
number_feat = size(num_feat_mat,2) + size(catg_feat_mat,2);
feat_names = [names_num; names_catg]; % all features names
feat_mat = [num_feat_mat catg_feat_mat]; % all features matrix
feat_feat_corr = ones(number_feat);

% numeric - numeric corr
feat_feat_corr(1:length(names_num), 1:length(names_num)) = corr(num_feat_mat, 'type', 'Spearman', 'rows', 'complete');  % Features-Features correlation
L = size(num_feat_mat,2);
U = size(catg_feat_mat,2);
% numeric - categorial corr
for i = 1:L
    for j = 1:U
        feat_feat_corr(i,L + j) = corr(num_feat_mat(:,i), catg_feat_mat(:,j), 'type', 'Pearson', 'rows', 'complete');
        feat_feat_corr(j + L,i) = feat_feat_corr(i,L + j);
    end
end

% categorial - categorial corr
for i = 1:U
    for j = 1:U
        if i == j 
            continue
        elseif feat_feat_corr(j + L,i + L) ~= 1 || feat_feat_corr(i + L, j + L) ~= 1
            continue
        end
        cg1 = catg_feat_mat(:,i);
        cg2 = catg_feat_mat(:,j);
        nan_idx = (isnan(cg1) | isnan(cg2)); % remove examples with nans
        cg1(nan_idx) = [];
        cg2(nan_idx) = [];
        TT = sum((cg1 == 1) & (cg2 == 1));
        TF = sum((cg1 == 1) & (cg2 == 0));
        FT = sum((cg1 == 0) & (cg2 == 1));
        FF = sum((cg1 == 0) & (cg2 == 0));
        mat = [TT, FT; TF, FF];
        stats = mestab(mat);
        feat_feat_corr(j + L,i + L) = stats.phi;
        feat_feat_corr(i + L, j + L) = stats.phi;
    end
end
figure;
heatmap(abs(feat_feat_corr)); %##### remove later ######

% find max feature-feature correlation under 0.7 and their names
[M, I] = max(feat_feat_corr(abs(feat_feat_corr) < 0.7));
[row,col] = ind2sub(size(feat_feat_corr), I);
highest_corr_under_thresh = cell(1,2);
highest_corr_under_thresh{1} = M;
highest_corr_under_thresh{2} = {feat_names{col}, feat_names{row}};

% find and remove features with over 0.7 feature-feature correlation
indices = find(and(abs(feat_feat_corr) >= 0.7, abs(feat_feat_corr) ~= 1) );
[row,col] = ind2sub(size(feat_feat_corr),indices);
feature_removed_indices = zeros(1,length(indices)); % alocate memory

for i = 1:length(indices)
    feat_1 = col(i);
    feat_2 = row(i);
    if weights(feat_1) > weights(feat_2)
        worst_feat = feat_2;
    else
        worst_feat = feat_1;
    end
    feature_removed_indices(i) = worst_feat;
end
feature_removed_indices = unique(feature_removed_indices);
features_removed_names = feat_names(feature_removed_indices);

feat_mat(:,feature_removed_indices) = []; % remove features
feat_mat = [feat_mat, label_vec]; % add labels to feature matrix
feat_names(feature_removed_indices) = []; % remove feature names

% find the indices of initial features that remain
features_not_removed_idx = ismember(all_names, feat_names);


weights(feature_removed_indices) = [];
feat_feat_corr(:,feature_removed_indices) = [];
feat_feat_corr(feature_removed_indices,:) = [];
end

