function [x] = pos0(x)
% [x] = pos0(x)
%
% Returns all numeric elements in x where any negative values are now 0.
% 
% Input: 
%   x       A vector or matrix with positive and/or negative values
% 
% Output:
%   x       The same vector or matrix returned with all previously negative 
%           (x < 0) returned as 0s
%
% Example:
% pos0(randn(100))

% Written by Kelly Chang - July 25, 2016

%% Input Control

if ~any([isvector(x) ismatrix(x)]) || iscell(x)
    error('Input must be a vector or a matrix');
end

%% Adjusting 'x'

x(x < 0) = 0;