function [collated] = estimate_hrf(protocols, seeds)
% [collated] = estimate_hrf(scans, seeds, hrf, opt)
%
% Estimates the hrf model given the scan, seeds, hrf, and options
%
% Inputs:
%   scans                   A structure containing information about the
%                           scan(s) (see 'create_scans.m')
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

set_global_model_parameters();
% UNIT = get_global_variables('prf.unit');
UNIT = 'vertex';

%% Open Parallel Core 

open_parallel(); % open parallel cores

%% Calculate Predicted Response for Each Seed

tic();
startTime = datestr(now);

fprintf('Calculating Predicted Response for Each Seed...\n');
seedResp = calculate_seed_response(protocols, seeds);
% save('seedResp.mat', 'seedResp'); 
load('seedResp.mat', 'seedResp'); 

fprintf('Calculating Best Seeds for Each %s...\n', capitalize(UNIT));
bestSeed = initialize_best_seed(protocols, seedResp);
tic;
bestSeed = calculate_best_seed(bestSeed); toc;
save('bestSeed.mat', 'bestSeed'); 

return

%% Subset Voxel / Vertices to Use for HRF Fitting

%%% subset to units with seed fits past threshold
bestSeed = bestSeed([bestSeed.corr] > opt.hrfThr); 
nHrfFit = min(length(thrSeed), opt.nHrfFit);

%%% truncate to maximum units allowed to be fit
[~,topIndx] = sort([bestSeed.corr], 'descend');
bestSeed = bestSeed(topIndx(1:nHrfFit)); 

%% Create 'fitParams' Structure for pRF Fitting

initParams = initialize_parameter_structure(bestSeed);
return
for i = 1:nv % for each voxel or vertex
    seedModel = hrf;
    seedModel.corr = NaN;
    seedModel.didFit = false;
    if ~opt.CSS; seedModel.exp = 1; end
    seedModel.seedCorr = pRF(i).bestSeed.corr;
    for i2 = 1:length(freeParams) % load 'fitParams' with bestSeed params
        seedModel.(freeParams{i2}) = pRF(i).bestSeed.(freeParams{i2});
    end
    fitParams(i) = seedModel;
end

%% Fitting pRF Model (and Estimating HRF)

fprintf('Estimating HRF\n');
fittedParams = fit_hrf(initParams, protocols, opt);
%     for i = 1:length(hrf.freeList) % calculate estimated parameters
%         hrf.fit.(hrf.freeList{i}) = median([fittedParams.(hrf.freeList{i})], 'omitnan');
%     end

opt.stopTime = datestr(now);

%% Final Timings

stopTime = toc;
fprintf('Final HRF Estimation Time %5.2f minutes', round(stopTime/60));
fprintf('\n\n\n');