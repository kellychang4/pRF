function [paths] = createPaths(paths)
% [paths] = createPaths(paths)
%
% If no argument is passed, returns a structure with paths with field
% 'main' to the currect working directory. If a 'paths' structure is passed
% as an argument, will check if all directories exist and if not will 
% create the directories.
%
% Input:
%   <No Arg>        If no argument is passed, will return an initialized
%                   'paths' structure will a main path outlined in Output
%   paths           A structure containing paths to common directories of
%                   interest. When passed in as an argument, will check
%                   each path is a directory and if not, will create the
%                   directory. 
%
% Output:
%   paths           A structure containing paths to directories of interest
%       main        Main directory (default: current working directory)
%
% Example:
% paths = createPaths(); % initialize 'paths' structure
% paths.test = fullfile(paths.main, 'Testing'); % new directory pathing
% paths = createPaths(paths); % will create the 'paths.test' directory

% Written by Kelly Chang - July 20, 2016

%% Create 'paths' Structure

if nargin < 1
    paths.main = pwd();
else
    % error check
    flds = fieldnames(paths);
    if ~all(structfun(@ischar, paths) | structfun(@iscell, paths))
        errFlds = flds(~(structfun(@ischar, paths) | structfun(@iscell, paths)));
        error('Unrecognized path fields: %s', strjoin(errFlds, ', '));
    end
    % if they do not exist, create directory
    for i = 1:length(flds)
        tmp = paths.(flds{i});
        if ischar(tmp) || length(paths.(flds{i})) == 1 
            paths.(flds{i}) = char(paths.(flds{i}));
            tmp = cellstr(paths.(flds{i})); 
        end
        tmp = tmp(~cellfun(@isempty, tmp) & ~cellfun(@isdir, tmp));
        cellfun(@mkdir, tmp); % make directories
    end
end