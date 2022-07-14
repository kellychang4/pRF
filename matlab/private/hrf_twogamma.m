function [hrf] = hrf_twogamma(params,t)
% [hrf] = hrf_twogamma(params,t)
%
% SPM's Two Gamma HRF function
%
% Returns a Gamma function over the vector 't' based on the equation 1 from
% Lindquist et al. (2009). See Notes for more information.
%
%
% Inputs:
%   params
%       delta     Onset, seconds (default: 0)
%       c         Response undershoot ratio (default: 6)
%       a1        Time to response, seconds (default: 6)
%       a2        Time to undershoot, seconds (default: 16)
%       b1        Response dispersion (default: 1)
%       b2        Undershoot dispersion (default: 1)
%   t             Time vector the two gamma function is a function of, g(t)
%
% Output:
%   hrf           Output of the Two Gamma HRF function from the given
%                 parameters as a column
%
% Notes:
% - SPM canonical Two Gamma HRF Function was taken from Equation 1 of 
%   Lindquist et al. (2009)
% - Lindquist, M. A., Loh, J. M., Atlas, L. Y., & Wager, T. D. (2009). 
%   Modeling the hemodynamic response function in fMRI: efficiency, bias 
%   and mis-modeling. Neuroimage, 45(1), S187-S198.

% Written by Kelly Chang - June 20, 2017
% Edited by Kelly Chang - July 14, 2022

%% Two Gamma HRF

t = t - params.delta;
hrf = ((t.^(params.a1 - 1) .* params.b1.^(params.a1) .* exp(-params.b1 .* t)) ./ gamma(params.a1)) - ...
    ((t.^(params.a2 - 1) .* params.b2 .^ (params.a2) .* exp(-params.b2 .* t)) / (params.c .* gamma(params.a2)));
hrf(t < 0) = 0;