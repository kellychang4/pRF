function [bestSeed] = initialize_best_seed(protocols, seedResp)

% nv = get_global_variables('prf.nv'); 
nv = length(protocols(1).vertex);

bestSeed = struct(); 
for i = 1:nv % for each unit
    bestSeed(i).vertex = protocols(1).vertex(i);    
    for i2 = 1:length(protocols) % for each protocol
        bestSeed(i).bold{i2} = protocols(i2).bold(:,i);
        bestSeed(i).seedPred{i2} = seedResp{i2};
    end
    bestSeed(i).seedId = NaN;
    bestSeed(i).corr = NaN;
end