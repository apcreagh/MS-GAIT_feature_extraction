function [SNR_IMF_features, SNR_IMF_feature_labels]=feat_imf(x, fs, options)
% Signal-to-Noise (SNR) frequecny based features using Intrinsic mode
% Functions (IMFs). IMFs are computed using Empericial Mode Decomposition
% (EMD) by the Hilbert-Huang transform (HHT) to encode instantaneous
% frequency and amplitude information. Features are relate to work by
% Creagh et al. (2020) [1], where IMF analysis has been inspied from [2].
% Implementation of IMF-EMD has been adapted from [3].
%--------------------------------------------------------------------------
% Input:
%       x: a [1 x N] or [N x 1] vector of inertial sensor data (for example
%       the vertical accleration)
%
%       * if x == [] or x==NaN, the output feature vector is returned as a
%       [1xN] vector of NaNs, along with a [1xN] vector string of
%       corresponding feature labels
%       
%       fs: the sampling frequency in Hertz [Hz] of the signal x. 
% _________________________________________________________________________
% Optional Inputs: 
%      options: structure containing optional inputs.
%      - 'IMF_signal_noise_threshold': an integer denoting how many IMFs 
%        charactise the signal vs. the high frequency compoents of "noise" 
%        in the SNR ratio.
%        (default: options.IMF_signal_noise_threshold=4);
%        e.g. for IMF_signal_noise_threshold=4, the 4th IMF and greater
%        characterises the signal, where the 1st, 2nd and 3rd IMF
%        characteise the "noise" compoents of x
%        - 'resample_signal':  0/1 (binary off/on). 
%          Functionality to window the inertial sensor data and take the 
%          maximum value of x every epoch as a resampled signal.  
%         (default on: options.buffer_values=1)
%        - 'epoch_size': an integer indicating the window size to
%          sub-sample the inertial sensor data x.
%         (default: options.epoch_size=0.05;) 
%         i.e. partition x into 0.05 second [s] non-overlapping windows 
% =========================================================================
% Output: 
%       SNR_IMF_features: a 1xN vector of feature values 
%       SNR_IMF_feature_labels: a 1xN vector string of corresponding 
%       feature labels
%
%--------------------------------------------------------------------------
% References:
% [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%     Characterisation of Ambulation in Multiple Sclerosis during the
%     Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%     Informatics, doi: 10.1109/JBHI.2020.2998187.
% [2] P. Ren et al., “Gait rhythm fluctuation analysis for
%     neurodegenerative diseases by empirical mode decomposition,” IEEE
%     Trans. Biomed. Eng., 830 vol. 64, no. 1, pp. 52–60, Jan. 2017.
% [3] A. Tsanas: "Accurate telemonitoring of Parkinson's disease symptom
%    severity using nonlinear speech signal processing and statistical
%    machine learning", D.Phil. thesis, University of Oxford, 2012
%
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
%  Last modified on June 2020

%% Initialisation and Parameterisation
% Initialise each feature as a NaN value as well as output feature vectors
% and corresponding feature labels

IMF_signal_noise_threshold=4; 
resample_signal=0;
epoch_size=0.05; % 0.05 [s]
                          
if isfield(options, 'IMF_signal_noise_threshold')
    IMF_signal_noise_threshold=options.IMF_signal_noise_threshold; end 
if isfield(options, 't_delay') 
    epoch_size=options.t_delay; 
    resample_signal=1;
end 
if isfield(options, 'resample_signal')
    resample_signal=options.resample_signal; end 

% Initailse feature vectors 
SNR_IMF_features=NaN(1, 3);
SNR_IMF_feature_labels={'IMF_SNR_SEO', 'IMF_SNR_TKEO', 'IMF_SNR_H'}; 

% Append feature labels with epoch_size parameter, if resampling the signal
if resample_signal==1
SNR_IMF_feature_labels=strcat(SNR_IMF_feature_labels, '_', strrep(num2str(epoch_size), '.', '_'));
end 

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

%% Epoch (window) inertial sensor data
% Functionality to window the inertial sensor data and take the
% maximum value of x every epoch as a resampled signal.
if resample_signal==1
    data_resampled = buffer(x,round(epoch_size*fs));
    x = max(abs(data_resampled)); %max value every t_delay [s]
end

%% Feature Computation 

%Use classical EMD
%Returns intrinsic mode functions (IMF)
% lets not display the output for each IMF during decomposition process,
% ('Display', 0)
IMF_dec = emd(x,  'Display', 0); 
IMF_dec=IMF_dec';
[N,M]=size(IMF_dec);

%for each IMF
for i=1:M
    %Energy (E) of IMF(i)
    IMF_decEnergy(i) = abs(mean((IMF_dec(:,i)).^2));
    %TKEO (E) of IMF(i)
    IMF_decTKEO(i) = abs(mean(TKEO(IMF_dec(:,i))));
    %Entropy (H) of IMF(i)
    IMF_decEntropy(i) = abs(mean(-sum(IMF_dec(:,i).*log_bb(IMF_dec(:,i)))));
end

                          
% Get Signal-to-Noise (SNR) ratio measures
SNR_IMF_features(1) = sum(IMF_decEnergy(IMF_signal_noise_threshold:end))/sum(IMF_decEnergy(1:IMF_signal_noise_threshold-1));
SNR_IMF_features(2) = sum(IMF_decTKEO(IMF_signal_noise_threshold:end))/sum(IMF_decTKEO(1:IMF_signal_noise_threshold-1));
SNR_IMF_features(3) = sum(IMF_decEntropy(IMF_signal_noise_threshold:end))/sum(IMF_decEntropy(1:IMF_signal_noise_threshold-1));

 
%% EMBEDDED FUNCTIONS
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

function pout = log_bb(pin, method)
% Function that computes the algorithm depending on the user specified
% base; if the input probability is zero it returns zero.
% Adapted from [3]

if nargin<2
    method = 'Nats';
end

switch (method)
    case 'Hartson' % using log10 for the entropy computation
        log_b=@log10;
        
    case 'Nats' % using ln (natural log) for the entropy computation 
        log_b=@log;
       
    otherwise % method -> 'Bits' using log2 for the entropy computation 
        log_b=@log2;
end

if pin==0
    pout=0;
else
    pout=log_b(pin);
end

end

end
%EOF