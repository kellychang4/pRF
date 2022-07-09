function [bestSeed] = initialize_best_seed(freeList, nv)

bestSeed = struct(); 
for i = 1:nv % for each unit
    bestSeed(i).vertex = labels(i); 
    bestSeed(i).seedId = NaN;
    for i2 = 1:length(freeList) % for each field
        bestSeed(i2).(freeList{i2}) = NaN;
    end
    bestSeed(i).corr = NaN;
end