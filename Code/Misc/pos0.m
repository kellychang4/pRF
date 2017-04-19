function [x] = pos0(x)
% [x] = pos0(x)
%
% Returns all elements in x where any negative values are now 0.
% 
% Input: 
%   x       A vector or matrix with positive and/or negative values
% 
% Output:
%   x       The same vector or matrix returned now with what were
%           previously negative values (x < 0) as 0s

% Written by Kelly Chang - July 25, 2016

%% Adjusting 'x'

x(x < 0) = 0;