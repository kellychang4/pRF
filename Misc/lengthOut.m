function [x] = lengthOut(start, by, len)
% [x] = lengthOut(start, by, len) 
% 
% Returns a vector of length 'len' starting with the number 'start' 
% incremented by'by' 
% 
% Inputs: 
%   start     Starting value of the vector, numeric
%   by        Increment of the vector, numeric
%   len       Desired length of the vector, non-negative, numeric
%
% Output:
%   x         Vector of length 'len' starting with the number 'start'
%             incremented by 'by'

% Written by Kelly Chang - July 25, 2016

%% Input Control

if len < 0
    error('Desired length must be non-negative');
end

%% Creating 'x' Vector

x = start:by:(start+by*len-by);
x = x(1:len);