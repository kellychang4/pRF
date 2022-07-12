function [flag] = open_parallel(flag)
% [flag] = open_parallel(flag)
%
% Opens all available parallel cores, if there are parallel cores to open.
% If there are no parallel cores to open, will return flag as false.
% 
% Input:
%   flag              Open parallel cores (true) OR not (false), logical
%                     (default: false)
%
% Output:
%   flag              Parallel cores opened (true) or not (false), logical
%
% Example:
% flag = openParallel(true);

% Written by Kelly Chang - July 19, 2016

%% Input Control

if ~exist('flag', 'var')
    flag = false;
end

%% Open Parallel Cores

if flag
    try
        p = gcp('nocreate'); % check for pool information
        if isempty(p) % if no pool is currently open
            % open all cores on default cluster
            parpool(parallel.defaultClusterProfile, p.NumWorkers);
        end
    catch ME % if there is no parallel pools available
        flag = false; % reset flag to be false
    end
end