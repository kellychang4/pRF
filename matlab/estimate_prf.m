function [estimates,info] = estimate_prf(protocols, seeds, hrf, options)
% [estimates,info] = estimate_prf(protocols, seeds, hrf, options)
%
% Estimates the pRF model given the protocols, seeds, and options
%
% Inputs:
%   protocols               A structure containing information about the
%                           scan(s) (see 'create_protocols.m')
%   seeds                   A structure containing information about the
%                           seeds (see 'create_seeds.m')
%   hrf                     A structure containing information about the
%                           hrf parameters and options.
%   options                 A structure containing information about model
%                           fitting options (see 'create_options.m')

% Written by Kelly Chang - June 29, 2022

%% Argument Validation 

arguments 
    protocols (1,:) struct {validate_protocols(protocols)} 
    seeds     (1,1) struct {validate_seeds(seeds)}
    hrf       (1,1) struct {validate_hrf(hrf)}
    options   (1,1) struct {validate_options_prf(options)}
end

%% Global Variables

update_global_parameters(protocols, seeds, hrf, options); 
[unit] = capitalize(get_global_parameters('unit.name'));

%% Open Parallel Pools

open_parallel(); % open parallel pools

%% Start pRF Estimation Process

tic(); % start prf estimation clock

fprintf('Calculating Predicted Response for Each Seed...\n');
seedResp = calculate_seed_response(protocols);

fprintf('Calculating Best Seeds for Each %s...\n', unit);
bestSeed = calculate_best_seed(protocols, seedResp);

fprintf('Calculating Initial pRF Fits for each %s...\n', unit);
initParams = calculate_initial_parameters(bestSeed);

fprintf('Estimating pRF Parameters for each %s...\n', unit);
fitParams = fit_prf(initParams);

fprintf('Collecting Estimated pRF Parameters...\n'); 
[estimates,info] = collect_prf_estimates(protocols, fitParams);

fprintf('Final pRF Estimation Time: %5.2f minutes', round(toc()/60));
fprintf('\n\n\n');

end

%% Helper Function

function [estimates,info] = collect_prf_estimates(protocols, fitParams)
    [unit,params] = get_global_parameters('unit', 'prf.params'); 

    %%% save data and stimulus information
    info.roi_file  = protocols.roi_file; 
    info.bold_file = {protocols.bold_file};
    info.stim_file = {protocols.stim_file};
    
    %%% save prf estimation procedure parameters
    info.prf_model  = get_global_parameters('prf.model');  
    info.prf_free   = get_global_parameters('prf.free'); 
    info.hrf_model  = get_global_parameters('hrf.model');
    info.hrf_params = get_global_parameters('hrf.defaults');
    
    %%% save estimated prf paramters
    estimates = initialize_structure(unit.n, [unit.name, params, 'corr']);
    for i = 1:length(fitParams) % for each unit
        estimates(i).(unit.name) = fitParams(i).id; 
        for p = 1:length(params) % for each parameter
            estimates(i).(params{p}) = fitParams(i).prf.(params{p});
        end
        estimates(i).corr   = fitParams(i).corr;
    end
end