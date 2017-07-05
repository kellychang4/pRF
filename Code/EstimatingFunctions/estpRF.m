function [collated] = estpRF(scan, seeds, hrf, opt)
% [collated] = estpRF(scan, seeds, hrf, opt)
%
% Estimates the pRF model
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
% Output:
%   collated                A collated structure with all relevant
%                           structures as fields:
%       scan                Same 'scan' structure, but with addition
%                           fields:
%           seedpRF         pRF model based on each seed parameter(s) in
%                           'seeds', a MxN matrix where M is length(scan.x)
%                           and N is the number of seeds
%           convStim        Convolved HRF with the stimulus image
%           seedPred        Predicted response for each seed pRF, a MxN
%                           matrix where M is the number of volumes in the
%                           scan and N si the number of seeds
%       seeds               Same 'seeds' structure
%       hrf                 Same 'hrf' structure, but if 'opt.estHRF' was
%                           true with additional field:
%           fit             A structure with fitted estimate of 'tau' and
%                           'delta' as fields
%       pRF                 A structure containing fitted pRF information
%                           for each voxel with fields:
%           id              Voxel ID number
%           didFit          Fitted voxel (true) OR not (false), logical
%           <estimated      Estimated parameters, will match the parameters
%           parameter(s)>   as given in 'opt.freeList'
%           tau             Time constant of HRF used the estimate pRF
%                           parameters
%           delta           Delay (seconds) of HRF used to estimate pRF
%                           parameters
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

%% Variables and Input Control

nVox = length(scan(1).vtc);
freeName = regexprep(opt.freeList, '[^A-Za-z]', '');

paramNames = eval(opt.model);
scanExp = 1; % no exponent factor
if opt.CSS
    scanExp = mean([seeds.exp]);
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

% if cost parameter is not all within the free parameters, excluding 'tau' and 'delta'
if ~isempty(fieldnames(opt.cost)) && ~all(ismember(setdiff(fieldnames(opt.cost), {'tau', 'delta'}), freeName))
    errFlds = setdiff(setdiff(fieldnames(opt.cost), {'tau', 'delta'}), freeName);
    error('Cost parameter(s) not found in the free parameters: %s', ...
        strjoin(errFlds, ', '))
end

% if estimated hrf but pre-defined hrf provided
if ~isnan(opt.estHRF) && isfield(hrf, 'hrf')
    error('Cannot estimate HRF with pre-defined (non-paramaterized) HRF');
end

%% Initialize pRF Fields

for i = 1:nVox
    pRF(i).id = scan(1).vtc(i).id; % voxel 'id' number
    pRF(i).didFit = false;
    pRF(i).corr = NaN;
    pRF(i).bestSeed = NaN;
    for i2 = 1:length(freeName)
        pRF(i).(freeName{i2}) = NaN;
    end
end

%% Open Parallel Cores

opt.parallel = openParallel(opt.parallel);

%% Create Predicted BOLD Response for Each Seed

tic();
opt.startTime = datestr(now);
fprintf('Calculating Predicted Response for Each Seed\n');
for i = 1:length(scan) % loop through scan
    for i2 = 1:length(seeds) % loop through seeds
        tmp = callModel(opt.model, seeds(i2), scan(i));
        scan(i).seedpRF(:,i2) = tmp(:); % pRF model for each seed
    end
    scan(i).convStim = createConvStim(scan(i), hrf); % convolve hrf with the stimulus image
    scan(i).seedPred = pos0(scan(i).convStim * scan(i).seedpRF).^scanExp; % multiply by seed pRF
end

%% Calculating Best Seeds

fprintf('Calculating Best Seeds\n');
parfor i = 1:nVox
    if ~opt.quiet && opt.parallel
        parallelProgressBar(nVox, 'Calculating Best Seed');
    elseif ~opt.quiet && mod(i,floor(nVox/10)) == 0 % display voxel count every 10th of voxels
        fprintf('Calculating Best Seed: Voxel %d of %d\n', i, nVox);
    end
    
    % find best seeds to intialize pRF fitting
    seedMat = NaN(length(scan), length(seeds)); % initialize predicted seeds matrix
    for i2 = 1:length(scan)
        seedMat(i2,:) = callCorr(opt.corr, scan(i2).vtc(i).tc, scan(i2).seedPred, scan(i2));
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

%% Prepare 'fitParams' Structure for pRF Fitting

for i = 1:nVox
    tmp = hrf;
    tmp.didFit = false;
    tmp.exp = 1;
    tmp.corr = NaN;
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
    for i = 1:length(hrf.freeList)
        hrf.fit.(hrf.freeList{i}) = median([fittedParams.(hrf.freeList{i})], 'omitnan');
    end
    fitParams = eval(sprintf('assignfield(fitParams,%s);', ...
        strjoin(cellfun(@(x) sprintf('''%1$s'',hrf.fit.%1$s',x), ...
        hrf.freeList, 'UniformOutput', false),',')));
    fprintf('Fitting pRF Model with Estimated HRF\n');
    fittedParams = callFitModel(fitParams, opt.freeList, scan, opt);
    for i = 1:length(scan) % update convolved stimulus
        scan(i).convStim = createConvStim(scan(i), fittedParams(1));
    end
end
opt.stopTime = datestr(now);

%% Collect Final pRF Values

for i = 1:nVox
    pRF(i).didFit = fittedParams(i).didFit;
    pRF(i).corr = fittedParams(i).corr;
    for i2 = 1:length(freeName)
        pRF(i).(freeName{i2}) = fittedParams(i).(freeName{i2});
    end
end

%% Organize Output

pRF = orderfields(pRF, ['id' 'didFit' freeName 'corr' 'bestSeed']);
collated = collate(scan, seeds, hrf, pRF, opt);

%% Final Timings

stopTime = toc;
fprintf('Final pRF Estimation Time %5.2f minutes', round(stopTime/60));
fprintf('\n\n\n');