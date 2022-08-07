function [fitParams] = fit_prf(fitParams)
% [fitParams] = fit_prf(initParams)

%%% global parameters
[p,prfFree,globalArgs] = get_global_parameters('parallel', 'prf.free', 'fit');

%%% initialized parameters
nv = length(fitParams); 
fitParams = initialize_fit_params(fitParams);

switch p.flag
    case false % sequential processing

        for i = 1:nv % for each unit

            %%% print progress status
            print_progress(i, nv); 

            %%% fit current vertex or voxel hrf parameters
            fitParams(i) = fit_unit_prf(fitParams(i), prfFree, globalArgs);

        end

    case true % parallel processing
        
        %%% start prf fitting in background pool
        f(1:nv) = parallel.FevalFuture(); 
        for i = 1:nv % for each unit
            f(i) = parfeval(backgroundPool, @fit_unit_prf, 1, ...
                fitParams(i), prfFree, globalArgs); 
        end
            
        %%% collect prf fitted paramters 
        for i = 1:nv % for each unit
            %%% print progress status
            print_progress(i, nv);
            
            %%% fetch hrf parameters results from parallel pool
            [indx, results] = fetchNext(f);
            fitParams(indx) = results;
        end

end

end

%% Helper Functions

function [fitParams] = initialize_fit_params(initParams)
    %%% initialize and clear previous fitting values
    fitParams = initParams; % initialize with previous fits
    for i = 1:length(fitParams); fitParams(i).corr = NaN; end
end

function [fitParams] = fit_unit_prf(fitParams, freeList, globalArgs)

    %%% separate prf parameters and other information
    params = fitParams.prf; % initial prf parameters
    args = combine_structures(globalArgs, rmfield(fitParams, 'prf'));

    %%% call 'fitcon' on unit
    [outParams,err] = fitcon(@error_prf, params, freeList, args);

    %%% save fitted parameter outputs
    fitParams.prf  = outParams;
    fitParams.corr = -err;
end