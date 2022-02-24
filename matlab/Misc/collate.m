function [collated] = collate(varargin)
% [collated] = collate(var1, var2, var3, ...)
%
% Returns a collated structure that contains all the given variable inputs
% as fields.
%
% Inputs:
%   var<n>          Variable(s) to be collated into one structure. The
%                   collated structure fields will correspond with the 
%                   given variable(s)' name
% 
% Output:
%   collated        A collated structure created from all given input
%                   variables
%
% Example:
% a.a = 1; a.b = 2;
% b.c = 3; b.d = 4;
%
% collate(a,b)

% Written by Kelly Chang - June 2, 2016

%% Collate Variables

for i = 1:length(varargin)
    collated.(inputname(i)) = varargin{i};
end