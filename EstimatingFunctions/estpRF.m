function [collated] = estpRF(scan, seeds, hdr, opt)
% [collated] = estpRF(scan, seeds, hdr, opt)
%
% Estimates the pRF model
%
% Inputs:
%   scan                    A structure containing information about the
%                           scan(s) (see 'createScan.m')
%   seeds                   A structure containing information about the
%                           seeds (see 'createSeeds.m')
%   hdr                     A structure containing information about the
%                           hemodynamic response function
%                           (see 'createHDR.m')
%   opt                     A structure containing information about model
%                           fitting options (see 'createOpt.m')
%
% Outputs:
%   collated                A collated structure with all relevant
%                           structures as fields:
%       scan                Same 'scan' structure, but with addition
%                           fields:
%           seedpRF         pRF model based on each seed parameter(s) in
%                           'seeds', a MxN matrix where M is length(scan.x)
%                           and N is the number of seeds
%           convStim        Convolved HDR with the stimulus image
%           seedPred        Predicted response for each seed pRF, a MxN
%                           matrix where M is the number of volumes in the
%                           scan and N si the number of seeds
%       seeds               Same 'seeds' structure
%       hdr                 Same 'hdr' structure, but if 'opt.estHDR' was
%                           true with additional field:
%           fit             A structure with fitted estimate of 'tau' and
%                           'delta' as fields
%       pRF                 A structure containing fitted pRF information
%                           for each voxel with fields:
%           id              Voxel ID number
%           didFit          Fitted voxel (true) OR not (false), logical
%           <estimated      Estimated parameters, will match the parameters
%           parameter(s)>   as given in 'opt.freeList'
%           tau             Time constant of HDR used the estimate pRF
%                           parameters
%           delta           Delay (seconds) of HDR used to estimate pRF
%                           parameters
%           corr            Correlation from the estimated pRF parameters
%           bestSeed        A structure containing information about the
%                           best seed used to estimate the pRF model, see
%                           Note section for more information
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
if ~opt.CSS
    scanExp = 1; % no exponent factor
else
    scanExp = mean([seeds.exp]);
    paramNames.params = [paramNames.params 'exp'];
end

%% Error Checking

if any(ismember(freeName, fieldnames(seeds)) == 0) % if free parameter without seeds
    errFlds = setdiff(freeName, fieldnames(seeds));
    error(sprintf('No seeds for opt.freeList parameter(s): %s', ...
        strjoin(errFlds, ', ')));
end

if any(ismember(freeName, paramNames.params) == 0) % if model cannot estimate all given free parameters
    errFlds = setdiff(freeName, paramNames.params);
    error(sprintf('%s() does not have given opt.freeList parameter(s): %s', ...
        opt.model, strjoin(errFlds, ', ')));
end

%% Initialize pRF Fields

for i = 1:nVox
    pRF(i).id = scan(1).vtc(i).id; % voxel 'id' number
    pRF(i).didFit = false;
    pRF(i).corr = NaN;
    pRF(i).tau = NaN;
    pRF(i).delta = NaN;
    pRF(i).bestSeed = NaN;
    for i2 = 1:length(freeName)
        pRF(i).(freeName{i2}) = NaN;
    end
end

%% Create Predicted Responses for Each Seed

tic();
opt.startTime = datestr(now);
disp('Calculating Predicted Response for Each Seed');
for i = 1:length(scan) % loop through scan
    for i2 = 1:length(seeds) % loop through seeds
        tmp = eval([opt.model '(seeds(i2),scan(i));']);
        scan(i).seedpRF(:,i2) = tmp(:); % pRF model for each seed
    end
    scan(i).convStim = createConvStim(scan(i), hdr); % convolve hdr with the stimulus image
    scan(i).seedPred = [scan(i).convStim] * [scan(i).seedpRF].^scanExp; % multiply by seed pRF
end

%% Open Parallel Cores

opt = openParallel(opt);

%% Calculating Best Seeds

disp('Calculating Best Seeds');
parfor i = 1:nVox
    if ~opt.quiet && opt.parallel
        parallelProgressBar(nVox,  struct('title', 'Calculating Best Seed'));
    elseif ~opt.quiet && mod(i, 100) == 0 % display voxel count every 100 voxels
        disp(sprintf('Calculating Best Seed for Voxel %d of %d', i, nVox));
    end
    
    % find best seeds to intialize pRF fitting
    seedMat = NaN(length(scan), length(seeds)); % initialize predicted seeds matrix
    for i2 = 1:length(scan)
        seedMat(i2,:) = callCorr(scan(i2).vtc(i).tc, scan(i2).seedPred, opt.corr);
    end
    seedMat = mean(seedMat,1); % average across scan
    [maxCorr,bestSeedIndx] = max(seedMat); % find best seeds
    
    % save seeds fits
    bestSeed = seeds(bestSeedIndx);
    bestSeed = rmfield(bestSeed, setdiff(fieldnames(bestSeed), freeName))
    bestSeed.seedID = bestSeedIndx;
    bestSeed.corr = maxCorr;
    pRF(i).bestSeed = orderfields(bestSeed, ...
        ['seedID' freeName 'corr']);
end

if ~opt.quiet && opt.parallel
    parallelProgressBar(-1, struct('title', 'Calculating Best Seed')); % clean up parallel progress bar
end

%% Prepare 'fitParams' Structure for pRF Fitting

disp('Preparing ''fitParams'' Structure for pRF Fitting');
for i = 1:nVox
    tmp = hdr;
    tmp.didFit = false;
    tmp.exp = 1;
    tmp.corr = NaN;
    for i2 = 1:length(freeName) % load 'fitParams' with bestSeed params
        tmp.(freeName{i2}) = pRF(i).bestSeed.(freeName{i2});
    end
    fitParams(i) = tmp;
end

%% Fitting pRF Model (and Estimating HDR)

fittedParams = callFitModel(fitParams, pRF, scan, opt);
if opt.estHDR
    hdr.fit.tau = median([fittedParams([fittedParams.didFit]).tau]);
    hdr.fit.delta = median([fittedParams([fittedParams.didFit]).delta]);
end
opt.stopTime = datestr(now);

%% Collect Final pRF Values

for i = 1:nVox
    pRF(i).didFit = fittedParams(i).didFit;
    pRF(i).corr = fittedParams(i).corr;
    pRF(i).tau = fittedParams(i).tau;
    pRF(i).delta = fittedParams(i).delta;
    for i2 = 1:length(freeName)
        pRF(i).(freeName{i2}) = fittedParams(i).(freeName{i2});
    end
end

%% Organize Output

pRF = orderfields(pRF, ['id' 'didFit' freeName 'corr' 'tau' 'delta' 'bestSeed']);
collated = collate(scan, seeds, hdr, pRF, opt);

%% Final Timings

stopTime = toc;
disp(sprintf('Final pRF Estimation Time %5.2f minutes', round(stopTime/60)));
fprintf('\n\n\n');