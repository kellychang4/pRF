function [params] = var2params(var, params, freeList)
% [params] = var2params(var, params, freeList)
%
% Support function for 'fitcon.m'. Turns values 'var' into a field within
% 'param' with a field name given in order from 'freeList'.
%
% Inputs:
%   var         New values to be stored in the 'params' structure under
%               field names (in order) from 'freeList'
%   params      A structure of parameter values with field names that
%               correspond with the parameter names in 'freeList'
%   freeList    Cell array containing list of parameter names (strings)
%               that match the field names in 'params'
%
% Outputs:
%   params      Same 'params' structure with parameter values as field 
%               names that correspond with the parameter names in 
%               'freeList' with the values (in order) from 'var'

% Written by gmb - Summer of '00
% Edited by Kelly Chang for pRF package - June 21, 2016

%% Transforms 'var' into Structure 'params'

for i = 1:length(freeList)
    params.(freeList{i}) = var(i);
end