function [DWT_features, DWT_feature_labels]=feat_wavedec(x, options)
% Wavelet Decomposition. A sparse representation of inertial sensor data x
% is obtained using the Discrete Wavelet Transform (DWT), where the signal
% x is decomposed into a number of different bandwidths expressed by
% approximation cAj and detail cDj coefficients at level j = [1, 2, 3,...L]
% Features are extracted according to [1]. This function is based on work
% by Tsanas et al. 2010 [2]. 
%--------------------------------------------------------------------------
% Input:
%       x: a [1 x N] or [N x 1] vector of inertial sensor data (for example
%       the vertical accleration)
%
%       * if x == [] or x==NaN, the output feature vector is returned as a
%       [1xN] vector of NaNs, along with a [1xN] vector string of
%       corresponding feature labels
% _________________________________________________________________________
% Optional Inputs: 
%      options: structure containing optional inputs.
%      - 'dwt_name': string denoting the the wavelet family to be use. 
%       See 'wavedec.m' for further information on calling various wavelets
%       (default,options.dwt_name='db2')
%      - 'dec_levels': number of DWT decomposition levels
%       (default,options.dec_levels=10)
%
% =========================================================================
% Output: 
%       DWT_features: a 1xN vector of DWT feature values        
%
%       DWT_feature_labels: a 1xN vector string of corresponding feature 
%       labels
% -----------------------------------------------------------------------
% References:
%
%   [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based
%       Remote Characterisation of Ambulation in Multiple Sclerosis during
%       the Two-Minute Walk Test," in IEEE Journal of Biomedical and
%       Health Informatics, doi: 10.1109/JBHI.2020.2998187.
%
%   [2] A. Tsanas, M.A. Little, P.E. McSharry, L.O. Ramig: "New nonlinear
%       markers and insights into speech signal degradation for effective
%       tracking of Parkinson’s disease symptom severity", International
%       Symposium on Nonlinear Theory and its Applications (NOLTA), pp.
%       457-460, Krakow, Poland, 5-8 September 2010
%
%% Andrew Creagh. Last modified on June 2020 

%% Initialisation and Parameterisation
% Initialise each feature as a NaN value as well as output feature vectors
% and corresponding feature labels

dwt_name = 'db2';
dec_levels = 10;

%Parameterisation from options files
if isfield(options, 'dwt_name')
    dwt_name=options.dwt_name;end 
if isfield(options, 'dec_levels')
    dec_levels=options.dec_levels;end 

% determine the number of features that will be extracted with the
% parameters given. 

%Initialise features
num_features= 1 + dec_levels + 8*dec_levels + 4*2; 
DWT_features=NaN(1, num_features);

%Initialise feature labels
DWT_feature_labels=[...
    {'Ea'};...
    strcat('Ed_', split(num2str(1:dec_levels)), '_coef');...
    {'det_max';'det_min';'det_mean';'det_var'};...
    strcat('det_entropy_shannon_', split(num2str(1:dec_levels)), '_coef');...
    strcat('det_entropy_log_', split(num2str(1:dec_levels)), '_coef');...
    strcat('det_TKEO_mean_', split(num2str(1:dec_levels)), '_coef');...
    strcat('det_TKEO_std_', split(num2str(1:dec_levels)), '_coef');...
    {'app_max';'app_min';'app_mean';'app_var'};...
    strcat('app_entropy_shannon_', split(num2str(1:dec_levels)), '_coef');...
    strcat('app_entropy_log_', split(num2str(1:dec_levels)), '_coef');...
    strcat('app_TKEO_mean_', split(num2str(1:dec_levels)), '_coef');...
    strcat('app_TKEO_std_', split(num2str(1:dec_levels)), '_coef')...
    ];

%transpose DWT_feature_labels to be a [1xN] vector
DWT_feature_labels=DWT_feature_labels';

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

%% Wavelet decomposition
[C, L] = wavedec(x, dec_levels, dwt_name); % compute decomposition

% % If we want to have a look at the DWT Wavelet packet decomposition 1-D and
% % to view the wavelet packets colored coefficients and filter
% tree = wpdec(x,dec_levels,dwt_name);
% plot(tree);
% wpviewcf(tree,2);
% 1-D wavelet decomposition same as below...
% [Lo_D,Hi_D] = wfilters(dwt_name);
% [A,D] = dwt(x,Lo_D,Hi_D);

%% Wavelet Feature Extraction
%initialise features to be created in for loop for best practice
[...
    det_entropy_shannon, det_entropy_log, det_TKEO_mean, det_TKEO_std,...
    app_entropy_shannon, app_entropy_log, app_TKEO_mean, app_TKEO_std]=deal(NaN(1, dec_levels));

% Approximation and detail coeffficent energy for 1-D wavelet decomposition.
[Ea, Ed(1,:)] = wenergy(C, L); 

for j = 1:dec_levels
    d = detcoef(C,L,j); % Detail coefficients in levels j=[1,2...L], dec_levels
    det_max=max(d);% max detail coef.
    det_min=min(d);% min detail coef.
    det_mean=mean(d);% mean detail coef.
    det_var=var(d); % variance in detail coef.

    % shannon's entropy (H) of detail coef @ level j
    det_entropy_shannon(1, j) = wentropy(d, 'shannon');
    % log entropy (H) of detail coef @ level j
    det_entropy_log(1, j) = wentropy(d, 'log energy');
    % mean TKEO of detail coef @ level j
    det_TKEO_mean(1, j) = mean(TKEO(d));
    % standard deviation in TKEO of detail coef @ level j
    det_TKEO_std(1, j) = std(TKEO(d));
end

for j = 1:dec_levels
    a = appcoef(C,L,dwt_name, j); % Approximation coefficients in levels 1...dec_levels
    app_max=max(a); % max approx. coef. 
    app_min=min(a); % min approx. coef.
    app_mean=mean(a); % mean approx. coef.
    app_var=var(a);   % variance in approx. coef.

    % shannon's entropy (H) of approx. coef @ level j   
    app_entropy_shannon(1, j) = wentropy(a, 'shannon');
    % log entropy (H) of approx. coef @ level j
    app_entropy_log(1, j) = wentropy(a, 'log energy');
    % mean TKEO of approx. coef @ level j
    app_TKEO_mean(1, j) = mean(TKEO(a));
    % standard deviation in TKEO of approx. coef @ level j
    app_TKEO_std(1, j) = std(TKEO(a));

end
%% Create Feature Vector

DWT_features=[...
    Ea, Ed,...
    det_max, det_min, det_mean, det_var, ...
    det_entropy_shannon, det_entropy_log, det_TKEO_mean, det_TKEO_std,...   
    app_max,app_min, app_mean, app_var,...
    app_entropy_shannon, app_entropy_log, app_TKEO_mean, app_TKEO_std,...
    ];

end 
% Simple TKEO function
function [energy] = TKEO(x)
% Adapted from [3]
data_length=length(x);
energy=zeros(data_length,1);

energy(1)=(x(1))^2; % first sample in the vector sequence

for n=2:data_length-1
    energy(n)=(x(n))^2-x(n-1)*x(n+1); % classical TKEO equation
end

energy(data_length)=(x(data_length))^2; % last sample in the vector sequence

end % end of TKEO function


%EOF

