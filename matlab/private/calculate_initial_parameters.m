function [initParams] = calculate_initial_parameters(bestSeed)

[nv,hrf,seeds] = get_global_parameters('unit.n', 'hrf', 'seeds');

%%% calculate best seed threshold index and range values
thrIndx = [bestSeed.corr] > hrf.thr; % threshold index
nMin = ceil(nv .* hrf.pmin); nMax = ceil(nv .* hrf.pmax);

%%% if no units past threshold to minimum value, decrease threshold
if sum(thrIndx) < nMin
    while sum(thrIndx) < nMin
        hrf.thr = hrf.thr - 0.01; % decrement threshold 
        thrIndx = [bestSeed.corr] > hrf.thr;
    end
    fprintf(['[NOTE] Insufficient number of units after seed ', ...
        'fitting that were past threshold.\nLowering correlation ', ...
        'threshold to %0.2f.\n'], hrf.thr);
    set_global_parameters('hrf.thr', hrf.thr); 
end

%%% subset to units with seed fits past threshold
bestSeed = bestSeed(thrIndx); % threshold limit
[~,sortId] = sort([bestSeed.corr], 'descend');

%%% truncate to number units allowed to be fit
nSubset = min(max(length(bestSeed), nMin), nMax);
bestSeed = bestSeed(sortId(1:nSubset));

%%% create initial parameter structure
initParams = struct();
for i = 1:length(bestSeed)
    initParams(i).id    = bestSeed(i).id;
    initParams(i).bold  = bestSeed(i).bold;
    initParams(i).prf   = seeds(bestSeed(i).seedId); 
    initParams(i).hrf   = hrf.defaults; 
    initParams(i).corr  = NaN;
end