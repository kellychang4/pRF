function [collated] = estimate_hrf(protocols, seeds)
% [collated] = estimate_hrf(scans, seeds, hrf, opt)
%
% Estimates the hrf model given the scan, seeds, hrf, and options
%
% Inputs:
%   protocols               A structure containing information about the
%                           scan(s) (see 'create_protocols.m')
%   seeds                   A structure containing information about the
%                           seeds (see 'create_seeds.m')
%   hrf                     A structure containing information about the
%                           hemodynamic response function
%                           (see 'create_hrf.m')
%   opt                     A structure containing information about model
%                           fitting options (see 'create_opt.m')
%
% Output:

% Written by Kelly Chang - June 29, 2022

% arguments 
%     protocols (1,:) struct {validate_protocols(protocols)} 
%     seeds     (1,:) struct {validate_seeds(seeds)}
% end

%% Global Variables

update_global_parameters(protocols, seeds); 
unitName = get_global_variables('prf.unit');

%% Open Parallel Core 

open_parallel(); % open parallel cores

%% Estimate HRF Function

tic();
startTime = datestr(now);

fprintf('Calculating Predicted Response for Each Seed...\n');
% seedResp = calculate_seed_response(protocols, seeds);
% save('seedResp.mat', 'seedResp'); 
% load('seedResp.mat', 'seedResp'); 

fprintf('Calculating Best Seeds for Each %s...\n', capitalize(unitName));
% bestSeed = initialize_best_seed(protocols);
% bestSeed = calculate_best_seed(bestSeed, seedResp); 
% save('bestSeed.mat', 'bestSeed'); 
load('bestSeed.mat', 'bestSeed'); 

fprintf('Calculating Initial Fit Parameters...\n', capitalize(unitName));
initParams = calculate_initial_parameters(bestSeed);
save('initParams.mat', 'initParams'); 
% load('initParams.mat', 'initParams');

fprintf('Estimating HRF\n');
fprintf('  Iteration %d of %d...\n', 1, 3);
tic; fitParams1 = fit_hrf(initParams); toc;
save('fitParams1.mat', 'fitParams1'); 

fprintf('  Iteration %d of %d...\n', 2, 3); 
fitParams1 = calculate_median_hrf(fitParams1); 
tic; fitParams2 = fit_prf(fitParams1); toc;
save('fitParams2.mat', 'fitParams2'); 

tic; fitParams3 = fit_hrf(fitParams2); toc;
save('fitParams3.mat', 'fitParams3'); 

fprintf('  Iteration %d of %d...\n', 3, 3); 
fitParams3 = calculate_median_hrf(fitParams3); 
tic; fitParams4 = fit_prf(fitParams3); toc;
save('fitParams4.mat', 'fitParams4'); 

tic; fitParams5 = fit_hrf(fitParams4); toc;
save('fitParams5.mat', 'fitParams5'); 

return

%% Final Timings

opt.stopTime = datestr(now);
stopTime = toc;
fprintf('Final HRF Estimation Time %5.2f minutes', round(stopTime/60));
fprintf('\n\n\n');