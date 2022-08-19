function [fitParams] = fit_hrf(fitParams)
% [fitParams] = fit_hrf(fitParams)

%%% global parameters
[hrfFree,globalArgs] = get_global_parameters('hrf.free', 'fit');

%%% initialized parameters
fitParams = initialize_fit_params(fitParams);

%%% fit hrf for each unit
fitParams = fit_wrapper(@fit_unit_hrf, fitParams, hrfFree, globalArgs);

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