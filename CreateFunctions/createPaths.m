function [paths] = createPaths(paths)
% [paths] = createPaths(paths)
% 
% If no argument is passed, returns a structure with common fields for 
% paths to relevant directories. If a 'paths' structure is passed as an
% argument, will check if all directories exista and if not will create the
% directories.
%
% Input:
%   <No Arg>        If no argument is passed, will return an initialized
%                   'paths' structure will fields outlined in Output
%   paths           A structure containing paths to common directories of
%                   interest. When passed in as an argument, will check
%                   each path is a directory and if not, will create the
%                   directory
% 
% Output:
%   paths           A structure containing paths to common directories of
%                   interest
%       main        Main directory (default: current working directory)
%       data        Data directory (suggested: location of .vtc and .mat 
%                   paradigm files)
%       results     Results directory (suggested: location to save the pRF
%                   file)

% Written by Kelly Chang - July 20, 2016

%% Create 'paths' Structure

if nargin < 1
    paths.main = pwd();
    paths.data = '';
    paths.results = '';
else
    flds = fieldnames(paths);
    for i = 1:length(flds)
        if ~isempty(paths.(flds{i})) && ~isdir(paths.(flds{i}))
            mkdir(paths.(flds{i}));
        end
    end
end