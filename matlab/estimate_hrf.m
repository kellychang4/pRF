function [estimates] = estimate_hrf(protocols, seeds, options)
% [estimates] = estimate_hrf(protocols, seeds, options)
%
% Estimates the hrf model given the protocols, seeds, and options
%
% Inputs:
%   protocols               A structure containing information about the
%                           scan(s) (see 'create_protocols.m')
%   seeds                   A structure containing information about the
%                           seeds (see 'create_seeds.m')
%   options                 A structure containing information about model
%                           fitting options (see 'create_opt.m')

% Written by Kelly Chang - June 29, 2022

%% Argument Validation 

arguments 
    protocols (1,:) struct {validate_protocols(protocols)} 
    seeds     (1,1) struct {validate_seeds(seeds)}
    options   (1,1) struct {validate_options(options)}
end

%% Global Variables

update_global_parameters(protocols, seeds, options); 
[unit,niter] = get_global_parameters('unit.name', 'hrf.niter');
unit = capitalize(unit);

%% Open Parallel Pools

open_parallel(); % open parallel pools

%% Start HRF Estimation Process

tic(); % start hrf estimation clock

fprintf('Calculating Predicted Response for Each Seed...\n');
seedResp = calculate_seed_response(protocols);

fprintf('Calculating Best Seeds for Each %s...\n', unit);
tic; bestSeed = calculate_best_seed(protocols, seedResp); toc;

fprintf('Calculating Initial pRF Fits for each %s...\n', unit);
fitParams = calculate_initial_parameters(bestSeed);

fprintf('Estimating HRF...\n');
for i = 1:niter % for number of hrf fit iterations
    fprintf(' Iteration %d of %d...\n', i, niter);

    %%% fit hrf parameters
    fitParams = fit_hrf(fitParams);
   
    %%% if not last iteration, fit prfs with estimated hrf parameters
    if i ~= niter; fitParams = fit_prf(fitParams); end
end

fprintf('Collecting Estimated HRF Parameters...\n'); 
estimates = collect_hrf_estimates(protocols, fitParams);

stopTime = toc(); % clock stop time
fprintf('Final HRF Estimation Time: %5.2f minutes', round(stopTime/60));
fprintf('\n\n\n');