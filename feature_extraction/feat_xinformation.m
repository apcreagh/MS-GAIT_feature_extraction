function [XI_features, XI_feature_labels]=feat_xinformation(y, z, options)
% Signal Cross-Information (XI) Metrics.
% Function to extract cross-information based metrics, such as the
% cross-correaltion between two signals.
% Features are extracted according to [1], where typical examples are the
% cross-correlation between body-mounted, inertial sensor signals in the X-
% and Y- coordinates, corresponding to the medio-lateral and vertical
% axis. Features are based on those explored in [3]. 
%--------------------------------------------------------------------------
% Input:
%       y: a [1 x N] or [N x 1] vector of inertial sensor data (for
%       example the vertical accleration)
%       z: a [1 x N] or [N x 1] vector of inertial sensor data (for
%       example the medio-lateral or Z- axis perpendicular to the Y-axis
%       accleration
%
%       * if y == [] or y==NaN or y == [] or y==NaN, the output feature
%       vector is returned as a [1xN] vector of NaNs, along with a [1xN]
%       vector string of corresponding feature labels
% _________________________________________________________________________
%      options: structure containing optional inputs.
%      - 'rho_corr_type': string denoting the the correlation metric to use:
%             'Pearson' to compute Pearson's linear correlation coefficient
%             'Kendall' to compute Kendall's tau, 
%             'Spearman' to compute Spearman's rho.
%     (default,options.dwt_name='Spearman')
%
% =========================================================================
% Output: 
%       XI_features: a 1xN vector of XI feature values        
%
%       XI_feature_labels: a 1xN vector string of corresponding feature 
%       labels
% -----------------------------------------------------------------------
% References:
%   [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based
%       Remote Characterisation of Ambulation in Multiple Sclerosis during
%       the Two-Minute Walk Test," in IEEE Journal of Biomedical and
%       Health Informatics, doi: 10.1109/JBHI.2020.2998187.   
%   [2] Zhan, A., M. A. Little, D. A. Harris, S. O. Abiola, E. Dorsey, S.
%       Saria and A. Terzis (2016). "High Frequency Remote Monitoring of
%       Parkinson's Disease via Smartphone: Platform Overview and
%       Medication Response Detection." arXiv preprint arXiv:1601.00960.
%   [3] G. E. Box, G. M. Jenkins, G. C. Reinsel, and G. M. Ljung, Time
%       series analysis: forecasting and control. John Wiley Sons, 2015.
%
%% Andrew Creagh. Last modified on June 2020 

%% Initialisation and Parameterisation
% Initialise each feature as a NaN value as well as output feature vectors
% and corresponding feature labels
XI_features=NaN(1,5);
XI_feature_labels={'rCC_max', 'max_lag', 'rho_YZ', 'MI', 'condE'};

% If the sensor data is empty of a NaN value, return the initalised
% features as NaNs. This simple functionality allows the user to quickly
% generate the feature labels and NaN features. This is useful for
% initalising feature vectors, generating feature labels, and for
% integration into modular and scalable feature extraction pipelines. This
% is especially useful for dealing with feature extraction errors within a
% single sensor data file during feature extraction over a large number of
% sensor files. 

if isempty(y) || all(isnan(y)) || isempty(z) || all(isnan(z)) 
    return; end

%Parameterisation
rho_corr_type='Spearman';

if isfield(options, 'rho_corr_type')
    rho_corr_type=options.rho_corr_type; end
%% Feature Extraction
% Sample cross-correlation [3]
[acor,lags,bounds] = crosscorr(y,z, 'NumLags',length(y)-1);

% Maximum sample cross-correlation between y- and z-axis inertial sensor signal 
[rCC_max, mi]=max(abs(acor));
  
% Time lag at which the sample cross-correlation between the y- and z-axis
% inertial sensor signal is maximised
max_lag=lags(mi);           
                                               
% Linear or rank correlation between y- and z-axis inertial sensor signal
rho_YZ=corr(y,z, 'type', rho_corr_type);  
    
% Mutual information between y- and z-axis inertial sensor signal
MI=mutualinfo(y,z);   
                                                    
% Conditional entropy of  y- given z-axis inertial sensor signal 
condE=condentropy(y,z);   
                                                
%% Create Feature Vector
XI_features=[rCC_max, max_lag, rho_YZ, MI, condE];

end 