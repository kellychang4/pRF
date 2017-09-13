function [out] = Gaussian1D(params, funcOf)
% [out] = Gaussian1D(params, funcOf)
%
% One dimensional Gaussian function based on the equation:
%
% f(x) = exp(-((x-mu).^2)/(2*sigma^2))
%
% Inputs:
%   <No Arg>      No arguments, will return a structure containing the 
%                 required field names for 'params' and 'funcOf'
%   params        A structure that specifes the parameters of the Gaussian
%                 with fields:
%       mu        Mean of the Gaussian
%       sigma     Standard deviation of the Gaussian
%   funcOf        A structure that speficies the dimensions the Gaussian is
%                 a function of:
%       x         The x dimension the Gaussian is a function of, f(x)
%
% Output:
%   out           Output of the Gaussian function from the given parameters

% Written by Kelly Chang - June 21, 2016

%% Equation

if nargin < 1
    out.params = {'mu', 'sigma'};
    out.funcOf = {'x'};
else
    out = exp(-((funcOf.x-params.mu).^2)/(2*params.sigma^2));
end