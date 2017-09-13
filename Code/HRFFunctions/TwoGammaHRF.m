function [hrf] = TwoGammaHRF(params,t)
% [hrf] = TwoGammaHRF(params,t)
%
% SPM's Two Gamma HRF function
%
% Returns a Gamma function over the vector 't' based on the equation 1 from
% Lindquist et al. (2009). See Notes for more information.
%
%
% Inputs:
%   <No Arg>      No arguments, will return a cell array containing the 
%                 required field names for 'params'
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

%% Input Control

if ~exist('params', 'var')
    params = struct();
end

if ~isfield(params, 'delta')
    params.delta = 0;
end

if ~isfield(params, 'c')
    params.c = 6;
end

if ~isfield(params, 'a1')
    params.a1 = 6;
end

if ~isfield(params, 'a2')
    params.a2 = 16;
end

if ~isfield(params, 'b1')
    params.b1 = 1;
end

if ~isfield(params, 'b2')
    params.b2 = 1;
end

%% Two Gamma HRF


if nargin < 1
    hrf = {'delta', 'c', 'a1', 'a2', 'b1', 'b2'};
else
    t = t - params.delta;
    hrf = ((t.^(params.a1-1).*params.b1^(params.a1).*exp(-params.b1.*t)) / gamma(params.a1)) - ...
        ((t.^(params.a2-1).*params.b2^(params.a2).*exp(-params.b2.*t)) / (params.c*gamma(params.a2)));
    hrf(t < 0) = 0;
end