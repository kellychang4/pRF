function [x] = asrow(x)
% [x] = asrow(x)
% 
% Returns x as a row vector
% 
% Input:
%   x       A vector or matrix of x
%
% Output:
%   x       The same x but returned as a row vector

% Written by Kelly Chang - July 28, 2016

%% Unwrap 'x'

x = x(:)';