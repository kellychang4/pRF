function [out] = model_gaussian1d(params, funcOf)
% [out] = model_gaussian1d(params, funcOf)
%
% One dimensional Gaussian function based on the equation:
%
% f(x) = exp(-((x-x0).^2)/(2*sigma^2))
%
% Inputs:
%   params        A structure that specifes the parameters of the Gaussian
%                 with fields:
%       x0        Mean of the Gaussian
%       sigma     Standard deviation of the Gaussian
%   funcOf        A structure that speficies the dimensions the Gaussian is
%                 a function of:
%       x         The x dimension the Gaussian is a function of, f(x)
%
% Output:
%   out           Output of the Gaussian function from the given parameters

% Written by Kelly Chang - June 21, 2016

%% Equation

out = exp(-((funcOf.x - params.x0).^2) ./ (2.* params.sigma .^ 2));