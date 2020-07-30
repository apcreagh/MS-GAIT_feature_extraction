function [SENSOR_DATA_OUT]=window_sensor_data(SENSOR_DATA, fs, options)
% Simple wrapper to perform windowing on triaxial inertial sensor
% data using the 'buffer.m' function.
%--------------------------------------------------------------------------
% Input:
%       SENSOR_DATA: a [N x C] matrix of inertial sensor data, where N are
%       the number of samples and C are the number of channels such that:
%           SENSOR_DATA(:,1) - a monotonically increasing time vector 
%           SENSOR_DATA(:,2) - X-axis sensor data
%           SENSOR_DATA(:,3) - Y-axis sensor data
%           SENSOR_DATA(:,4) - Z-axis sensor data
%
%      fs: the sampling frequency in Hertz [Hz] (optional)
% _________________________________________________________________________
%      options: structure containing optional inputs.
%     'window_length' float value, measured in seconds [s],  denoting the
%      segment (frames) length that sensor data will be partitioned into.
%     (default, options.window_length=10; [s]) 
%      'overlap_length' integer value, measured in seconds [s], which
%     controls the amount of overlap or underlap in the buffered frames. 
%     (default,options.overlap_length=5; [s])
%
% =========================================================================
% Output: 
%      SENSOR_DATA_OUT:  [N x W x C ] matrix of inertial sensor data, where
%      N are the number of samples, W are the number of windoes (epochs), 
%      subject to the windowing conditions set out by options or else 
%       default paramater settings, and C are the number of channels. 
%
%--------------------------------------------------------------------------
% References:
% [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%     Characterisation of Ambulation in Multiple Sclerosis during the
%     Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%     Informatics, doi: 10.1109/JBHI.2020.2998187.
%
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
% Last modified in June 2020
%
%% Paramaterization 
% If no fs given, calculate it
if isempty(fs) || isnan(fs)
    time=SENSOR_DATA(:, 1); 
    fs=round(1/median(diff(time))); %sampling freq, in Hertz [Hz}
end 

window_length = 10*fs; %# samples = [s]*sampling freq = sample length
overlap_length = 5*fs; %# samples overlap: [s]*sampling freq = sample length

if isfield(options, 'window_length')
    window_length=options.window_length*fs; end
if isfield(options, 'overlap_length')
    overlap_length=options.overlap_length*fs; end

%% Sensor Data Windowing
[num_samples, num_channels]=size(SENSOR_DATA);

%Initialise SENSOR_DATA_OUT by finding the sizes of the windowed data
%frame. We do this by using a dummy vector to gather the sizes. 

% we can have zero padding to maintain the desired frame overlap from one
% buffer to the next, or else 'nodelay' to skip the initial condition and
% begin filling the buffer immediately. See buffer.m documentation for a
% more detailed overview of zero and non-zero padding. 

%no zero padding
[y,~,~] = buffer(1:num_samples,window_length,overlap_length, 'nodelay'); 
%with zero padding
% [y,~,~] = buffer(1:num_samples,window_length,overlap_length); 

%Initialise SENSOR_DATA_OUT
num_epochs=size(y,2);
SENSOR_DATA_OUT=NaN(window_length, num_epochs,num_channels);

%Peform windowing
for channel_index = 1:num_channels
        x = SENSOR_DATA(:,channel_index);
        
        %%split into windows using the matlab buffer function
        %%(1) no zero padding
        [y,~,~] = buffer(x,window_length,overlap_length, 'nodelay');
        %%(2) with zero padding (buffer default)
        %[y,~,~] = buffer(x,window_length,overlap_length); 
        
        %load SENSOR_DATA_OUT foreach epoch
        SENSOR_DATA_OUT(:, :, channel_index)=y;

end

end
%EOF