function [hrf] = hrf_boynton(params,t)
% [out] = BoyntonHRF(params,t)
%
% Returns a Gamma function over the vector 't' based on the equation:
%
% g(t) = ((t-delta)/tau).^(n-1).*exp(-(t-delta)/tau)/(tau*factorial(n-1))
%
% which is the result of an n stage leaky integrator
%
% Inputs:
%   params        A structure that specifes the parameters of the Gaussian
%                 with fields:
%       n         Phase delay (default: 3)
%       tau       Time constant
%       delta     Delay (seconds)
%   t             Time vector the gamma function is a function of, g(t)
%
% Output:
%   hrf           Output of the Gamma function from the given parameters
%                 given as a column

% Written by G.M. Boynton at Stanford University - June 27, 1995
% Simplified for Psychology 448/538 at U.W. - April 19, 1999
% Modified by Kelly Chang for pRF - May 29, 2016
% Edited by Kelly Chang - July 14, 2022

%% Equation

t = t - params.delta;
hrf = (t ./ params.tau).^(params.n - 1) .* ...
    exp(-t ./ params.tau) ./ (params.tau .* factorial(params.n - 1));
hrf(t < 0) = 0;