function [x] = asrow(x)
% [x] = asrow(x)
% 
% Returns x as a row vector.
% 
% Input:
%   x       A vector or matrix of x
%
% Output:
%   x       The same x but returned as a row vector
%
% Example:
% asrow(randn(x))

% Written by Kelly Chang - July 28, 2016

%% Input Control

if ~any([isvector(x) ismatrix(x)]) || iscell(x)
    error('Input must be a vector or a matrix');
end

%% Unwrap 'x'

x = x(:)';