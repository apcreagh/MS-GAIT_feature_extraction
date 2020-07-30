function [JERK_stat_features, JERK_stat_feature_labels]=feat_jerk(x,t,options)
% Extract "jerk" based features based on [1]. 
% Jerk is the third derivative, d^3 x / dt^3 of x and helps characterise 
% sharp sensor movements.
%--------------------------------------------------------------------------
% Input:
%       x: a [1 x N] or [N x 1] vector of inertial sensor data (for example
%       the vertical accleration)
%
%       * if x == [] or x==NaN, the output feature vector is returned as a
%       [1xN] vector of NaNs, along with a [1xN] vector string of
%       corresponding feature labels
%
%       t: the corresponding time vector for x. t is formated in [s] and
%       increasing at unifmor sample rate (fs)
% _________________________________________________________________________
%      options: structure containing optional inputs.
%      Currently there are no options for this function
%
% =========================================================================
% Output: 
%       JERK_stat_features: a 1xN vector of feature values 
%       JERK_stat_feature_labels: a 1xN vector string of corresponding 
%       feature labels
%
%--------------------------------------------------------------------------
% References:
% [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%     Characterisation of Ambulation in Multiple Sclerosis during the
%     Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%     Informatics, doi: 10.1109/JBHI.2020.2998187.
%% Andrew Creagh. Last modified on June 2020

%% Initialisation and Parameterisation
% Initialise each feature as a NaN value as well as output feature vectors
% and corresponding feature labels

%we can use empty inputs within modular functions, such as
%'feat_stats.m', to initalise feature vectors that will be computed on
%"jerk" input data
[JERK_stat_features, JERK_stat_feature_labels]=feat_stats([], options);
%append label information to feature_labels signifying these features are
%based on "jerk" of inertial sensor data
JERK_stat_feature_labels=strcat('jerk_', JERK_stat_feature_labels);

% If the sensor data is empty of a NaN value, return the initalised
% features as NaNs. This simple functionality allows the user to quickly
% generate the feature labels and NaN features. This is useful for
% initalising feature vectors, generating feature labels, and for
% integration into modular and scalable feature extraction pipelines. This
% is especially useful for dealing with feature extraction errors within a
% single sensor data file during feature extraction over a large number of
% sensor files. 

if isempty(x) || all(isnan(x))
    return; end

%% Calculate JERK
%Jerk is the third derivative, d^3 x / dt^3 of x and helps characterise sharp sensor movements.
jerk=diff(x)./diff(t);

% % % Uncomment to plot jerk example
% figure;
% subplot(2,1,1); plot(t, aY); ylabel('a_y')
% subplot(2,1,2); plot(t(2:end), jerk); ylabel('jerk (d^{3} a_{y} / dt^{3})'); xlabel('Time [s]')

%% Compute JERK features 
[JERK_stat_features, ~]=feat_stats(jerk, options);

end 