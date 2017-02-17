function [collated] = collate(varargin)
% [collated] = collate(varargin)
%
% Returns a collated structure that contains all the given inputs as fields
%
% Inputs:
%   <variable(s)>     Variable(s) to be collated into one structure. The
%                     collated structure fields will correspond with the 
%                     given variable(s)' name
% 
% Outputs:
%   collated          A collated structure created from all given input
%                     variables

% Written by Kelly Chang - June 2, 2016

%% Collate Variables

for i = 1:length(varargin)
    collated.(inputname(i)) = varargin{i};
end