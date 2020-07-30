function [PSD_features, PSD_feature_labels]=feat_psd(x, fs, options)
%Power spectral density (PSD).
%This function calculates frequency-domain based features used in [1]. 
%--------------------------------------------------------------------------
% Input:
%       x: a [1 x N] or [N x 1] vector of inertial sensor data (for example
%       the vertical accleration)
%
%       * if x == [] or x==NaN, the output feature vector is returned as a
%       [1xN] vector of NaNs, along with a [1xN] vector string of
%       corresponding feature labels
%
%       fs: the sampling frequency in Hertz [Hz]
% _________________________________________________________________________
%      options: structure containing optional inputs.
%      There are currently no options for this function.
%
% =========================================================================
% Output: 
%       PSD_features: a 1xN vector of feature values 
%       PSD_feature_labels: a 1xN vector string of corresponding 
%       feature labels
%
%--------------------------------------------------------------------------
% References:
% [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%     Characterisation of Ambulation in Multiple Sclerosis during the
%     Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%     Informatics, doi: 10.1109/JBHI.2020.2998187.
%
%% Andrew Creagh. Last modified on June 2020

%% Initialisation and Parameterisation
% Initialise each feature as a NaN value as well as output feature vectors
% and corresponding feature labels

[PSD_max, dom_freq, gait_power, dom_gait_freq]=deal(NaN);
PSD_features=[PSD_max, dom_freq, gait_power, dom_gait_freq]; 
PSD_feature_labels={'PSD_max', 'dom_freq', 'gait_power', 'dom_gait_freq'}; 

if isempty(x) || all(isnan(x))
    return; end
%% Compute Power spectral density (PSD).
 
%removal of the mean
x=detrend(x); 

% Power Spectral Density (PSD) estimate via periodogram method of the
% sequence x. The PSD estimate of x is performed using the modified
% periodogram, calculated using Welch’s overlapped segment averaging
% estimator, with a Hamming window function
[pxx, freq]=periodogram(x, hamming(length(x)), [], fs,'power');

% The maximum power spectral density (PSD) of the sequence x
[PSD_max,fi]=max(pxx);

% The dominant frequency, f (Hz), in the sequence x
dom_freq=freq(fi);

%index the typical gait frequency range 0.3-5 [Hz]
gait_freq=find(freq>0.3 & freq<=5);  

% The maximum power spectral density (PSD) of the sequence x within the
% gait frequency domain (e.g. 0.3-5 [Hz])
[gait_power, fi]=max(pxx(gait_freq));

% The dominant frequency, fg (Hz), in the sequence x within the gait
% frequency domain (e.g. 0.3-5 [Hz])
 dom_gait_freq=freq(gait_freq(fi));
    
%% Create Feature Vector
PSD_features=[PSD_max, dom_freq, gait_power, dom_gait_freq]; 

end 