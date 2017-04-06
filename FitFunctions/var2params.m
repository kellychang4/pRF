function [params] = var2params(var, params, freeList)
% [params] = var2params(var, params, freeList)
%
% Support function for 'fit.m'. Turns values 'var' into a field within
% 'param' with a field name given in order from 'freeList'.
%
% Inputs:
%   var         New values to be stored in the 'params' structure under
%               field names (in order) from 'freeList'
%
%   params      A structure of parameter values with field names that
%               correspond with the parameter names in 'freeList'
%
%   freeList    Cell array containing list of parameter names (strings)
%               that match the field names in 'params'
%
% Output:
%   params      Same 'params' structure with parameter values as field
%               names that correspond with the parameter names in
%               'freeList' with the values from 'var'

% Written by G.M. Boynton - Summer of '00
% Edited by Kelly Chang - June 21, 2016

%% Input Control

if ischar(freeList)
    freeList = {freeList};
end

%% Transforms 'var' into Structure 'params'

count = 1;
varStr = regexprep(freeList, '(\(.*\))', '');
numList = cellfun(@(x) regexprep(x,'[()]',''), regexp(freeList, '(\(.*\))', 'match'), 'UniformOutput', false);
for i = 1:length(varStr)
    if ~isempty(numList{i})
        tmp = length(params.(varStr{i})(str2num(char(numList{i}))));
        params.(varStr{i})(str2num(char(numList{i}))) = var(count:(count+tmp-1));
    else
        tmp = length(params.(varStr{i}));
        params.(varStr{i}) = var(count:(count+tmp-1));
    end
    count = count + tmp;
end