function [estimates] = estimate_hrf(protocols, seeds, options)
% [estimates] = estimate_hrf(protocols, seeds, opt)
%
% Estimates the hrf model given the scan, seeds, hrf, and options
%
% Inputs:
%   protocols               A structure containing information about the
%                           scan(s) (see 'create_protocols.m')
%   seeds                   A structure containing information about the
%                           seeds (see 'create_seeds.m')
%   opt                     A structure containing information about model
%                           fitting options (see 'create_opt.m')

% Written by Kelly Chang - June 29, 2022

%% Argument Validation 

arguments 
    protocols (1,:) struct {validate_protocols(protocols)} 
    seeds     (1,:) struct {validate_seeds(seeds)}
    options   (1,1) struct {validate_options(options)}
end

%% Global Variables

update_global_parameters(protocols, seeds, options); 
unitName = get_global_variables('prf.unit');

%% Open Parallel Core 

open_parallel(); % open parallel cores

%% Start HRF Estimation Process

startTime = tic();

fprintf('Calculating Predicted Response for Each Seed...\n');
seedResp = calculate_seed_response(protocols, seeds);

fprintf('Calculating Best Seeds for Each %s...\n', capitalize(unitName));
%% !!! check is this is necessary
bestSeed = initialize_best_seed(protocols); 
bestSeed = calculate_best_seed(bestSeed, seedResp); 

fprintf('Calculating Initial pRF Fits for each %s...\n', capitalize(unitName));
fitParams = calculate_initial_parameters(bestSeed);

fprintf('Estimating HRF\n');
for i = 1:options.nfit% for number of hrf fitting iterations
    fprintf('  Iteration %d of %d...\n', i, options.nfit);

    fitParams = fit_hrf(fitParams);
    %% !!! make sure that function formats properly
    fitParams = calculate_median_hrf(fitParams); 
   
    %%% if not last iteration, fit prfs with estimated hrf parameters
    if i ~= options.nfit; fitParams = fit_prf(fitParams); end
end

fprintf('Collecting Estimated HRF Parameters...\n'); 
estimates = fitParams;

%% Final Timings

stopTime = toc;
fprintf('Final HRF Estimation Time: %5.2f minutes', round(stopTime/60));
fprintf('\n\n\n');