function [bestSeed] = calculate_best_seed(bestSeed, seedResp)

n = get_global_variables('n'); 

parallelFlag = get_global_variables('fit.parallel');
% nUnits = get_global_variables('print.nunits'); 

switch parallelFlag
    case 0
        
        for i = 1:n.unit % for each unit
        
            %%% print progress status
%             if ~mod(i, nUnits)
%                 unitStr = sprintf('%%%dd', vLength);
%                 print_message(['  Vertex ', unitStr, ' out of %d (%6.2f%%)...\n'], i, nv, i/nv*100); 
%             end
            
            %%% current vertex or voxel seed values
            curr = bestSeed(i);
            
            %%% find best seeds to intialize HRF fitting
            seedCorr = NaN(n.protocols, n.seeds); 
            for i2 = 1:n.protocols % for each scan
                seedCorr(i2,:) = corr(curr.bold{i2}, seedResp{i2});
            end
            seedCorr = mean(seedCorr); % average across scan
            [bestCorr,bestId] = max(seedCorr); % find best seeds
            
            %%% save best seed parameters
            bestSeed(i).seedId = bestId;
            bestSeed(i).corr = bestCorr;
        end
        
    case 1
        
        %%% initialize parfor progress bar
%         if ~flags.printQuiet; parfor_progress(nv); end
        
        parfor i = 1:n.unit % for each voxel or vertex
            fprintf('Vertex %6d of %d\n', i, n.unit);
            %%% print progress status
%             if ~flags.printQuiet 
%                 fprintf('  %d out of %d (%0.2f%%)...\n', i, nv, i ./ nv .* 100); 
%             end
 
            %%% current vertex or voxel seed values
            curr = bestSeed(i);
            
            %%% find best seeds to intialize HRF fitting
            seedCorr = NaN(n.protocols, n.seeds); 
            for i2 = 1:n.protocols % for each scan
                seedCorr(i2,:) = corr(curr.bold{i2}, seedResp{i2});
            end
            seedCorr = mean(seedCorr); % average across scan
            [bestCorr,bestId] = max(seedCorr); % find best seeds
            
            %%% save best seed parameters
            bestSeed(i).seedId = bestId;
            bestSeed(i).corr = bestCorr;
        end
        
        %%% delete parfor progress bar
%         if ~flags.printQuiet; parfor_progress(0); end
end
