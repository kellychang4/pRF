function [collated] = estimate_hrf(scans, seeds, hrf, opt)
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

%% Global Variables

% update_global_variables(scans, seeds);
% freeParams = get_global_variable('prf');

%% Validate Input Arguments

validate_estimate_hrf(); 

%% Open Parallel Cores

opt.parallel = openParallel(opt.parallel);

%% Create Predicted BOLD Response for Each Seed

tic();
opt.startTime = datestr(now);
fprintf('Calculating Predicted Response for Each Seed\n');
for i = 1:length(scans) % for each scan
    %%% generate prf models from prf parameter seeds
    for i2 = 1:length(seeds) % for each seed
        seedModel = PRF_MODEL(seeds(i2), scans(i).funcOf); 
        scans(i).seedModel(:,i2) = ascol(seedModel); % pRF model for each seed
    end
    
    %%% collapse scan stimulus image
    scans(i).stimImg = reshape(scans(i).stimImg, size(scans(i).stimImg,1), []); 
    
    %%% multiply stimulus with seed prfs
    scans(i).modelResp = scans(i).stimImg * scans(i).seedModel; 
    
    %%% (optional) raise to compressive spatial summation exponent
    if opt.CSS; scans(i).modelResp = bsxfun(@power, scans(i).modelResp, [seeds.exp]); end
        
    %%% convolve seed responses with hrf
    scans(i).convSeed = create_convolved_response(scans(i), hrf); 
end

%% Calculating Best Seeds

fprintf('Calculating Best Seeds for Each %s\n', captialize(UNIT));

% initialize_best_seed, not finished, needs to use global variables
bestSeed = initialize_best_seed(freeParams, labels, nv); % initialize
parfor i = 1:nv % for each voxel or vertex
    if ~opt.quiet && opt.parallel
        parallelProgressBar(nv, 'Calculating Best Seeds');
    elseif ~opt.quiet && mod(i,floor(nv/10)) == 0 % display voxel count every 10th of voxels
        fprintf('Calculating Best Seed: Voxel %d of %d\n', i, nv);
    end
    
    %%% find best seeds to intialize HRF fitting
    seedMat = NaN(length(scans), length(seeds)); % initialize predicted seeds matrix
    for i2 = 1:length(scans) % for each scan
        seedMat(i2,:) = call_correlation(opt.corr, scans(i2).vtc(:,i), ...
            scans(i2).convResp, scans(i2));
    end
    seedMat = mean(seedMat,1); % average across scan
    [bestCorr,bestIndx] = max(seedMat); % find best seeds
    
    %%% save best seed parameters
    bestSeed(i).seedId = bestIndx;
    for i2 = 1:length(freeParams) % for each parameter
        bestSeed(i).(freeParams{i2}) = seeds(bestIndx).(freeParams{i2});
    end
    bestSeed(i).corr = bestCorr;
end
if ~opt.quiet && opt.parallel % clean up parallel progress bar
    parallelProgressBar(-1, 'Calculating Best Seed');
end

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
fittedParams = fit_hrf(initParams, scans, opt);
%     for i = 1:length(hrf.freeList) % calculate estimated parameters
%         hrf.fit.(hrf.freeList{i}) = median([fittedParams.(hrf.freeList{i})], 'omitnan');
%     end

opt.stopTime = datestr(now);

%% Final Timings

stopTime = toc;
fprintf('Final HRF Estimation Time %5.2f minutes', round(stopTime/60));
fprintf('\n\n\n');