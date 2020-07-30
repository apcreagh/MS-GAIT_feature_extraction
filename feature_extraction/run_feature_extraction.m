function [features_out, feature_labels_out]=run_feature_extraction(SENSOR_DATA, fs, options)
% Shell function to run the feature extraction outlined in [1]. Extraction
% is performed on groups of functions characterising various feature
% domains.
%--------------------------------------------------------------------------
% Input:
%     SENSOR_DATA: a [N x C] matrix of inertial sensor data, where N are 
%     the number of samples and C are the number of channels such that:
%          SENSOR_DATA(:,1) - conatins the time vector
%          SENSOR_DATA(:,2) - X-axis sensor data
%          SENSOR_DATA(:,3) - Y-axis sensor data
%          SENSOR_DATA(:,4) - Z-axis sensor data
%          SENSOR_DATA(:,5) - The magnitude of X-, Y- and Z- axis sensor data
% 
%     fs: the sampling frequency of the inertial sensor data in Hertz [Hz]
% _________________________________________________________________________
%    options: structure containing optional inputs to be used in each
%    feature extraction fucntion. See specific extraction functions for
%    specific functionality.
% =========================================================================
% Output: 
%    features: a [1xN] vector of feature values .
%    feature_labels: a [1xN] vector string of corresponding feature labels.
%--------------------------------------------------------------------------
% Reference:
% [1]  A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%      Characterisation of Ambulation in Multiple Sclerosis during the
%      Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%      Informatics, doi: 10.1109/JBHI.2020.2998187.
%
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
%  Last modified on June 2020

%% Extract sensor data 
t=SENSOR_DATA(:, 1); 
aX=SENSOR_DATA(:,2); aY=SENSOR_DATA(:, 3);aZ=SENSOR_DATA(:, 4);
aMag=SENSOR_DATA(:, 5);

%% STATISTICAL FEATURES
% Statistical features computed on the aX,aY,aZ and magnitude of ||a||

[aMag_STAT_features, STAT_feature_labels]=feat_stats(aMag, options);
aMag_STAT_feature_labels=strcat('aMag_', STAT_feature_labels);

[aX_STAT_features, STAT_feature_labels]=feat_stats(aX, options);
aX_STAT_feature_labels=strcat('aX_', STAT_feature_labels);

[aY_STAT_features, STAT_feature_labels]=feat_stats(aY, options);
aY_STAT_feature_labels=strcat('aY_', STAT_feature_labels);

[aZ_STAT_features, STAT_feature_labels]=feat_stats(aZ, options);
aZ_STAT_feature_labels=strcat('aZ_', STAT_feature_labels);

%% POWER SPECTRAL DENSITY (PSD) FEATURES
[PSD_features, PSD_feature_labels]=feat_psd(aMag, fs, options);

%% JERK FEATURES
[JERK_features, JERK_feature_labels]=feat_jerk(aMag,t,options);
JERK_feature_labels=strcat('aMag_', JERK_feature_labels);

%% CROSS INFORMATION FEATURES
[XI_aYaZ_features, XI_aYaZ_feature_labels]=feat_xinformation(aY, aZ, options);
XI_aYaZ_feature_labels=strcat('aYaZ_', XI_aYaZ_feature_labels);

[XI_aXaZ_features, XI_aXaZ_feature_labels]=feat_xinformation(aX, aZ, options);
XI_aXaZ_feature_labels=strcat('aXaZ_', XI_aXaZ_feature_labels);
%% ENTROPY MEASURES
[H_features, H_feature_labels]=feat_entropy(aMag, options);

%% KERNEL DENSITY ESTIMATIONS
[KDE_features, KDE_feature_labels]=feat_kde(aMag, options);

%% NON-LINEAR DYNAMICS
[DFA_features, DFA_feature_labels]=feat_dfa(aMag, options);

%% DATA-DRIVEN FREQUENCY CHARACTERISATION
[IMF_features, IMF_feature_labels]=feat_imf(aMag, fs, options);

options.t_delay=0.05;
[IMF_005_features, IMF_005_feature_labels]=feat_imf(aMag, fs, options);

%% WAVELET FEATURES
%(1) Es wavelet Features
[Es_features,Es_feature_labels]=feat_scale_dependent_energy(aMag, fs, options);
%(2) DWT wavelet Features
[DWT_features, DWT_feature_labels]=feat_wavedec(aMag, options);

%% Create Feature Vector

features_out=[...
                aMag_STAT_features, ...
                aX_STAT_features,...
                aY_STAT_features,...
                aZ_STAT_features,...
                PSD_features, ...
                JERK_features,...
                XI_aYaZ_features,...
                XI_aXaZ_features,...
                H_features, ...
                KDE_features,...
                DFA_features,...
                IMF_features,...
                IMF_005_features, ...
                Es_features,...
                DWT_features...
    ];

feature_labels_out=[...
                    aMag_STAT_feature_labels, ...
                    aX_STAT_feature_labels, ...
                    aY_STAT_feature_labels, ...
                    aZ_STAT_feature_labels, ...
                    PSD_feature_labels, ...
                    JERK_feature_labels, ...
                    XI_aYaZ_feature_labels, ...
                    XI_aXaZ_feature_labels, ...
                    H_feature_labels,...
                    KDE_feature_labels, ...
                    DFA_feature_labels, ...
                    IMF_feature_labels, ...
                    IMF_005_feature_labels, ...
                    Es_feature_labels, ...
                    DWT_feature_labels, ...
    ];

%% Little qualtiy control to make sure feature labels and feature vectors match
if length(features_out) ~= length(feature_labels_out)
    error('The number of features extracted does not match the number of feaure labels'); end
end
%EOF