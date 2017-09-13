function [out] = Gaussian2D(params, funcOf)
% [out] = Gaussian2D(params, funcOf)
% 
% Two dimensional Gaussian function based on this equation:
% 
% f(x,y) = exp(-((x-xMu).^2+(y-yMu).^2)/(2*sigma^2));
%
% Inputs:
%   <No Arg>		No arguments, will return a structure containing the
%					required field names for 'params' and 'funcOf'
%   params			A structure that specifes the parameters of the model:
%       xMu         X dimension center of the 2D Gaussian
%       yMu         Y dimention center of the 2D Gaussian
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

if nargin < 1
    out.params = {'xMu', 'yMu', 'sigma'};
    out.funcOf = {'x', 'y'};
else
    out = exp(-((funcOf.x-params.xMu).^2+(funcOf.y-params.yMu).^2)/(2*params.sigma^2));
end