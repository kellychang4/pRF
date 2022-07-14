function open_parallel()
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

%% Open Parallel Cores

parallelFlag = get_global_variables('fit.parallel');

if parallelFlag 
    try % try to open parallel pool
        p = gcp('nocreate'); % check for pool information
        if isempty(p) % if no pool is currently open
            % open all cores on default cluster
            c = parcluster(parallel.defaultClusterProfile);
            parpool(parallel.defaultClusterProfile, c.NumWorkers);
        end
    catch ME % if there is no parallel pools available
        delete(gcp('nocreate')); % delete all parallel pools
        set_global_variables('fit.parallel', false);
    end
end