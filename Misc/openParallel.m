function [parallelOpt] = openParallel(parallelOpt)
% [parallelOpt] = openParallel(parallelOpt)
%
% Opens all available parallel cores, if there are parallel cores
% 
% Input:
%   parallelOpt       Open parallel cores (true) OR not (false), logical
%                     (default: false)
%
% Output:
%   parallelOpt       Parallel cores opened (true) or not (false), logical

% Written by Kelly Chang - July 19, 2016

%% Input Control

if ~exist('parallelOpt', 'var')
    parallelOpt = false;
end

%% Open Parallel Cores

if parallelOpt
    try
        p = gcp('nocreate'); % check for pool information
        if isempty(p) % if no pool is currently open
            % open all cores on default cluster
            parpool(parallel.defaultClusterProfile, p.NumWorkers);
        end
    catch ME % if there is no parallel pools available
        parallelOpt = false; % reset flag to be false
    end
end