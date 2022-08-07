function [estimates] = estimate_prf(protocols, seeds, options)
% [estimates] = estimate_prf(protocols, seeds, options)
%
% Estimates the pRF model given the protocols, seeds, and options
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
[unit] = get_global_parameters('unit.name');
unit = capitalize(unit);

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
estimates = collect_prf_estimates(protocols, fitParams);

stopTime = toc(); % clock stop time
fprintf('Final pRF Estimation Time: %5.2f minutes', round(stopTime/60));
fprintf('\n\n\n');