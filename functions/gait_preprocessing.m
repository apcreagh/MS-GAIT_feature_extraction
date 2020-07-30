function [SENSOR_DATA, fs]=gait_preprocessing(SENSOR_DATA, options)
% Shell function to preprocess the inertial sensor data according to the
% work presented in in [1]. This includes the raw sensor data
% visualisation, the filtering, orientation transformation and any sensor
% data normalisation (if necessary).
%--------------------------------------------------------------------------
% Input:
%     SENSOR_DATA: a [N x C] matrix of inertial sensor data, where N are
%     the number of samples and C are the number of channels such that:
%       SENSOR_DATA(:,1) - conatins the monotonically increasing time vector 
%       SENSOR_DATA(:,2) - X-axis sensor data
%       SENSOR_DATA(:,3) - Y-axis sensor data
%       SENSOR_DATA(:,4) - Z-axis sensor data
% _________________________________________________________________________
%     options: structure containing optional inputs.
%     - 'plot_sensor_data' 0/1 (binary off/on). Functionality to plot the 
%       raw sensor data (default,options.plot_sensor_data=0, off)
%     - 'orientation_independent_transformation' 0/1 (binary off/on).
%     Functionality to perform orientation_independent_transformation
%     (default, options.orientation_independent_transformation=1, on).
%     - 'normalise_sensor_data' 0/1 (binary off/on). Functionality to
%     detrend and normalise (zscore) the sensor data 
%      (options.normalise_sensor_data=0, off).
% =========================================================================
% Output:
%     SENSOR_DATA: a [N x C] matrix of pre-processed inertial sensor data
%     depending on the conditions set out by the options structure, where N
%     are the number of samples and C are the number of channels such that:
%       SENSOR_DATA(:,1) - conatins the time vector 
%       SENSOR_DATA(:,2) - X-axis sensor data 
%       SENSOR_DATA(:,3) - Y-axis sensor data 
%       SENSOR_DATA(:,4) - Z-axis sensor data 
%       SENSOR_DATA(:,5) - The magnitude of X-, Y- and Z-axis sensor data
%
% -------------------------------------------------------------------------
% Reference:
% [1]  A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%      Characterisation of Ambulation in Multiple Sclerosis during the
%      Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%      Informatics, doi: 10.1109/JBHI.2020.2998187.
%
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
% Last modified in June 2020
%
%% Parameterization 
orientation_transform=1;
plot_sensor_data=0;
normalise_sensor_data=0;

if isfield(options, 'orientation_transform')
orientation_transform=options.orientation_transform;end 
if isfield(options, 'plot_sensor_data')
plot_sensor_data=options.plot_sensor_data; end 
if isfield(options, 'normalise_sensor_data')
normalise_sensor_data=options.normalise_sensor_data;end 

%% Sensor Data Pre-Processing
time=SENSOR_DATA(:,1); aX=SENSOR_DATA(:,2); aY=SENSOR_DATA(:,3); aZ=SENSOR_DATA(:,4); 

%Represent sensor data in terms of gravity
g=9.81; %gravity (g) = 9.81 ms^-2;
aX=aX/g; aY=aY/g; aZ=aZ/g; 

%the sampling frequency. Sometimes smartphone/smartwatches do not sample at
%an exact same rate. There we take the median sampling frequency over all
%paired sample differences
fs=round(1/median(diff(time)));

% Functionality to plot the raw sensor data (controlled with options
% structure above)
if plot_sensor_data
    options.plot_title='Raw Sensor Data';
    plot_data(SENSOR_DATA, options);
end

%% Filtering
% In this case we use a 4th order butterworth with a cut-off frequecny at
% 17Hz
fc=17; %cut off freqyuency (for exampple 17 Hz)
n=4; %4th order
Wn=fc/fs;
% design the filter
[B,A] = butter(n, Wn);
%apply filter to X-, Y, Z- axis inertail sensor data
aX = filtfilt(B, A, aX);                                     
aY = filtfilt(B, A, aY);                                     
aZ = filtfilt(B, A, aZ);                                     

%combine filtered data back to a matrix
SENSOR_DATA=[time, aX, aY, aZ];

%% Orientation Independent Transformation
if orientation_transform
a_transform=orientation_independent_transformation(SENSOR_DATA, fs, options);
SENSOR_DATA=a_transform;
end 

%% Magnitude of Sensor Data
%take the magnitude of the X-, Y-, and Z-axis sensor data
aMag=sqrt(SENSOR_DATA(:,2).^2 + SENSOR_DATA(:,3).^2 + SENSOR_DATA(:,4).^2);
%concatonate this to the SENSOR_DATA matrix
SENSOR_DATA=[SENSOR_DATA, aMag];

%% Inertial Sensor Data Normalisation
% depending on the application we might want to detrend and normalise the
% raw sensor data here Functionality to normalise the raw sensor data is
% controlled with options structure above
if normalise_sensor_data
SENSOR_DATA(:,2:end)=normalise_data(SENSOR_DATA(:,2:end), options); end 


end 

%EOF