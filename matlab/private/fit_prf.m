function [fitParams] = fit_prf(fitParams)
% [fitParams] = fit_prf(initParams)

%%% global parameters
[prfFree,globalArgs] = get_global_parameters('prf.free', 'fit');

%%% initialized parameters
fitParams = initialize_fit_params(fitParams);

%%% fit prf for each unit
fitParams = fit_wrapper(@fit_unit_prf, fitParams, prfFree, globalArgs);

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