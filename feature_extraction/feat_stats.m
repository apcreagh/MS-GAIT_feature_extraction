function [features, feature_labels]=feat_stats(x, options)
% Simple function to compute the 1st, 2nd, 3rd and 4th moments of the data
% x, as well as other miscellaneous statistical-based fetaures Features are
% based on the work in [1]. 
%--------------------------------------------------------------------------
% Input:
%       x: a [1 x N] or [N x 1] vector of inertial sensor data (for example
%       the vertical accleration)
% 
%       * if x == [] or x==NaN, the output feature vector is returned as a
%       [1xN] vector of NaNs, along with a [1xN] vector string of
%       corresponding feature labels
% ___________________________________________________________________
%       options: structure containing optional inputs.
%       Currently there are no options for this function. 
% =========================================================================
% Output: 
%       features: a 1xN vector of feature values feature_labels - a 1xN
%       vector string of corresponding feature labels
%
%--------------------------------------------------------------------------
% Reference:
% [1]  A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%      Characterisation of Ambulation in Multiple Sclerosis during the
%      Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%      Informatics, doi: 10.1109/JBHI.2020.2998187.
%
% Andrew Creagh. Last modified on June 2020 
%% Initialisation and Parameterisation
% Initialise each feature as a NaN value as well as output feature vectors
% and corresponding feature labels

[x_m, x_sd,  x_med, x_var, x_skew, x_kurt,x_25, x_75, x_iqr, x_range, x_cv, x_zcr]=deal(NaN);
features=[x_m, x_sd,  x_med, x_var, x_skew, x_kurt,x_25, x_75, x_iqr, x_range, x_cv, x_zcr];
feature_labels={'mean', 'std', 'med', 'var', 'skew', 'kurt', 'p25','p75', 'iqr', 'range', 'cv', 'zcr'};

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

%% Feature Computation 
x_m=mean(x);                                                               % mean (1st, central, moment) of x                   
x_sd=std(x);                                                               % standard deviation (2nd moment)of x
x_med=median(x);                                                           % median of x
x_skew=skewness(x);                                                        % skewness (3rd moment) of x
x_kurt=kurtosis(x);                                                        % kurtosis (4rd moment) of x
x_25=prctile(x,25);                                                        % 25th percentile of x
x_75=prctile(x,75);                                                        % 75th percentile of x          
x_iqr=iqr(x);                                                              % interquartile range of x
x_range=range(x);                                                          % range of x 
x_var=var(x);                                                              % variance of x 
x_cv=std(x)/mean(x);                                                       % coefficient of variation of x 
x_zcr=zcr(detrend(x));                                                     % zero-crossing rate of x, where x has been detrended first     

%% Create Feature Vector
features=[x_m, x_sd,  x_med, x_var, x_skew, x_kurt,x_25, x_75, x_iqr, x_range, x_cv, x_zcr];

end 

%Supplementary funciton to compute the zero crossing rate
function y = zcr(x)
% Returns the zero crossing rate
y = sum(abs(diff(x>0)))/length(x);

end 

% EOF