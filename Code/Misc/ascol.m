function [x] = ascol(x)
% [x] = ascol(x)
% 
% Returns x as a column vector.
% 
% Input:
%   x       A vector or matrix of x
%
% Output:
%   x       The same x but returned as a column vector
%
% Example:
% ascol(randn(x))

% Written by Kelly Chang - July 25, 2016

%% Input Control

if ~any([isvector(x) ismatrix(x)]) || iscell(x)
    error('Input must be a vector or a matrix');
end

%% Unwrap 'x'

x = x(:);