function RPDE=feat_rpde(x, options)

RPDE=NaN;

if isempty(x) || all(isnan(x))
    return; end

%%
%RPDE
% Default params for DFA
Tmax = length(x)/2;
m = 2; % Embedding dimension
tau = 50; % Embedding delay
eta = 0.2; % RPDE close returns radius
RPDE = rpde(x, m, tau); 
% RPDE = rpde(x, m, tau, eta, Tmax); 
end 