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

% Written by Kelly Chang - June 24, 2016

%% Reassign File Name if Previous Already Exists

[p,name,ext] = fileparts(fileName);
tmp = dir(fullfile(p, sprintf('%s*%s', name, ext)));
fileName = sprintf('%s%s', name, ext);
if ~isempty(tmp) % if file already exists, add increment to file name
    fileName = sprintf('%s_%d%s', name, length(tmp)+1, ext);
end
fullPath = fullfile(p, fileName);

%% Double Check if Exact File Name Already Exists

tmp = dir(fullfile(fullPath)); 
if ~isempty(tmp)
    [p,name,ext] = fileparts(fullPath);
    fileName = sprintf('%s%s%s', name, letter(length(tmp)+1), ext);
end
fullPath = fullfile(p, fileName);

%% Saving Specific Variables

evalStr = sprintf('save(''%s'');', fullPath);
if nargin > 1
    nVar = strjoin(arrayfun(@(x) sprintf(',varargin{%d}',x), 1:length(varargin), ...
        'UniformOutput', false), '');
    tmp = repmat(',''%s''', 1, length(varargin));
    tmp = ['save(''%s''' tmp ');'];
    evalStr = eval(['sprintf(tmp,fullPath' nVar ');']);
end
evalin('caller', evalStr);
fprintf('Saved As: %s\n', fileName);

%% Output

saveName = fileName;