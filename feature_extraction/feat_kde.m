function [KDE_features,KDE_feature_labels]=feat_kde(x, options)
% Kernel Density Estimation (KDE) features extracted for use in [1].
% Features are apadated based on those proposed in [2] and [3].
%--------------------------------------------------------------------------
% Input:
%       x: a [1 x N] or [N x 1] vector of inertial sensor data (for example
%       the vertical accleration)
%
%       * if x == [] or x==NaN, the output feature vector is returned as a
%       [1xN] vector of NaNs, along with a [1xN] vector string of
%       corresponding feature labels
% _________________________________________________________________________
%      options: structure containing optional inputs.
%      - 'kde_bandwidth': a float denoting the KDE bandwidth (h) to use.
%       (exmaple: options.kde_bandwidth=0.4);
%       (default - allow ksdensity.m to choose h);
%       See 'ksdensity.m' for further information. 
%
% =========================================================================
% Output: 
%       KDE_features: a 1xN vector of feature values 
%       KDE_feature_labels: a 1xN vector string of corresponding 
%       feature labels
%
%--------------------------------------------------------------------------
% References:
% [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%     Characterisation of Ambulation in Multiple Sclerosis during the
%     Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%     Informatics, doi: 10.1109/JBHI.2020.2998187.
% [2] A. Qureshi, M. Brandt-Pearce, M. M. Engelhard, and M. D. Goldman, 
%     “Relationship between kernel density function estimates of gait time 
%     series and clinical data,” in 2017 IEEE EMBS International Conference 
%     on Biomedical Health Informatics (BHI). IEEE, Conference Proceedings,
%     pp. 329–332.
% [3] S. R. Dandu, M. M. Engelhard, A. Qureshi, J. Gong, J. C. Lach, 
%     M. Brandt-Pearce, and M. D. Goldman, “Understanding the physiological
%     significance of four inertial gait features in multiple sclerosis,” 
%     IEEE Journal of Biomedical and Health Informatics, vol. 22, no. 1, 
%     pp. 40–46, 2018.
%
%% Andrew Creagh. Last modified on June 2020

%% Initialisation and Parameterisation
% Initialise each feature as a NaN value as well as output feature vectors
% and corresponding feature labels

[kde_pk_density, kde_x, kde_bandwidth]=deal(NaN);
KDE_features=[kde_pk_density, kde_x, kde_bandwidth];
KDE_feature_labels={'kde_pk_density', 'kde_x', 'kde_bandwidth'};

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
%SIGNAL DENSITY ESTIMATION

%if we want to specifiy the bandwidth
if isfield(options, 'kde_bandwidth') 
    [f,xi,kde_bandwidth]=ksdensity(x,'Kernel', 'normal', 'Bandwidth', options.kde_bandwidth);
else %use the default parameters
    [f,xi,kde_bandwidth]=ksdensity(x);
end 

%The maximum Kernel density estimation (KDE) value
[kde_pk_density, mi]=max(f);
                                                
%The value of x that maximises the KDE
kde_x=xi(mi);                                                               

%% Create Feature Vector
KDE_features=[kde_pk_density, kde_x, kde_bandwidth];

end 

% EOF
