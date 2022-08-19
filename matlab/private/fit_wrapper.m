function [varOut] = fit_wrapper(fitFunc, varOut, varargin)

%%% global parameters
[p,print] = get_global_parameters('parallel', 'print');
nv = length(varOut); % number of units

if ~p.flag % seqential processing

    for i = 1:nv % for each unit
        %%% print progress status
        print_progress(i, nv);

        %%% fit current vertex or voxel
        varOut(i) = fitFunc(varOut(i), varargin{:});
    end

else % parallel processing

    switch p.method
        case 'parfor'

            if ~print.quiet

                %%% initialize parfor progress bar, if printing
                print_parfor_progress('initialize'); print.n = nv;

                parfor i = 1:nv % for each unit
                    %%% increment parfor progress bar, if printing
                    print_parfor_progress('increment', print);

                    %%% fit current vertex or voxel
                    varOut(i) = fitFunc(varOut(i), varargin{:});
                end

                %%% delete parfor progress bar, if printing
                print_parfor_progress('delete', print);

            else

                parfor i = 1:nv % for each unit
                    %%% fit current vertex or voxel seed values
                    varOut(i) = fitFunc(varOut(i), varargin{:});
                end

            end

        case 'parfeval'

            %%% initialize parallel job counters
            ct = 0; job = zeros(nv, 3); f(1:nv) = parallel.FevalFuture();

            %%% start best seed parallel processing
            while any(job(:,3) == 0) % while jobs are not collected

                %%% check how many jobs are currently ongoing
                nj = sum(ismember({f.State}, {'queued', 'ongoing'}));

                %%% start hrf fitting procedure in the parallel pool
                if ct < nv && nj < p.chunk % if not all jobs in queue AND within chunk limit

                    %%% increment unit count and job index
                    ct = ct + 1; j = find([f.ID] == -1, 1);

                    %%% start best seed calculations
                    f(j) = parfeval(p.pool, fitFunc, 1, varOut(ct), varargin{:});

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

                        %%% fetch fitted hrf parameter output
                        varOut(outIndx) = fetchOutputs(f(jobIndx));

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

