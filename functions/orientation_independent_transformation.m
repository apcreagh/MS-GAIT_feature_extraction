function [SENSOR_DATA_TRANSFORMED]=orientation_independent_transformation(SENSOR_DATA, fs, options)
% Function that takes in trixial inertial sensor data and translates to
% a new orientation invarient coordinate system using three orthogonal
% versors, whose orientation is independent of that of the smartphone and
% alligned with gravity and the direction of motion
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
%     - 'plot_rotation' 0/1 (binary off/on). Functionality to plot the raw
%     sensor data and the orientation independent transformation 
%     of the sensor data (default,off)
% =========================================================================
% Output: 
%   SENSOR_DATA_TRANSFORMED:    a [N x C] matrix of transformed sensor data
%       SENSOR_DATA_TRANSFORMED(:,1) - conatins the monotonically 
%                                      increasing time vector 
%       SENSOR_DATA_TRANSFORMED(:,2) - X-axis sensor data
%       SENSOR_DATA_TRANSFORMED(:,3) - Y-axis sensor data
%       SENSOR_DATA_TRANSFORMED(:,4) - Z-axis sensor data
% Where:
%       X: medio_lateral - phi - points forward, alligned with the
%       direction of motion
%       Y: longitudinal - zeta - points upwards & parallel to users torso
%       Z: anterior_posterior- xi - tracks lateral motion and orthogonal to
%       other two axis
% -------------------------------------------------------------------------
% Reference
% [1] A. P. Creagh et al. (2020), "Smartphone- and Smartwatch-Based Remote
%     Characterisation of Ambulation in Multiple Sclerosis during the
%     Two-Minute Walk Test," in IEEE Journal of Biomedical and Health
%     Informatics, doi: 10.1109/JBHI.2020.2998187.
% [2] Gadaleta, M. and M. Rossi (2018). "IDNet: Smartphone-based gait
%     recognition with convolutional neural networks." Pattern Recognition
%     74(Supplement C): 25-37.
% 
%% Andrew Creagh. andrew.creagh@eng.ox.ac.uk
%  Last modified on June 2020

%% Initalisation
% I've had enough of warnings!
warning('off', 'stats:pca:ColRankDefX')

time=SENSOR_DATA(:,1);
aX=SENSOR_DATA(:, 2); aY=SENSOR_DATA(:, 3); aZ=SENSOR_DATA(:, 4); %all should be column vectors i.e. x=[x1,x2,x3, ...xn]^T

%% Orientation Transformation
% change coordinate system to match paper coordinate system. See [2] fpr
% full mathematical description of the orientation transformation process.  
aaX=aX; aaY=aY; aaZ=aZ;
aX=aaX; aY=aaZ; aZ=aaY;

pk=[mean(aX), mean(aY), mean(aZ)]'; %gravity versor

zeta=pk/norm(pk);

A=[aX, aY, aZ]';

a_zeta=A'*zeta;

Af=A-(zeta*a_zeta');

% U=mean(Af, 2);
% nk=length(Af);
% Af_norm=Af-U*(ones(nk,1)');
% covMat=(Af_norm*Af_norm')/nk-1;
% [i, j]=chol(covMat);
% eigenvalues=eig(covMat);
% [eigenvectors,eigenvalues, W]=eig(covMat);
% [mD, mi]=max(D);
% eigenvectors/norm(eigenvectors);

[eigenvectors, score, eigenvalues, TSQUARED, EXPLAINED, MU]=pca(Af');

max_eigenvector=eigenvectors(:,1);
xi=max_eigenvector/norm(max_eigenvector);

a_xi=A'*xi;

phi=cross(zeta, xi);

a_phi=A'*phi;

%Concatonate sensor data matrix
SENSOR_DATA_TRANSFORMED=[time, a_phi, a_zeta, a_xi];

%Plot orientation transform
if isfield(options, 'plot_orientation_transform') && options.plot_orientation_transform

start_time=10;
time_length=5;  %5 seconds [s]  
if isfield(options, 'start_time') 
    start_time=options.start_time;
end 
if isfield(options, 'time_length')
    time_length=options.time_length;
end 
samples=int16((start_time*fs):1:((start_time+time_length)*fs));

%%

figure
subplot(2,1,1)
plot(SENSOR_DATA(samples,1), SENSOR_DATA(samples,2))
hold on
plot(SENSOR_DATA(samples,1), SENSOR_DATA(samples,3))
hold on
plot(SENSOR_DATA(samples,1), SENSOR_DATA(samples,4))
ylabel('Acceleration (m.s^{-2})')
xlabel('Time [s]')
legend('aX', 'aY', 'aZ')
title('Before Orientation Transform')

subplot(2,1,2)
plot(SENSOR_DATA_TRANSFORMED(samples,1), SENSOR_DATA_TRANSFORMED(samples,2))
hold on
plot(SENSOR_DATA_TRANSFORMED(samples,1), SENSOR_DATA_TRANSFORMED(samples,3))
hold on
plot(SENSOR_DATA_TRANSFORMED(samples,1), SENSOR_DATA_TRANSFORMED(samples,4))
ylabel('Acceleration (m.s^{-2})')
xlabel('Time [s]')
legend('aX', 'aY', 'aZ')
title('After Orientation Transform')

%%
% figure
% ax11=subplot(3,2,1);
% plot(DATA(samples,1), DATA(samples,2))
% ylabel('X')
% xlabel('Time [s]')
% 
% ax12=subplot(3,2,2);
% plot(SENSOR_DATA_TRANSFORMED(samples,1), SENSOR_DATA_TRANSFORMED(samples,2))
% xlabel('Time [s]')
% ylabel('Xi')
% 
% ax21=subplot(3,2,3);
% plot(DATA(samples,1), DATA(samples,3))
% ylabel('Y')
% 
% xlabel('Time [s]')
% ax22=subplot(3,2,4);
% plot(SENSOR_DATA_TRANSFORMED(samples,1), SENSOR_DATA_TRANSFORMED(samples,3))
% xlabel('Time [s]')
% ylabel('Zeta')
% 
% ax31=subplot(3,2,5);
% plot(DATA(samples,1), DATA(samples,4))
% ylabel('Z')
% xlabel('Time [s]')
% 
% ax32=subplot(3,2,6);
% plot(SENSOR_DATA_TRANSFORMED(samples,1), SENSOR_DATA_TRANSFORMED(samples,4))
% ylabel('Phi')
% xlabel('Time [s]')



end 
end 