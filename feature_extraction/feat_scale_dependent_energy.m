function [Es_features,Es_feature_labels]=feat_scale_dependent_energy(x, fs, options)
% Extract features related to the maximum scale-dependent energy density Es
% of the continuous wavelet transform (CWT) of a discrete time signal using
% analytic wavelets. Features are extracted based on the work in [1]. CWT
% analysis is adapted from [2] and [3].
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
%
% Optional Inputs: 
%       options: structure containing optional inputs. 
%      - 'cwt_name': string denoting the analytic wavelet family to use. 
%       See 'cwt.m' for further information on calling various wavelets and
%       parameteras associated with such. 
%       (default,options.cwt_name='amor')
%         Analytic wavelets:
%             - Analytic Morlet (Gabor) Wavelet: 'amor'
%             - Morse Wavelet Family: 'morse'
%             - Bump:  'bump'
% =========================================================================
% Output: 
%       Es_features: a 1xN vector of feature values 
%       Es_feature_labels: a 1xN vector string of corresponding feature labels
%
%--------------------------------------------------------------------------
% References:
% [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%     Characterisation of Ambulation in Multiple Sclerosis during the
%     Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%     Informatics, doi: 10.1109/JBHI.2020.2998187.
% [2] P. S. Addison, J. Walker, and R. C. Guido, “Time–frequency analysis 
%     of biosignals,” IEEE Eng. Medicine Biol. Mag., vol. 28, no. 5,
%     pp. 14–29, Sep./Oct. 2009. 823
% [3] S. Khandelwal and N. Wickström, “Novel methodology for estimating
%     initial contact events from accelerometers positioned at different 
%     body 825 locations,” Gait Posture, vol. 59, pp. 278–285, 2018
%
%% Andrew Creagh. Last modified on June 2020 

%% Initialisation
% Initialise each feature as a NaN value as well as output feature vectors
% and corresponding feature labels

[...
    Epk, f_max, E_m, E_std, E_skew, E_kurt, E_sum,...
    E_width, E_prom, E_Pk_ratio, E_width_ratio, f_ratio]=deal(NaN);

Es_features=[...
    Epk, f_max, E_m, E_std, E_skew, E_kurt, E_sum,...
    E_width, E_prom, E_Pk_ratio, E_width_ratio, f_ratio];

Es_feature_labels={...
    'Epk', 'f_max', 'E_m', 'E_std', 'E_skew', 'E_kurt', 'E_sum',...
    'E_width', 'E_prom', 'E_Pk_ratio', 'E_width_ratio', 'f_ratio'};

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

%% Parameterisation
cwt_name='amor'; %Morlet

if isfield(options, 'wname')
    cwt_name=options.cwt_name; end 

%% Continuous Wavelet Transform (CWT)

% The continuous wavelet transform (CWT) of x at each scale
[Wn,f,~,~,~] =cwt(x, cwt_name, fs);
[scales, samples]=size(Wn);

% The total signal energy at a specific scale can be measured by the
% scale-dependent energy density spectrum E_s:
for s=1:scales
 E_s(s, 1)=sum(abs(Wn(s,:)).^2);  end 

%flip vectors so we consider Es and f in ascending order rather than descending order
E_s=flip(E_s);
f=flip(f);
 
%% Compute Features

%The maximum scale-dependent energy density E_s of the CWT.
[Epk, mi]=max(E_s); 
 
%The frequency (fmax), in Hz, which maximises E_s over all scales.
f_max=f(mi);

%The average E value over all scales s.
E_m=mean(E_s);

%The standard deviation in the values of E over all scales s.
E_std=std(E_s);

%Skewness as a measure of the asymmetry of the probability distribution of
%the scale dependent energy distribution E over all scales s.
E_skew=skewness(E_s);

%The kurtosis in the values of E over all scales s.
E_kurt=kurtosis(E_s);

%The area under the curve (AUC) approximate integral of E over all scales s
E_sum=trapz(f, E_s);

%Use the findpeaks.m function to determine the peaks in the E_s values
[pks, locs, widths, prom]=findpeaks(E_s);
% sort the E_s peaks in descending order (i.e. biggest first)

[pks, si]=sort(pks, 'descend');
%sort the width values in descending order
widths=widths(si);
%sort the prominence values in descending order
prom=prom(si);
%sort the prominence values in descending order
locs=locs(si);

%The width Ew of the maximum scale-dependent energy density Epk.
E_width=widths(1);

%The prominence of the maximum scale-dependent energy density peak Epk
E_prom=prom(1);

%The ratio of the maximum scale-dependent energy peak density to next highest peak.
E_Pk_ratio=pks(1)/pks(2);

%The ratio of the width of the maximum scale-dependent energy peak density to next highest peak.
E_width_ratio=widths(1)/widths(2);

%The ratio of the frequency that maximises the scale-dependent energy peak
%density, fmax, to the frequency that maximises the next highest peak
f_ratio=f(locs(1))/f(locs(2));

%% Create Feature Vector
Es_features=[Epk, f_max, E_m, E_std, E_skew, E_kurt, E_sum, E_width, E_prom, E_Pk_ratio, E_width_ratio, f_ratio];

end 
% EOF