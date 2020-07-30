function [H_features, H_feature_labels]=feat_entropy(x, options)
% Entropy-based feature extraction. Function to compute entropy-based
% features from inertial sensor data (x), which have been grouped together.
% Features are based on the work in [1].
%--------------------------------------------------------------------------
% Input:
%       x: a [1 x N] or [N x 1] vector of inertial sensor data (for example
%       the vertical accleration)
%
%       * if x == [] or x==NaN, the output feature vector is returned as a
%       [1xN] vector of NaNs, along with a [1xN] vector string of
%       corresponding feature labels
% _________________________________________________________________________
%
% Optional Inputs: 
%       options: structure containing optional inputs. See specific
%       extraction functions for specific functionality
% =========================================================================
% Output: 
%       H_features: a 1xN vector of feature values 
%       H_feature_labels: a 1xN vector string of corresponding feature labels
%
%--------------------------------------------------------------------------
% References:
% [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%     Characterisation of Ambulation in Multiple Sclerosis during the
%     Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%     Informatics, doi: 10.1109/JBHI.2020.2998187.
% [2] R. M. Gray, Entropy and information theory. Springer Science
%     Business Media, 2011. 
% [3] S. M. Pincus, “Approximate entropy as a measure of system complexity,
%     ” Proceedings of the National Academy of Sciences, vol. 88,
%     no. 6, pp. 2297–2301, 1991 
% [4] M. A. Little, P. E. McSharry, S. J. Roberts, D. A. Costello, 
%     and I. M. Moroz, “Exploiting nonlinear recurrence and fractal
%     scaling properties for voice disorder detection,” 
%     Biomedical engineering online, vol. 6, no. 1, p. 23, 2007.
% [5] M. Costa, A. L. Goldberger, and C.-K. Peng, “Multiscale entropy
%     analysis of complex physiologic time series,” Physical review
%     letters, vol. 89, no. 6, p. 068102, 2002.
% [6] M. Costa, C. K. Peng, A. L. Goldberger, and J. M. Hausdorff,
%     “Multiscale entropy analysis of human gait dynamics,” Physica A: 
%     Statistical Mechanics and its Applications, vol. 330, no. 1,
%     pp. 53–60, 2003. 
% [7] J. Yu, J. Cao, W.-H. Liao, Y. Chen, J. Lin, and R. Liu, “Multivariate
%     multiscale symbolic entropy analysis of human gait signals,” Entropy, 
%      vol. 19, no.10, p. 557, 2017.
%
%% Andrew Creagh. Last modified on June 2020

%% Initialisation and Parameterisation
% Initialise each feature as a NaN value as well as output feature vectors
% and corresponding feature labels

[H, H_rate, ApEn, RPDE]=deal(NaN);
%initalise values for MsEn (see below), using the feat_msen.m function 
[MsEn, mSE_labels]=feat_msen([], options);

H_features=[H, H_rate, ApEn, RPDE, MsEn];
H_feature_labels=[{'H', 'H_rate', 'ApEn', 'RPDE'}, mSE_labels];

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

% Classic entropy [2]
H=entropy(x);
% Entropy in (in bits)[2]
H_rate=entropy_rate(x); 

%Approximate Entropy [3]
ApEn=feat_apen(x, options);

%Recurrance Period Density Entropy [4]
RPDE=feat_rpde(x, options);

%Multi-scale (Sample) Entropy [5-7]
[MsEn, mSE_labels]=feat_mse(x, options);

%% Create Feature Vector
H_features=[H, H_rate, ApEn, RPDE, MsEn];

end 

%EOF