function SENSOR_DATA=normalise_data(SENSOR_DATA, options)
% Function to normalise triaxial inertial sensor data.
%--------------------------------------------------------------------------
% Input:
%     SENSOR_DATA: a [N x C] matrix of inertial sensor data, where N are 
%     the number of samples and C are the number of channels such that:
%          SENSOR_DATA(:,1) - conatins the time vector
%          SENSOR_DATA(:,2) - X-axis sensor data
%          SENSOR_DATA(:,3) - Y-axis sensor data
%          SENSOR_DATA(:,4) - Z-axis sensor data
% _________________________________________________________________________
%    options: structure containing optional inputs
%    - 'detrend' 0/1 (binary off/on). Functionality to detrend the 
%       raw sensor data (default,options.detrend=0, off)
%    - 'zscore'  0/1 (binary off/on). Functionality to zscore normalise the 
%       raw sensor data (default,options.zscore=0, off)
%
% =========================================================================
% Output: 
%     SENSOR_DATA: a [N x C] matrix of normalised inertial sensor data
%     depending on the conditions set out by the options structure, where N
%     are the number of samples and C are the number of channels such that:
%       SENSOR_DATA(:,1) - conatins the time vector 
%       SENSOR_DATA(:,2) - X-axis normalised sensor data 
%       SENSOR_DATA(:,3) - Y-axis normalised sensor data 
%       SENSOR_DATA(:,4) - Z-axis normalised sensor data 
%--------------------------------------------------------------------------
% Reference:
% [1]  A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%      Characterisation of Ambulation in Multiple Sclerosis during the
%      Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%      Informatics, doi: 10.1109/JBHI.2020.2998187.
%
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
% Last modified in June 2020
%
%% Normalise sensor data

[~, num_channels]=size(SENSOR_DATA);
for channel=1:num_channels
    
    if isfield(options, 'detrend') && options.detrend
        SENSOR_DATA(:, channel)=detrend(SENSOR_DATA(:, channel));
    end
    if isfield(options, 'zscore') && options.zscore
        SENSOR_DATA(:, channel)=zscore(SENSOR_DATA(:, channel));
    end
    
end