%% MAIN
%--------------------------------------------------------------------------
%       Smartphone- and Smartwatch-Based Gait Feature Extraction
%--------------------------------------------------------------------------
%% Description
% MAIN function to perform scalable, modular feature extraction 
% body-worn inertial measurement unit (IMU) sensors, such as a smartphone
% placed in a pocket or affixed to a body using a running belt. 
%
% This codebase outlines a the framework to construct a scaleable and
% parrallizable feature extraction pipeline. Theoretically pipeline can be
% performed on any biomedical time series data.
%
% This work is based on the manuscript by Creagh et al. (2020) [1]. 
%
%% Feature Extraction Pipleline:
% (1) Query and gather all inertial sensor data files stored in
%     'raw_data_pathname'. 
% (2) Run feature extraction (by executing 'run_feature_extraction_shell.m'). 
%     We do this by looping through all inertial sensor data files,
%     either in series or else in parallel. This creates an independently 
%     labelled feature file for each inertial sensor data file. 
% (3) Execute 'compile_feature_matrix.m' which compiles all computed
%     feature files associated to each independent inertial sensor file to a
%     feature matrix file.
%--------------------------------------------------------------------------
% Reference:
% [1]  A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%      Characterisation of Ambulation in Multiple Sclerosis during the
%      Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%      Informatics, doi: 10.1109/JBHI.2020.2998187.
%
%% Andrew Creagh. Last modified on June 2020 
%
%% PARAMETERISATION 
clear
%the pathname where the data is stored
raw_data_pathname=[cd, filesep, 'SAMPLE_DATA'];
%the pathname where the features are to be saved
save_features_pathname=[cd, filesep, 'FEATURES'];
file_key='RAW';

%% Options Declarations
% options: structure containing optional inputs. See each feature
% extraction function for a comprehensive help on each specific usage. An
% option for any of the feature extraction fcuntions can be declared here.
% e.g. options.cwt_name='amor'; 
% Executes the analytic Morlet (Gabor) wavelet for use in the continuous
% wavelet transform (CWT) of a discrete time signal to compute feature to
% extract features related to the maximum scale-dependent energy density
% Es. See 'feat_scale_dependent_energy.m' for more information.
%--------------------------------------------------------------------------
% Pre-procesing options
options.window_sensor_data=1;
options.orientation_independent_transformation=1;
options.plot_rotation=0;
%--------------------------------------------------------------------------
%% File extraction
files=dir([raw_data_pathname, filesep, '*', file_key, '*']);
filenames(:,1)={files.name};

%the number of sensor data files. These are can be from the same subject
%but a different trial, or from various subjects and various tests
%contributed by each subject
num_files=length(filenames);

%% Serial Feature Extraction
%serial CPU feature extraction: serial refers to cycling through each
%sensor file in series. This is is sufficient for small amounts of sensor
%data files. 
fprintf('\nPerforming Feature Extraction...\n')
for fileno=1:num_files
        
    %'run_feature_extraction_shell.m' will extract and save features for each
    %sensor filename independently.
    run_feature_extraction_shell(raw_data_pathname, filenames{fileno}, save_features_pathname, options)
    
    % Print out feature extraction progress bar
    clocktime = clock ;
    clocktimestr = sprintf('%02d:%02d:%02d', clocktime(4), clocktime(5), round(clocktime(6))) ;
    formatSpec = 'Filename:  %s\nIteration:  %i\nCompleted:  %4.2f%% \nTimestamp: %s\n';
    fprintf(formatSpec, filenames{fileno}, fileno, fileno/(num_files)*100, clocktimestr)
        
end
%% Parallel Feature Extraction
%-------------------------------------------------------------------------%
%       UNCOMMENT THIS SECTION BELOW FOR PARALLEL FEATURE EXTRACTION
%-------------------------------------------------------------------------%
% % parallel CPU feature extraction: parallel refers to cycling through each
% % sensor file in parallel. This is performed using a parfor function which
% % executes for-loop iterations in parallel on workers in a parallel pool,
% % such as over multi-core computer, i.e. over all available CPUs on a
% % machine, or on a distributed cluster network. For more informationn on
% % parfor please see :
% % https://uk.mathworks.com/help/parallel-computing/parfor.html
% % https://uk.mathworks.com/help/parallel-computing/convert-for-loops-into-parfor-loops.html
% %
% % Loop iterations are executed in parallel in a nondeterministic order.
% % Therefore we ensure that parfor-loop iterations are independent.
% % Monitor the progress of parfor loop. We can't actually do this with a
% % read-out of a traditonal for loop prgress as the works are split up
% % non-consecutively I like this 'parfor_progress.m' function by Jeremy Scheff on
% % matlabcentral/fileexchange/ to print out the progress of a parfor loop
fprintf('\nPerforming Feature Extraction...\n')
parfor_progress(num_files);
parfor fileno=1:num_files
            
        % in parfor loops we cannot contain any global or persistent
        % variable declarations. in order to maintain independence within a
        % parfor loop we create dummy variables of the variables of
        % interets and parametert variables we need; we can then call a
        % feature extraction function independently
        raw_data_pathname_=raw_data_pathname;
        filenames_=filenames{fileno}
        save_features_pathname_=save_features_pathname;
        options_=options;

        run_feature_extraction_shell(raw_data_pathname_, filenames_, save_features_pathname_, options_)
        parfor_progress;
end
% %deletes the parfor progress file
parfor_progress(0);

%% Compile Feature Matrix
% We can then use a final function to collate and compile out feature
% matrix from all features exacted over all inertial sensor files
feature_file_key='FEATURES'; 
save_filename='FINAL_GAIT_FEATURE_FILE'; 
compile_main_feature_file(save_features_pathname, feature_file_key, save_filename, options)
%%
%Thats all folks. 
%EOF