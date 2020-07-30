function [DFA_features, DFA_feature_labels]=feat_dfa(x, options)
% Detrended Fluctuation Analysis (DFA)
% Function to compute DFA features from inertial sensor data (x) based on
% the work in [1]. Function utalises DFA code created by [2]. 
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
%       options: structure containing optional inputs. Currently unused. 
% =========================================================================
% Output: 
%       DFA_features: a 1xN vector of feature values 
%       DFA_feature_labels: a 1xN vector string of corresponding feature labels
%--------------------------------------------------------------------------
% References:
% [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%     Characterisation of Ambulation in Multiple Sclerosis during the
%     Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%     Informatics, doi: 10.1109/JBHI.2020.2998187.
% [2] M. Little, P. McSharry, I. Moroz, S. Roberts (2006),
%     Nonlinear, biophysically-informed speech pathology detection
%     in Proceedings of ICASSP 2006, IEEE Publishers: Toulouse, France.
%%    Andrew Creagh. Last modified on June 2020

%% Initialisation and Parameterisation
% Initialise each feature as a NaN value as well as output feature vectors
% and corresponding feature labels

DFA_features=NaN;DFA_feature_labels={'DFA'};

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

%% Detrended Fluctuation Analysis
dfa_scaling = (50:20:100)'; % DFA scaling range
% DFA using code created by Max Little [2]. 
% Performs fast detrended fluctuation analysis on a nonstationary input
% signal to obtain an estimate for the scaling exponent
dfa = fastdfa(x, dfa_scaling);
DFA = 1/(1+exp(-dfa));

%% Create Feature Vector
% *just one feature for now... 
  DFA_features=DFA;

end 
%EOF