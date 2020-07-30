% Performs fast recurrence period density entropy (RPDE) analysis on an input signal to
% obtain an estimate of the H_norm value.
%
% Useage:
% [H_norm, rpd] = rpde(x, m, tau)
% [H_norm, rpd] = rpde(x, m, tau, epsilon)
% [H_norm, rpd] = rpde(x, m, tau, epsilon, T_max)
% Inputs
%    x       - input signal: must be a row vector
%    m       - embedding dimension
%    tau     - embedding time delay
% Optional inputs
%    epsilon - recurrence neighbourhood radius
%              (If not specified, then a suitable value is chosen automatically)
%    T_max   - maximum recurrence time
%              (If not specified, then all recurrence times are returned)
% Outputs:
%    H_norm  - Estimated RPDE value
%    rpd     - Estimated recurrence period density
%
% (c) 2007 Max Little. If you use this code, please cite:
% Exploiting Nonlinear Recurrence and Fractal Scaling Properties for Voice Disorder Detection
% M. Little, P. McSharry, S. Roberts, D. Costello, I. Moroz (2007),
% BioMedical Engineering OnLine 2007, 6:23

function [H_norm, rpd] = rpde(x, m, tau, epsilon, T_max)

if ((nargin < 3) | (nargin > 5))
    help rpde;
    return;
end

if (nargin < 4)
    epsilon = 0.12;
end

if (nargin < 5)
    T_max = -1;
end

rpd = close_ret(x, m, tau, epsilon);

if (T_max > -1)
    rpd = rpd(1:T_max);
end
rpd = rpd/sum(rpd);

N = length(rpd);
H = 0;
for j = 1:N
   H = H - rpd(j) * logz(rpd(j));
end
H_norm = H/log(N);


function y = logz(x)
if (x > 0)
   y = log(x);
else
   y = 0;
end
