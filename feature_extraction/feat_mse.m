function [msE_features, msE_feature_labels]=feat_msen(x, options)
% Multi-scale (Sample) Entropy feature extraction. Multiscale entropy
% (MsEn) calculates the sample entropy (SampEn) of a signal at increasingly
% coarser grains (scales) % Features are based on the work in [1-4].
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
%     options: structure containing optional inputs.
%     - 'num_mse_scales': integer value. Functionality to define the
%     maximum number of scales to calulate the Sample Entropy
%     (default,num_mse_scales=20)
%      See third party 'msentropy.m' function for further functionality
%
% =========================================================================
% Output: 
%       msE_features: a 1xN vector of multi-scale entropy feature values.
%       Features are exacted at each scale (where the number of scales are
%       defined by 'num_mse_scales'.
%
%       msE_feature_labels: a 1xN vector string of corresponding feature 
%       labels
%--------------------------------------------------------------------------
% References:
%    [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based
%        Remote Characterisation of Ambulation in Multiple Sclerosis during 
%        the Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%        Informatics, doi: 10.1109/JBHI.2020.2998187.
%    [2] M. Costa, A. L. Goldberger, and C.-K. Peng, “Multiscale entropy
%        analysis of complex physiologic time series,” Physical review
%        letters, vol. 89, no. 6, p. 068102, 2002.
%    [3] M. Costa, C. K. Peng, A. L. Goldberger, and J. M. Hausdorff,
%        “Multiscale entropy analysis of human gait dynamics,” Physica
%        A: Statistical Mechanics and its Applications, vol. 330, no. 1,
%        pp. 53–60, 2003.
%    [4] J. Yu, J. Cao, W.-H. Liao, Y. Chen, J. Lin, and R. Liu,
%        “Multivariate multiscale symbolic entropy analysis of human gait
%        signals,” Entropy, vol. 19, no. 10, p. 557, 2017.
% 
% Andrew Creagh. Last modified on June 2020  
%% Initialisation and Parameterisation
% Initialise each feature as a NaN value as well as output feature vectors
% and corresponding feature labels. Define parameters from options function
% (if not the default)

num_mse_scales=20;
if isfield(options, 'num_mse_scales')
    num_mse_scales=options.num_mse_scales; end 

msE_feature_labels(1,:)=cellstr(strcat('msE_',split(num2str(1:num_mse_scales))));
msE_features=NaN(1, num_mse_scales);

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

%% Multi-Scale Entropy
%use defualt parameters
[msE_features(1, :),~,info]=msentropy(x,[],[],[],[],[],[],[],num_mse_scales);
%We could also parameterize msentropy like below (see msentropy.m fucntion
%for further information on this.
% [y,scale,info]=msentropy(data,dn,dm,dr,N,N0,minM,maxM,num_mse_scales,minR,maxR);


end   
 
%EOF