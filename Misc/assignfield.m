function [s] = assignfield(s, varargin)
% [s] = assignfield(s, 'field1', v1, 'field2', v2, ...)
%
% Assigns the specfied value for all instances of the given field. Can work
% for multiple specified fields.
%
% Input:
%   s           A structure with field values to be modified
%   field       A string that is a field names within the given structure
%   v           Values to be assigned with to the specified field
%
% Output:
%   s           Same input structure but with the specified fields
%               reassigned with their corresponding values

% Written by Kelly Chang - February 2, 2017

%% Error Check and Input Control

if (isempty(varargin) || length(varargin) < 2)
    error(message('MATLAB:setfield:InsufficientInputs'));
end

if mod(length(varargin),2) ~= 0
    error('Each given field must have corresponding value');
end

tmp = reshape(varargin, 2, []);
if ~all(cellfun(@ischar, tmp(1,:)))
    error('Field names must be strings');
end

if ~all(ismember(tmp(1,:), fieldnames(s)))
    errFlds = setdiff(tmp(1,:), fieldnames(s));
    error('Unknown field names: %s', strjoin(errFlds, ', '));
end

%% Assignment of Values

for i = 1:length(s)
    for i2 = 1:size(tmp,2)
        s(i).(tmp{1,i2}) = tmp{2,i2};
    end
end