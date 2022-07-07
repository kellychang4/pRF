function [bestSeed] = initalize_best_seed(freeList, nv)

flds = ['seedId', freeList, 'corr'];
for i2 = 1:length(flds) % for each field
    bestSeed.(flds{i2}) = NaN;
end
bestSeed = repmat(bestSeed, 1, nv);