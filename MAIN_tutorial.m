% GAIT FEATURE EXTRACTION TUTORIAL
% Tutorial for gait feature extraction software. This example is based off
% the work presented by Creagh et al. (2020) [1].
% Reference:
% [1]  A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%      Characterisation of Ambulation in Multiple Sclerosis during the
%      Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%      Informatics, doi: 10.1109/JBHI.2020.2998187.
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
% Last modified in June 2020

%% Dependencies
% % There are a number of 3rd party software dependencies required I have
% % added a copy of the 3rd party software dependencies to the repository,
% % however, these can be manually added using the below code. This file will
% % download required files and folders that my toolbox relies The user may
% % wish to take this step manually. The author of this toolbox has no
% % responsibility for suggesting the downloading of third party software. If
% % you can't find these try googling them!
% unzip('http://www.maxlittle.net/software/fastdfa.zip', 'DFA')
% unzip('http://www.maxlittle.net/software/rpde.zip', 'RPDE')
% unzip('https://physionet.org/files/mse/1.0', 'MSE')

%% Load Raw Data
clear %brute force house keeping
close all

raw_data_pathname=[cd, filesep, 'SAMPLE_DATA'];
%the pathname where the features are to be saved
save_features_pathname=[cd, filesep, 'FEATURES'];
%the filename:
filename='Raw_sample_smartphone_accelerometer_data_1.txt';

%read sensor data as a table. You cna use whatever functions you prefer to
%load the data. 
SENSOR_DATA=readtable(fullfile(raw_data_pathname, filesep, filename));

%print first 5 lines of sensor data, we see that each file has a header
%with a time vector, triaxial X-axis, Y-axis and Z-axis acceleromoter reading  
SENSOR_DATA(1:5, :)

% We convert the sensor data to an array, where the SENSOR_DATA is an 
% [N x C] matrix of inertial sensor data, where N are  the number of 
% samples and C are the number of channels such that:
%       SENSOR_DATA(:,1) - a monotonically increasing time vector 
%       SENSOR_DATA(:,2) - aX-axis sensor data
%       SENSOR_DATA(:,3) - aY-axis sensor data
%       SENSOR_DATA(:,4) - aZ-axis sensor data
SENSOR_DATA=table2array(SENSOR_DATA);

%Plot the raw sensor data using this independent function 
options.plot_title='Raw Sensor Signal';
plot_data(SENSOR_DATA, options);

%inspect the sampling frequency (fs);
% Sometimes smartphone/smartwatches do not sample at an exact same rate.
% There we take the median sampling frequency over all paired sample
% differences
time=SENSOR_DATA(:, 1); %time is the first index; 
fs=round(1/median(diff(time)));

%% Perform Data Pre-processing
% In this section we will execute the processsing steps associated with [1]

% call wrapper function to perform gait pre-processing, namely:
% (1) Low-pass filter the sensor data
% (2) Perform orientation independent transformation
% (3) Normalise sensor data (optional)

% we can use the options structure containing optional inputs for our functions.
% See each specific function for optional parameters. 
% Options:
options.orientation_transform=1; %perform orientation transformation 
options.plot_orientation_transform=1; %plot orientation transformation results

%--------------------------------------------------------------------------
%                 Sensor Data Pre-processing
%call pre-processing function
SENSOR_DATA=gait_preprocessing(SENSOR_DATA, options);
%--------------------------------------------------------------------------

%plot the pre-processed sensor data 
options.plot_title='Pre-Processed Sensor Signal';
plot_data(SENSOR_DATA, options);

%--------------------------------------------------------------------------
%               Non-gait bout removal 
%call pre-processing function to remove erronous sections of sesnor signal
%which are not gait. 
options.plot_bout_detection=1; %plot the gait removal results. 
SENSOR_DATA=gait_bout_detection(SENSOR_DATA, [], options);
%--------------------------------------------------------------------------
%% Sensor Data Windowing 
%Perform windowing on triaxial inertial sensor
[SENSOR_DATA_WINDOWED]=window_sensor_data(SENSOR_DATA, [], options);

% Rearrange the sensor data (SENSOR_DATA_WINDOWED) to a [N x C x W] matrix
% of inertial sensor data, where N are the number of samples, C are the
% number of channels and W are the number of windoes (epochs), subject to
% the windowing conditions set out by options or else default paramater
% settings in .window_sensor_data.m'.
SENSOR_DATA_WINDOWED=permute(SENSOR_DATA_WINDOWED, [1, 3, 2]);

%Lets examine one epoch of the windowed sensor data, taking the 2nd epoch
epoch_index=2; 
EPOCH_DATA=SENSOR_DATA_WINDOWED(:, :, epoch_index);

%Plot the windowed epoch
options.plot_title='Epoch from Sensor Data';
plot_data(EPOCH_DATA, options);

%% FEATURE EXTRACTION EXAMPLES
% In the sections below we will investigate some of the features that can
% be extracted from inertial sensor signal. Pull the time vector and each
% the X, Y, and Z-axis from the triaxial inertial sensor data, as well as
% the magnitude of acceleration (which should be calculated in the
% pre-processing stage.
t=EPOCH_DATA(:, 1);
aX=EPOCH_DATA(:,2); aY=EPOCH_DATA(:, 3);aZ=EPOCH_DATA(:, 4);
aMag=EPOCH_DATA(:, 5);

%% Feature Extraction
%By inputting empty vectors or NaN vectors we can get a list of all the
%features this codebase can extract from the assortment of feature
%extraction algorithms. These algorithms have a prefix 'feat_' in their
%name to be easily identifed. e.g. 'feat_stats.m'

x=[];y=[];z=[];
%-------------------------------------------------------------------------%
%           Feature Extraction Table of Contents
%-------------------------------------------------------------------------%
%STATISTICAL FEATURES
[STAT_features, STAT_feature_labels]=feat_stats(x, options);
% POWER SPECTRAL DENSITY (PSD) FEATURES
[PSD_features, PSD_feature_labels]=feat_psd(x, fs, options);
%JERK FEATURES
[JERK_features, JERK_feature_labels]=feat_jerk(x,t,options);
%CROSS INFORMATION FEATURES
[XI_features, XI_feature_labels]=feat_xinformation(y, z, options);
% ENTROPY MEASURES
[H_features, H_feature_labels]=feat_entropy(x, options);
%KERNEL DENSITY ESTIMATIONS
[KDE_features, KDE_feature_labels]=feat_kde(x, options);
%NON-LINEAR DYNAMICS
[DFA_features, DFA_feature_labels]=feat_dfa(x, options);
%DATA-DRIVEN FREQUENCY CHARACTERISATION
[IMF_features, IMF_feature_labels]=feat_imf(x, fs, options);
%WAVELET FEATURES
%(1) Es wavelet Features
[Es_features,Es_feature_labels]=feat_scale_dependent_energy(x, fs, options);
%(2) DWT wavelet Features
[DWT_features, DWT_feature_labels]=feat_wavedec(x, options);
%-------------------------------------------------------------------------%
%% Example #1 (Extracting features on various sensor axes)
% These are simple features based on the first, second, third and fouth
% moments of the raw sensor signal e.g the mean and standard deviation in
% the acceleration signal, and can be computed on each sensor axis signal
% or the orientation invarianet magnitude of acceleration
[aY_stat_features, stat_feature_labels]=feat_stats(aY, options);

%The feature labels can be renamed, where the sensor axis or a specific
%parmater can be appended to the feature labels. In this case we add 'aY'
%to denote that in this example these statistcial features are computed on
%the Y (vertical) axis
aY_feature_labels=strcat('aY_', stat_feature_labels);

% We can calculate the same features on different sensor axes
[aZ_stat_features, stat_feature_labels]=feat_stats(aZ, options);
aZ_feature_labels=strcat('aZ_', stat_feature_labels);

%% Example #2 (Transforming the raw sensor data to extract more features)
% Individual features can be wrapped in a function to extract these. In
% this example we have created a wrapper function to compute the jerk (3rd
% derivative) of acceleration, i.e the jerk We can then use the same
% 'feat_stats.m' function to extract statictical features on jerk, as with
% the vertical accelerationn (aY) example above.
[JERK_features, JERK_feature_labels]=feat_jerk(aY,t,options);

%% Example #3 (Grouping similar features in a wrapper function)
% All individual features can be seperated and conatined in a wrapper
% function to create modular code to extract the features we want The
% function below calculated entropy-based features which can be grouped
% together as "similar" features. In the example below we calculate entropy
% measures on the magnitude of acceleration signal
[H_features, H_feature_labels]=feat_entropy(aMag, options);

%% Example #4 (Merging features from various feature extractionn functions)
%(1) Es wavelet Features
[Es_features,Es_feature_labels]=feat_scale_dependent_energy(aMag, fs, options);
%(2) DWT wavelet Features
[DWT_features, DWT_feature_labels]=feat_wavedec(aMag, options);

%we do this by concatonating the feature files and feature labels 
features=[Es_features, DWT_features];
feature_labels=[Es_feature_labels, DWT_feature_labels];
%% Example #5
% Sometimes we may want to use the same feature extraction function twice,
% but use different parameters to compare. We can do this by prefixing the
% feature labels as in with example #1 to denote which sensor axis the
% features were extracted on. Some functions embed the parameters in the
% labels already. For example see 'feat_imf.m', where the time delay (if
% called) will be denoted in the feature labels for where the time delay
% paramater was used. See individual 'feat_*.m' files for instances of this
% functionality.
[IMF_features, IMF_feature_labels]=feat_imf(aMag, fs, options);

options.t_delay=0.05;
[IMF_005_features, IMF_005_feature_labels]=feat_imf(aMag, fs, options);

%% Example #6 (Best practice for creating a scaleable feature extraction)
% It is best practice when budiling modular feature extraction code to
% embed feature extraction functions in try/catch statements. If the file
% fails to execute or if there is an error associated with the feature
% extraction, the whole codebase won't fail, just the file you were
% extracting. We can then execute the same function in the catch statement
% to output a NaN feature file by feeded an empty nmatrix or a matrix of
% NaNs. 
aMag_INFS=inf(200,1); 
try
    [KDE_features, KDE_feature_labels]=feat_kde(aMag, options);
catch 
    [KDE_features, KDE_feature_labels]=feat_kde([], options);
end

%% Example #7 (Managing a Feature Extraction Function)
% We can warp all the independent feature extraction functions in a
% single run_feature_extraction.m' file which extracts all these features,
% and concatonates the feature vectors and feature labels
[features_out, feature_labels_out]=run_feature_extraction(SENSOR_DATA, fs, options);

% Again, it is best practice when budiling modular feature extraction code
% to embed feature extraction functions in try/catch statements.
% Use a try/catch functionality to execute feature extraction and "catch"
% resulting errors as above; This approach allows us to override the
% default error behavior for a set of program statements, i.e. the feature
% extraction code will not crash. This is especially useful for dealing
% with feature extraction errors within over a large number of sensor files
% and for integration into modular and scalable feature extraction
% pipelines. We can "catch" this error message 'err_msg'. Modifications of
% this code could save or store error messages for debugging purposes to to
% return and explore reasons a sensor file failed Using the in-built
% functionality of our feature extraction package we simply return the
% return the initalised features as NaNs by inputting a dummy fetaure file
% of NaNs to our feature extraction file. (see example for more information
% on this functionality.

% We denote our sensor data as a matrix of Infs, which should break our
% algorithm. The errors are caught in err_msg. We then input NaNs to the
% function to draw out NaN feature values for this particular example. In
% scaleable code, we can use this to denote missing data or failed
% extaction for certain files when perfroming feature extractionn over a
% large number of files.
SENSOR_DATA_INF=inf(200,5); 
try
    [features_out, feature_labels_out]=run_feature_extraction(SENSOR_DATA_INF, fs, options);
catch err_msg
    [features_out, feature_labels_out]=run_feature_extraction(NaN(1,5), fs, options);
end
%view what the error message would have been. 
fprintf('Error Message would be: ''%s''\n', err_msg.message)
%% The End
fprintf('MAIN_tutorial finished.\n')
%Hopefully this is enough to get you started out on modular, scaleable and
%parallizable feature extraction.
% EOF