function [bestSeed] = calculate_best_seed(protocols, seedResp)

%%% global parameters
[nv,p,corrFunc] = get_global_parameters('unit.n', 'parallel', 'fit.func.corr');

bestSeed = initialize_best_seed(protocols);

switch p.flag
    case false % sequential processing

        for i = 1:nv % for each unit
            %%% print progress status
            print_progress(i, nv);

            %%% fit current vertex or voxel seed values
            bestSeed(i) = fit_best_seed(bestSeed(i), corrFunc, seedResp);
        end

    case true % parallel processing

        %%% initialize parallel job counters
        ct = 0; job = zeros(nv, 3); f(1:nv) = parallel.FevalFuture();

        %%% start best seed parallel processing
        while any(job(:,3) == 0) % while jobs are not collected

            %%% start best seed calculations in the parallel pool
            if ct < nv % if not all units have been placed into the queue

                %%% increment unit count and job index
                ct = ct + 1; j = find([f.ID] == -1, 1);

                %%% start best seed calculations
                f(j) = parfeval(p.pool, @fit_best_seed, 1, ...
                    bestSeed(ct), corrFunc, seedResp);

                %%% record job id
                job(ct, 1) = f(j).ID; % record job id

            end

            %%% check and mark completed job processing
            stateIndx = strcmp({f.State}, 'finished');
            markIndx  = ismember(job(:,1), [f(stateIndx).ID]);
            job(markIndx, 2) = 1; % mark as completed

            %%% locate completed but not collected job difference index
            diffIndx = logical(job(:,2) - job(:,3));

            if any(diffIndx) % if there are completed by unread jobs

                %%% find job ids that are completed but unread
                completedId = job(diffIndx, 1);

                for i2 = 1:length(completedId) % for each unread

                    %%% compute job and output indices
                    jobIndx = [f.ID] == completedId(i2);   % current job index
                    outIndx = job(:,1) == completedId(i2); % current output index

                    %%% fetch best seed output
                    bestSeed(outIndx) = fetchOutputs(f(jobIndx));

                    %%% mark job as completed and clear job object
                    job(outIndx, 3) = 1; % mark as collected
                    f(jobIndx) = [];     % clear job object
                    
                    %%% print progress status
                    print_progress(sum(job(:,3)), nv);

                end

            end
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