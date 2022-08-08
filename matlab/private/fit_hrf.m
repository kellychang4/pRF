function [fitParams] = fit_hrf(fitParams)
% [fitParams] = fit_hrf(initParams)

%%% global parameters
[p,hrfFree,globalArgs] = get_global_parameters('parallel', 'hrf.free', 'fit');

%%% initialized parameters
nv = length(fitParams); 
fitParams = initialize_fit_params(fitParams);

switch p.flag
    case false % sequential processing

        for i = 1:nv % for each unit

            %%% print progress status
            print_progress(i, nv); 

            %%% fit current vertex or voxel hrf parameters
            fitParams(i) = fit_unit_hrf(fitParams(i), hrfFree, globalArgs);

        end

    case true % parallel processing
        
        %%% initialize parallel job counters
        ct = 0; job = zeros(nv, 3); f(1:nv) = parallel.FevalFuture();

        %%% start best seed parallel processing
        while any(job(:,3) == 0) % while jobs are not collected

            %%% start hrf fitting procedure in the parallel pool
            if ct < nv % if not all units have been placed into the queue

                %%% increment unit count and job index
                ct = ct + 1; j = find([f.ID] == -1, 1);

                %%% start best seed calculations
                f(j) = parfeval(p.pool, @fit_unit_hrf, 1, ...
                    fitParams(ct), hrfFree, globalArgs);

                %%% record job id
                job(ct, 1) = f(j).ID; % record job id

            end

            %%% check and mark completed job processing
            stateIndx = strcmp({f.State}, 'finished');
            markIndx  = ismember(job(:,1), [f(stateIndx).ID]);
            job(markIndx, 2) = 1; % mark as completed

            %%% locate completed but not collected job difference index
            diffIndx = logical(job(:,2) - job(:,3));

            if any(diffIndx) % if there are completed by unread jobs

                %%% find job ids that are completed but unread
                completedId = job(diffIndx, 1);

                for i2 = 1:length(completedId) % for each unread

                    %%% compute job and output indices
                    jobIndx = [f.ID] == completedId(i2);   % current job index
                    outIndx = job(:,1) == completedId(i2); % current output index

                    %%% fetch fitted hrf parameter output
                    fitParams(outIndx) = fetchOutputs(f(jobIndx));

                    %%% mark job as completed and clear job object
                    job(outIndx, 3) = 1; % mark as collected
                    f(jobIndx) = [];     % clear job object
                    
                    %%% print progress status
                    print_progress(sum(job(:,3)), nv);
                end
            end
        end

end

%%% calculate median hrf parameter across all units
fitParams = calculate_median_hrf(fitParams);

end

%% Helper Functions

function [fitParams] = initialize_fit_params(initParams)
    %%% initialize and clear previous fitting values
    fitParams = initParams; % initialize with previous fits
    for i = 1:length(fitParams); fitParams(i).corr = NaN; end
end

function [fitParams] = fit_unit_hrf(fitParams, freeList, globalArgs)

    %%% separate hrf parameters and other information
    params = fitParams.hrf; % initial hrf parameters
    args = combine_structures(globalArgs, rmfield(fitParams, 'hrf'));

    %%% call 'fitcon' on unit
    [outParams,err] = fitcon(@error_hrf, params, freeList, args);

    %%% save fitted parameter outputs
    fitParams.hrf  = outParams;
    fitParams.corr = -err;
end

function [fitParams] = calculate_median_hrf(fitParams)
    %%% extract fitted hrf parameters and names
    params = cat(1, fitParams.hrf); flds = fieldnames(params);

    %%% calulate median value for each hrf parameter
    for i = 1:length(flds) % for each field
        mdn.(flds{i}) = median([params.(flds{i})], 'omitnan'); 
    end
    
    %%% assign median hrf parameter values to each unit
    for i = 1:length(fitParams) % for each unit
        fitParams(i).hrf = mdn; 
    end
end