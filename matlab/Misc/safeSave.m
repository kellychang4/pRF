function [saveName] = safeSave(fileName, varargin)
% [saveName] = safeSave(fileName, var1, var2, var3, ...)
%
% Prevents overwriting existing file if 'fileName' is given. If the
% 'fileName' already exists, will add an increment to 'fileName' 
% (i.e., 'fileName.mat' --> 'fileName_2.mat'). As a fail safe, if
% 'fileName' still exists after appending the increment, a letter will be
% attached to the end of fileName (i.e., 'fileName_2.mat' -->
% 'fileName_2b.mat').
%
% Inputs:
%   fileName        Name of the file to be saved, string
%   var<n>          Variables to be saved in 'fileName', string
% 
% Output:
%   saveName        Name of the file actually saved as, string
%
% Examples:
% save('wip.mat'); % as a baseline
% safeSave('wip.mat'); % will change to 'wip_2.mat'
% safeSave('wip.mat', '-v7.3'); % will change to 'wip_3.mat'

% Written by Kelly Chang - June 24, 2016
% Edited by Kelly Chang - September 6, 2017

%% Reassign File Name if Previous Already Exists

[p,name,ext] = fileparts(fileName);
tmp = dir(fullfile(p, sprintf('%s*%s', name, ext)));
saveName = sprintf('%s%s', name, ext);
if ~isempty(tmp) % if file already exists, add increment to file name
    indx = sum(~cellfun(@isempty, regexp({tmp.name}, sprintf('(%1$s|%1$s_[0-9]*).mat', name))));
    saveName = sprintf('%s_%d%s', name, indx+1, ext);
end

%% Double Check if Exact File Name Already Exists

tmp = dir(fullfile(p, saveName)); 
if ~isempty(tmp)
    [~,name,ext] = fileparts(saveName);
    saveName = sprintf('%s%s%s', name, letter(length(tmp)+1), ext);
end
fullPath = fullfile(p, saveName);

%% Saving Specific Variables

evalStr = sprintf('save(''%s'');', fullPath);
if nargin > 1
    evalStr = sprintf('save(''%s'',''%s'');', fullPath, strjoin(varargin, ''','''));
end
evalin('caller', evalStr);
fprintf('Saved As: %s\n', saveName);