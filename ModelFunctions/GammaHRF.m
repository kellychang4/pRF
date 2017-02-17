function [out] = GammaHRF(params, funcOf)
% [out] = GammaHRF(params, funcOf)
%
% Returns a Gamma function on vector funcOf.t based on the equation:
%
% g(x) = ((t-delta)/tau).^(n-1).*exp(-(t-delta)/tau)/(tau*factorial(n-1))
%
% which is the result of an n stage leaky integrator
%
% Inputs:
%   <No Arg>      No arguments, will return a structure containing the 
%                 required field names for 'params' and 'funcOf'
%   params        A structure that specifes the parameters of the Gaussian
%                 with fields:
%       n         Phase delay
%       tau       Time constant
%       delta     Delay (seconds)
%   funcOf        A structure that speficies the dimensions the Gamma is
%                 a function of:
%       t         Time vector the gamma function is a function of, g(x)
%
% Outputs:
%   out           Output of the Gamma function from the given parameters
%                 given as a column

% Written by G.M. Boynton at Stanford University - June 27, 1995
% Simplified for Psychology 448/538 at U.W. - April 19, 1999
% Modified by Kelly Chang for pRF package - May 29, 2016

%% Equation

if nargin < 1
    out.params = {'n', 'tau', 'delta'};
    out.funcOf = {'t'};
else
    t = funcOf.t - params.delta;
    out = (t/params.tau).^(params.n-1) .* ...
        exp(-t/params.tau)/(params.tau*factorial(params.n-1));
    out(t < 0) = 0;
end