function [out] = model_gaussian2d(params, funcOf)
% [out] = model_gaussian2s(params, funcOf)
% 
% Two dimensional Gaussian function based on this equation:
% 
% f(x,y) = exp(-((x-x0).^2+(y-y0).^2)/(2*sigma^2));
%
% Inputs:
%   params			A structure that specifes the parameters of the model:
%       x0          X dimension center of the 2D Gaussian
%       y0          Y dimention center of the 2D Gaussian
%       sigma       Standard deviation of the 2D Gaussian, shared between
%                   the x and y dimension
%   funcOf			A structure that speficies the model function of
%					parameters:
%       x           The x dimension the 2D Gaussian is a function of,
%                   f(x,y)
%       y           The y dimension the 2D Gaussian is a function of, 
%                   f(x,y)
%
% Outputs:
%    out			Output of the two dimensional Gaussian function from 
%                   the given parameters

% Written by Kelly Chang - October 16, 2016

%% Equation

out = (exp(-((funcOf.x - params.x0).^2 + (funcOf.y - params.y0).^2) ./ ...
    (2 .* params.sigma .^ 2)));