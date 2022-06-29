function [collated] = estimate_prfs(scan, seeds, hrf, opt)
% [collated] = estimate_prfs(scan, seeds, hrf, opt)
%
% Estimates a pRF model given the scan, seeds, hrf, and options
%
% Inputs:
%   scan                    A structure containing information about the
%                           scan(s) (see 'createScan.m')
%   seeds                   A structure containing information about the
%                           seeds (see 'createSeeds.m')
%   hrf                     A structure containing information about the
%                           hemodynamic response function
%                           (see 'createHRF.m')
%   opt                     A structure containing information about model
%                           fitting options (see 'createOpt.m')
%
% Outputs:
%   collated                A collated structure with all relevant
%                           structures as fields:
%       scan                Same 'scan' structure, but with additional
%                           fields:
%           convStim        Stimulus image convolved with the (fitted) HRF
%           seedpRF         pRF model based on each seed parameter(s) in
%                           'seeds', a MxN matrix where M is length(scan.x)
%                           and N is the number of seeds
%           seedPred        Predicted response for each seed pRF, a MxN
%                           matrix where M is the number of volumes in the
%                           scan and N is the number of seeds
%       seeds               Same 'seeds' structure
%       hrf                 Same 'hrf' structure, but if 'opt.estHRF' was
%                           used, with additional field:
%           fit             A structure with fitted estimate of the
%                           'hrf.freeList' parameters as fields
%       pRF                 A structure containing fitted pRF information
%                           for each voxel with fields:
%           id              Voxel ID number
%           didFit          Fitted voxel (true) OR not (false), logical
%           <estimated      Estimated parameters, will match the parameters
%           parameter(s)>   as given in 'opt.freeList'
%           corr            Correlation from the estimated pRF parameters
%           bestSeed        A structure containing information about the
%                           best seed used to estimate the pRF model, see
%                           Notes section for more information
%       opt                 Same 'opt' structure
%
% Notes:
% - bestSeed
%       seedID              Seed ID number (i.e, seeds(seedID))
%       <parameter names>   Parameters from seeds(seedID)
%       corr                Correlation from the best seed

% Written by Kelly Chang - May 25, 2016
% Edited by Kelly Chang - June 6, 2022

%% Global Variables

paramNames = eval(opt.model);
scanExp = ones(1, length(seeds)); % no exponent factor
freeName = regexprep(opt.freeList, '[^A-Za-z]', '');

ANATOMICAL_TYPE = 'volume'; % volume space, default
if any(strcmp(fieldnames(scan), 'vertex')); ANATOMICAL_TYPE = 'surface'; end

switch ANATOMICAL_TYPE
    case 'volume'
        nv = length(scan(1).voxId);
        prfFlds = ['id', 'index', 'didFit', freeName, 'corr', 'bestSeed'];
    case 'surface'
        nv = length(scan(1).vertex);
        prfFlds = ['vertex', 'didFit', freeName, 'corr', 'bestSeed'];
end

%% Variables and Input Control

if ~opt.CSS && ismember('exp', freeName)
    fprintf('NOTE: ''opt.CSS'' set as TRUE due to ''exp'' in ''opt.freeList''\n');
    opt.CSS = true;
end

if opt.CSS && ~ismember('exp', freeName)
    error('''opt.CSS'' is true without ''exp'' in ''opt.freeList''');
end

if opt.CSS % exponent factor
    scanExp = [seeds.exp];
    paramNames.params = [paramNames.params 'exp'];
end

%% Error Checking

% if free parameter without seeds
if any(ismember(freeName, fieldnames(seeds)) == 0)
    errFlds = setdiff(freeName, fieldnames(seeds));
    error('No seeds for opt.freeList parameter(s): %s', ...
        strjoin(errFlds, ', '));
end

% if model cannot estimate all given free parameters
if any(ismember(freeName, paramNames.params) == 0)
    errFlds = setdiff(freeName, paramNames.params);
    error('%s() does not have given opt.freeList parameter(s): %s', ...
        opt.model, strjoin(errFlds, ', '));
end

% if estimated hrf but pre-defined hrf provided
if ~isnan(opt.estHRF) && isfield(hrf, 'hrf')
    error('Cannot estimate HRF with pre-defined (non-paramaterized) HRF');
end

% if cost parameter is not all within the free parameters, excluding hrf
% parameters
if ~isempty(fieldnames(opt.cost)) && isfield(hrf,'funcName') && ...
        ~all(ismember(setdiff(fieldnames(opt.cost), feval(hrf.funcName)), freeName))
    errFlds = setdiff(setdiff(fieldnames(opt.cost), feval(hrf.funcName)), freeName);
    error('Cost parameter(s) not found in the free parameters: %s', ...
        strjoin(errFlds, ', '))
end

%% Initialize pRF Structure

for i = 1:nv % for each voxel or vertex
    for i2 = 1:length(prfFlds)
        if strcmp(prfFlds{i2}, 'id')
            pRF(i).id = scan(1).voxID(i); % voxel 'id' number
        elseif strcmp(prfFlds{i2}, 'index')
            pRF(i).index = scan(1).voxIndex(i,:);
        elseif strcmp(prfFlds{i2}, 'vertex')
            pRF(i).vertex = scan(1).vertex(i); % vertex index
        else
            pRF(i).(prfFlds{i2}) = NaN;
        end
    end    
end

%% Open Parallel Cores

opt.parallel = openParallel(opt.parallel);

%% Create Predicted BOLD Response for Each Seed

tic();
opt.startTime = datestr(now);
fprintf('Calculating Predicted Response for Each Seed\n');
for i = 1:length(scan) % for each scan
    scan(i).convStim = createConvStim(scan(i), hrf); % convolve hrf with stimulus image
    for i2 = 1:length(seeds) % for each seed
        scan(i).seedpRF(:,i2) = ascol(feval(opt.model, seeds(i2), scan(i).funcOf)); % pRF model for each seed
    end
    scan(i).seedPred = bsxfun(@power, pos0(scan(i).convStim * scan(i).seedpRF), ...
        scanExp); % multiply by seed pRF
end

%% Calculating Best Seeds

fprintf('Calculating Best Seeds\n');
parfor i = 1:nv % for each voxel or vertex
    if ~opt.quiet && opt.parallel
        parallelProgressBar(nv, 'Calculating Best Seeds');
    elseif ~opt.quiet && mod(i,floor(nv/10)) == 0 % display voxel count every 10th of voxels
        fprintf('Calculating Best Seed: Voxel %d of %d\n', i, nv);
    end
    
    % find best seeds to intialize pRF fitting
    seedMat = NaN(length(scan), length(seeds)); % initialize predicted seeds matrix
    for i2 = 1:length(scan)
        seedMat(i2,:) = callCorr(opt.corr, scan(i2).vtc(:,i), scan(i2).seedPred, scan(i2));
    end
    seedMat = mean(seedMat,1); % average across scan
    [maxCorr,bestSeedIndx] = max(seedMat); % find best seeds
    
    % save seeds fits
    bestSeed = seeds(bestSeedIndx);
    bestSeed = rmfield(bestSeed, setdiff(fieldnames(bestSeed), freeName));
    bestSeed.seedID = bestSeedIndx;
    bestSeed.corr = maxCorr;
    pRF(i).bestSeed = orderfields(bestSeed, ...
        ['seedID' freeName 'corr']);
end
if ~opt.quiet && opt.parallel % clean up parallel progress bar
    parallelProgressBar(-1, 'Calculating Best Seed');
end

%% Create 'fitParams' Structure for pRF Fitting

for i = 1:nv % for each voxel or vertex
    tmp = hrf;
    tmp.corr = NaN;
    tmp.didFit = false;
    if ~opt.CSS; tmp.exp = 1; end
    tmp.seedCorr = pRF(i).bestSeed.corr;
    for i2 = 1:length(freeName) % load 'fitParams' with bestSeed params
        tmp.(freeName{i2}) = pRF(i).bestSeed.(freeName{i2});
    end
    fitParams(i) = tmp;
end

%% Fitting pRF Model (and Estimating HRF)

fprintf('Fitting pRF Model\n');
fittedParams = callFitModel(fitParams, opt.freeList, scan, opt);

if ~isnan(opt.estHRF) % if estimating HRF
    fprintf('Estimating HRF\n');
    fittedParams = callFitHRF(fittedParams, scan, opt);
    for i = 1:length(hrf.freeList) % calculate estimated parameters
        hrf.fit.(hrf.freeList{i}) = median([fittedParams.(hrf.freeList{i})], 'omitnan');
    end
    for i = 1:length(scan) % update convolved stimulus for pRF fitting
        scan(i).convStim = createConvStim(scan(i), hrf);
    end
    fprintf('Fitting pRF Model with Estimated HRF\n');
    fittedParams = callFitModel(fitParams, opt.freeList, scan, opt);
end
opt.stopTime = datestr(now);

%% Collect Final pRF Values

for i = 1:nv % for each voxel or vertex
    pRF(i).didFit = fittedParams(i).didFit;
    pRF(i).corr = fittedParams(i).corr;
    for i2 = 1:length(freeName)
        pRF(i).(freeName{i2}) = fittedParams(i).(freeName{i2});
    end
end

%% Organize Output

pRF = orderfields(pRF, prfFlds);
collated = collate(scan, seeds, hrf, pRF, opt);

%% Final Timings

stopTime = toc;
fprintf('Final pRF Estimation Time %5.2f minutes', round(stopTime/60));
fprintf('\n\n\n');