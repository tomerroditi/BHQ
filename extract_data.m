function all_data = extract_data(files_filepath, data_filepath, flag_load, flag_save)
% this function reads xlsx files and return them as a data structure.
% inputs:
%       - files_filepath: the relative path to the xlsx files
%       - data_filepath: the relative path to where you want to save the
%                        extracted data
%       - flag_load: specifies if you want to load a mat file as the data
%                    (1) structure or extract data from xlsx files (0)
%       - flag_save: specifies if you want to save the data that have been
%                    extracted to a mat file (1) or not (0)
%
% outputs:
%       - all_data: a cell containing the data structures. each cell is a
%                   structure containing the data of a single person. the
%                   fields of each structure are structures that contains
%                   data relative to this person in every day of recording.
%                   the data is stored as a table obj.




% load condition
warning ('off','MATLAB:table:ModifiedAndSavedVarnames');
if flag_load
    all_data = load(strcat(data_filepath,'/all_data.mat'));
    all_data = all_data.all_data;
    return
end

listing = dir(files_filepath);  % get files info

all_data = cell(length(listing),1); % alocate space in memory 


for i = 3:length(listing)
    name = listing(i).name;                                 % name of the file
    names = split(name, '.');
    if length(names) >= 3 || strcmp(name,'desktop.ini')
        continue
    end
    data = readtable(strcat(files_filepath, '/', name));    % read the xlsx file
    data_label = readtable(strcat(files_filepath, '/', names{1}, '.label.', names{2}));    % read the label xlsx file
    func = @(t) datetime([year(t) month(t) day(t)]);
    data_label(:,1) = varfun(func, data_label, 'InputVariables', 1);
    dates = unique(data(:,5));                              % get the recorded dates
    curr_struct = struct('uid', data(1,2));                 % create a new structure
    for j = 1:size(dates,1)
        temp_data = data(data{:,5} == dates{j,1},:);        % table data that maches the current date
        temp_data = sortrows(temp_data,6);                  % sort the data by time of the day
        type = temp_data{:, 7};                             % sensors names column

        temp_data_label = data_label(data_label{:,1} == dates{j,1},:);        % label table data that maches the current date

        % extract the relevant data from the table
        wifi = temp_data(strcmp(type,'wireless'), [6 8 9]);
        bluetooth = temp_data(strcmp(type,'bluetooth'), [6 8 9 10]);
        location = temp_data(strcmp(type,'location'), [6 9 10]);
        light = temp_data(strcmp(type,'light'), [6 9]);
        calls = temp_data(strcmp(type,'calls'), [6 9 11]);
        battery = temp_data(strcmp(type,'battery'), [6 9 10 11]);
        activity = temp_data(strcmp(type,'activity_recognition'), [6 10 11]);
        screen = temp_data(strcmp(type,'screenstate'), [6 9]);
        acc = temp_data(strcmp(type,'acelerometer'), [6 12 13 14]);

        if ~isempty(temp_data_label)
            sleep_time = temp_data_label{1,2};
            wake_time = temp_data_label{1,3};
            stress = temp_data_label{1,4};
            activities = temp_data_label{1,5}; 
        else
            sleep_time = nan;
            wake_time = nan;
            stress = nan;
            activities = nan;
        end
        % set the fields in the structure of the current date
        field_name = strcat('day_',num2str(j));
        curr_struct.(field_name).date = dates{j,1};
        curr_struct.(field_name).wifi = wifi;
        curr_struct.(field_name).bluetooth = bluetooth;
        curr_struct.(field_name).location = location;
        curr_struct.(field_name).light = light;
        curr_struct.(field_name).calls = calls;
        curr_struct.(field_name).battery = battery;
        curr_struct.(field_name).activity = activity;
        curr_struct.(field_name).screen = screen;
        curr_struct.(field_name).acc = acc;
        curr_struct.(field_name).sleep_time = sleep_time;
        curr_struct.(field_name).wake_time = wake_time;
        curr_struct.(field_name).load = stress;
        curr_struct.(field_name).activities = activities;
    end
    all_data{i - 2,1} = curr_struct;
end
all_data = all_data(~cellfun('isempty',all_data));      % remove empty cells
if flag_save
    save(strcat(data_filepath,'/','all_data'), 'all_data'); % save the data as a mat file
end
warning ('on','MATLAB:table:ModifiedAndSavedVarnames');
end
