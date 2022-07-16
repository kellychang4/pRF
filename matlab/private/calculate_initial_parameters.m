function [initParams] = calculate_initial_parameters(bestSeed)

[nv, hrfParams, seeds] = get_global_variables('n.unit', 'hrf', 'seeds');

%%% subset to units with seed fits past threshold
bestSeed = bestSeed([bestSeed.corr] > hrfParams.thr);
[~,sortId] = sort([bestSeed.corr], 'descend');

%%% truncate to number units allowed to be fit
nMin = ceil(nv .* hrfParams.pmin); 
nMax = ceil(nv .* hrfParams.pmax);
nSubset = min(max(length(bestSeed), nMin), nMax);
bestSeed = bestSeed(sortId(1:nSubset));

%%% create initial parameter structure
initParams = struct();
for i = 1:length(bestSeed)
    initParams(i).vertex = bestSeed(i).vertex;
    initParams(i).bold = bestSeed(i).bold;
    initParams(i).prf = seeds(bestSeed(i).seedId); 
    initParams(i).hrf = hrfParams.defaults; 
    initParams(i).corr = NaN;
end