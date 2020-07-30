function run_feature_extraction_shell(raw_data_pathname, filename, save_features_pathname, options)
%Shell function to run feature extraction code. This function can be
%independently called for each sensor data file within a itertaive loop
%(i.e. a for loop, or a parfor loop for paralleliszation)
%
% This feature extraction pipeline is based from Creagh et al. (2020) [1]. 
%
%% Function Pipleline:
% (1) loads the raw inertial sensor data associated with:
%     'raw_data_pathname' and 'filename'
% (2) pre-processes the raw inertial sensor data according to: 
%     'gait_preprocessing.m'
% (3) windows the data into epochs using 'window_sensor_data.m' (optional)
% (4) performs feature extraction on raw inertial sensor data,
%     or individual epoch (window) representations of the raw inertial 
%     sensor data (optional)
% (5) computes macro- average & variabilty of the features values over epochs
%     (optional, if sensor data is windowed; otherwise the features are
%     computed over the entire signal)
% (6) saves the computed macro- feature file associated with:
%     'raw_data_pathname' and 'filename'
%
%--------------------------------------------------------------------------
% Input:
%     raw_data_pathname: a character array denoting the pathname where the
%     data is stored
%
%     filename: a char array denoting the filename where the data is stored 
%
%     save_features_pathname: a char array denoting where the computed 
%     features should be stored
% _________________________________________________________________________
%    options: structure containing optional inputs to be used in each
%    feature extraction function. See specific extraction functions for
%    specific functionality.
%--------------------------------------------------------------------------
% Reference:
% [1]  A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%      Characterisation of Ambulation in Multiple Sclerosis during the
%      Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%      Informatics, doi: 10.1109/JBHI.2020.2998187.
%
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
%  Last modified on June 2020

%% Load Data
% load sensor data which should be stored as a .txt or .csv file with headers
% modify as necessary
SENSOR_DATA=readtable(fullfile(raw_data_pathname, filesep, filename));

%extract raw sensor data as an array
SENSOR_DATA=table2array(SENSOR_DATA);

%% Pre-Processing
%run pre-processing function
[SENSOR_DATA, fs]=gait_preprocessing(SENSOR_DATA, options);

SENSOR_DATA_WINDOWED=SENSOR_DATA;
% window sensor data into epochs (optional)
if isfield(options, 'window_sensor_data') && options.window_sensor_data
[SENSOR_DATA_WINDOWED]=window_sensor_data(SENSOR_DATA, fs, options); 
SENSOR_DATA_WINDOWED=permute(SENSOR_DATA_WINDOWED, [1, 3, 2]);
end

[num_samples_per_epoch, num_channels, num_epochs]=size(SENSOR_DATA_WINDOWED);

%% Feature Extraction
%initialise feature vector to populate per epoch
[features, feature_labels]=run_feature_extraction(NaN(1,num_channels), fs, options);
features=repmat(features, [num_epochs, 1]);

%run feature extraction per epoch
for epoch_index=1:num_epochs
    
    %sensor data for specific epoch @ epoch_index
    SENSOR_DATA_IN=SENSOR_DATA_WINDOWED(:, :, epoch_index);

%try / catch:
%     Use a try/catch functionality to execute feature extraction and
%     "catch" resulting errors; This approach allows us to override the
%     default error behavior for a set of program statements, i.e. the
%     feature extraction code will not crash. This is especially useful for
%     dealing with feature extraction errors within over a large number of
%     sensor files and for integration into modular and scalable feature
%     extraction pipelines. We can "catch" this error message 'err_msg'.
%     Modifications of this code could save or store error messages for
%     debugging purposes to to return and explore reasons a sensor file
%     failed Using the in-built functionality of our feature extraction
%     package we simply return the return the initalised features as NaNs
%     by inputting a dummy fetaure file of NaNs to our feature extraction
%     file. (see example for more information on this functionality.
    try
        %run feature extraction
        [features(epoch_index, :), feature_labels]=...
            run_feature_extraction(SENSOR_DATA_IN, fs, options);

    catch err_msg

         %catch failed feature extractions
         [features(epoch_index, :), feature_labels]=...
             run_feature_extraction(NaN(1,5), fs, options);
    end
end

% computes macro- average & variabilty of the features values over epochs
% (if sensor data is windowed; otherwise the features are computed over the
% entire signal as the signal will be represnted by one epoch; variability
% metrics will be redundant; these can easily be removed in post-processing)

features_m=mean(features);
features_std=std(features);

% % depending on how we want to consider missing values we can choose to
% % ignore epoch features which have been extracted as NaNs. Pros and Cons.
% % Uncomment the code below to not include NaN epochs
% features_m=nanmean(features);
% features_std=nanstd(features);


%Finally, concatonate epoch features into a larger vector
features_out=[features_m, features_std];
%label appropriately as mean '_m' and standard deviation '_std'
feature_labels_out=[strcat(feature_labels, '_m'),  strcat(feature_labels, '_std')];

%I like saving files as tables with header files
%convert feature files tp a table
features_out=array2table(features_out, 'VariableNames',feature_labels_out);
FEATURE_FILE=features_out;
% % we could also save the filename within the feature file if we wish using
% % the code below: 
% FEATURE_FILE=table(string(filename), 'VariableNames', {'filename'});
% FEATURE_FILE=[FEATURE_FILE,  features_out];

% % We could create a function to save the features from each epoch as a
% % seperate file. Pros and Cons again. 

%create a savefilename with an identifying prefix
save_filename=strcat('FEATURES_', filename);

% if save pathanme folder doesn't exist, make one. 
if ~isfolder(save_features_pathname)
mkdir(save_features_pathname); end

%im saving everything as .txt formats but you can save to raw .cav files,
%or use .mat files or any other applicable format. Use mathworks help to
%guide your decision and coding

% Matlab version R2019b introduced the "writetable" function which is quite
% good Before R2019b i used 'csvwrite.m' or 'dlmwrite.m' to save feature
% files. Remember to save the feature filename as 
writetable(FEATURE_FILE,fullfile(save_features_pathname, filesep, save_filename),  'delimiter',',', 'WriteVariableNames', true);
% csvwrite(fullfile(save_features_pathname, filesep, save_filename),features_out)
    
end 
% That's all folks
% EOF