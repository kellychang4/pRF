function [fitParams] = fit_hrf(initParams)
% [fitParams] = fit_hrf(initParams)

%%% global parameters
[p,freeList] = get_global_parameters('parallel', 'hrf.free');

% (!!!)
globalArgs = get_global_parameters('prf.func', 'stim', 'funcof', ...
    'prf.css', 'dt.stim', 'hrf.func', 'hrf.tmax', 't.stim', 't.bold');

%%% initialized parameters
nv = length(initParams); fitParams = initialize_fit_params(initParams);

switch p.flag
    case false % sequential processing

        for i = 1:nv % for each unit

            %%% print progress status
            print_progress(i, nv);

            %%% separate hrf parameters and other information
            params = initParams(i).hrf; % hrf parameters
            args = combine_structures(globalArgs, ...
                rmfield(initParams(i), 'hrf'));

            %%% fit current vertex or voxel hrf parameters
            fitParams(i) = fit_unit_hrf(fitParams(i), params, freeList, args);
        end

    case true % parallel processing
        
%         %%% start hrf fitting in background pool
%         f(1:nv) = parallel.FevalFuture(); 
%         for i = 1:nv % for each unit

%             params = initParams(i).hrf; % hrf parameters
%             args = combine_structures(globalArgs, ...
%                 rmfield(initParams(i), 'hrf'));

%             f(i) = parfeval(backgroundPool, @fit_unit_hrf, 1, ...
%                 params, freeList, args); 
%         end
%             
%         %%% collect hrf fit paramters 
%         for i = 1:nv % for each unit
%             %%% print progress status
%             print_progress(i, nv);
%             
%             %%% fetch hrf parameters results from parallel pool
%             [indx, results] = fetchNext(f);
%             fitParams(indx) = results;
%         end

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

function [fitParams] = fit_unit_hrf(fitParams, params, freeList, args)
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