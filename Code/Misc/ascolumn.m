function [x] = ascolumn(x)
% [x] = ascolumn(x)
% 
% Returns x as a column vector
% 
% Input:
%   x       A vector or matrix of x
%
% Output:
%   x       The same x but returned as a column vector

% Written by Kelly Chang - July 25, 2016

%% Unwrap 'x'

x = x(:);