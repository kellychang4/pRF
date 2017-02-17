function [opt] = openParallel(opt)
% [opt] = openParallel(opt)
%
% Opens all available parallel cores
% 
% Input:
%   opt               A structure containing options for parallel
%                     processing with the field: 
%       parallel      Open parallel cores (true) OR not (false), logical
%                     (default: false)
% 
% Output:
%   opt               Same opt structure, but with additional fields filled
%                     in (if they were not already)  

% Written by Kelly Chang - July 19, 2016

%% Input Control

if ~exist('opt', 'var') || ~isfield(opt, 'parallel')
    opt.parallel = false;
end

%% Open Parallel Cores

if opt.parallel
    try
        p = gcp('nocreate'); % check for pool information
        if isempty(p) % if no pool is currently open
            % open all cores on default cluster
            parpool(parallel.defaultClusterProfile, p.NumWorkers);
        end
    catch ME % if there is no parallel pools available
        opt.parallel = false; % reset opt.parallel to be false
    end
end