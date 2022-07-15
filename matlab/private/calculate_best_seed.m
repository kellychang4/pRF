function [bestSeed] = calculate_best_seed(bestSeed)

nv = length(bestSeed); 
np = length(bestSeed(1).bold); 
ns = size(bestSeed(1).seedPred{1}, 2);

parfor i = 1:nv % for each voxel or vertex
    %%% current vertex or voxel seed values
    curr = bestSeed(i);
    
    %%% find best seeds to intialize HRF fitting
    seedCorr = NaN(np, ns); % initialize correlaion matrix
    for i2 = 1:np % for each scan
        seedCorr(i2,:) = corr(curr.bold{i2}, curr.seedPred{i2});
    end
    seedCorr = mean(seedCorr); % average across scan
    [bestCorr,bestId] = max(seedCorr); % find best seeds
    
    %%% save best seed parameters
    bestSeed(i).seedId = bestId;
    bestSeed(i).corr = bestCorr;
end

bestSeed = rmfield(bestSeed, {'bold', 'seedPred'}); 