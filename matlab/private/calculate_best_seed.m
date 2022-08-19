function [bestSeed] = calculate_best_seed(protocols, seedResp)

%%% global parameters
corrFunc = get_global_parameters('fit.func.corr');

%%% initialize best seed structure for fitting
bestSeed = initialize_best_seed(protocols);

%%% fit best seed 
bestSeed = fit_wrapper(@fit_best_seed, bestSeed, corrFunc, seedResp); 

end

%% Helper Functions

function [bestSeed] = initialize_best_seed(protocols)
    
    %%% global parameters
    unit = get_global_parameters('unit');
    
    %%% initialize best seed structure
    flds = {'id', 'bold', 'seedId', 'corr'};
    bestSeed = initialize_structure(unit.n, flds);
    
    %%% assign best seed fields with values
    for i = 1:unit.n % for each unit
        bestSeed(i).id = unit.id(i);
        bestSeed(i).bold = cell(1, length(protocols));
        for i2 = 1:length(protocols) % for each protocol
            bestSeed(i).bold{i2} = protocols(i2).bold(:,i);
        end
    end

end

%%% fit best seed for each unit
function [bestSeed] = fit_best_seed(bestSeed, corrFunc, seedResp)

    %%% intialize correlation matrix
    seedCorr = NaN(length(bestSeed.bold), size(seedResp{1}, 2));
    
    %%% find best seeds to intialize pRF fitting
    for i2 = 1:size(seedCorr, 1) % for each protocol
        seedCorr(i2,:) = corrFunc(bestSeed.bold{i2}, seedResp{i2});
    end
    seedCorr = mean(seedCorr); % average across protocols
    [bestCorr,bestId] = max(seedCorr); % find best seeds
    
    %%% save best seed parameters
    bestSeed.seedId = bestId;
    bestSeed.corr = bestCorr;

end