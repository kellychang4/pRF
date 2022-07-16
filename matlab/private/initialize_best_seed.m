function [bestSeed] = initialize_best_seed(protocols)

nv = get_global_variables('n.unit'); 

bestSeed = struct(); 
for i = 1:nv % for each unit
    bestSeed(i).vertex = protocols(1).vertex(i);    
    for i2 = 1:length(protocols) % for each protocol
        bestSeed(i).bold{i2} = protocols(i2).bold(:,i);
    end
    bestSeed(i).seedId = NaN;
    bestSeed(i).corr = NaN;
end