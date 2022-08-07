function [bestSeed] = calculate_best_seed(protocols, seedResp)

%%% global parameters
[nv,p] = get_global_parameters('unit.n', 'parallel'); 

bestSeed = initialize_best_seed(protocols);

switch p.flag
    case false % sequential processing
        
        for i = 1:nv % for each unit
            %%% print progress status
            print_progress(i, nv);

            %%% fit current vertex or voxel seed values
            bestSeed(i) = fit_best_seed(bestSeed(i), seedResp);
        end
        
    case true % parallel processing
        
        %%% start best seed calculations in background pool
        f(1:nv) = parallel.FevalFuture(); 
        for i = 1:nv % for each voxel or vertex
            f(i) = parfeval(backgroundPool, @fit_best_seed, 1, ...
                bestSeed(i), seedResp);
        end

        %%% collect completed best seed calculations
        for i = 1:nv % for each voxel or vertex
            %%% print progress status
            print_progress(i, nv);
            
            %%% fetch best seed results from parallel pool
            [indx,results] = fetchNext(f);
            bestSeed(indx) = results;
        end

end

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
function [bestSeed] = fit_best_seed(bestSeed, seedResp)

    %%% intialize correlation matrix
    seedCorr = NaN(length(bestSeed.bold), size(seedResp{1}, 2));

    %%% find best seeds to intialize HRF fitting
    for i2 = 1:size(seedCorr, 1) % for each protocol
        seedCorr(i2,:) = corr(bestSeed.bold{i2}, seedResp{i2});
    end
    seedCorr = mean(seedCorr); % average across protocols
    [bestCorr,bestId] = max(seedCorr); % find best seeds
    
    %%% save best seed parameters
    bestSeed.seedId = bestId;
    bestSeed.corr = bestCorr;
    
end