function [fittedParams] = callFitHRF(fitParams, scan, opt)
% [fittedParams] = callFitMdodel(fitParams, scan, opt)
%
% Returns a structure containing the best fitting parameters after an
% iterative HRF and pRF fitting.
%
% Inputs:
%   fitParams       A structure of parameter values of HRF and pRF that are
%                   to be fitted
%   scan            A structure containing all scan(s) information
%   opt             A structure containing options for the model fitting
%
% Outputs:
%   fittedParams    A structure with the best fitting parameters. The HRF
%                   fitting process only takes the voxels that have passed
%                   the specified opt.hrfThr. While holding the pRF
%                   parameters constant, tau and delta are fitted. Then,
%                   using the estimated HRF parameters, the pRF parameters
%                   are fitted again. This process repeats for the
%                   specified opt.estHRF iterations.

% Written by Kelly Chang - February 2, 2017

%% Select Voxels that Fitted Past HRF Correlation Threshold

indx = [fitParams.corr] > opt.hrfThr;
fitParams = fitParams(indx);
for i = 1:length(scan)
    scan(i).vtc = scan(i).vtc(indx);
end
parallelTitle = 'Estimating HRF (%d): tau & delta';

%% Fitting HRF

fittedParams = fitParams;
for i = 1:opt.estHRF
    fprintf('HRF Fitting Iteration %d of %d\n',  i, opt.estHRF);
    parfor nV = 1:sum(indx) % for each voxel
        if ~opt.quiet && opt.parallel
            parallelProgressBar(sum(indx), struct('title', sprintf(parallelTitle,i)));
        elseif ~opt.quiet && mod(nV,floor(sum(indx)/10)) == 0 % display voxel count every 100 voxels
            fprintf('Fitting HRF: Voxel %d of %d\n', nV, sum(indx));
        end
        fittedParams(nV) = fitcon('fitModel', fittedParams(nV), ...
            {'tau','delta'}, nV, scan, opt);
    end
    if ~opt.quiet && opt.parallel % clean up parallel progress bar
        parallelProgressBar(-1, struct('title', sprintf(parallelTitle,i)));
    end
    fitTau = median([fittedParams.tau]);
    fitDelta = median([fittedParams.delta]);
    fittedParams = assignfield(fittedParams, 'tau', fitTau, 'delta', fitDelta);
    if i ~= opt.estHRF % not the last hrf fitting iteration
        fittedParams = callFitModel(fittedParams, opt.freeList, scan, opt);
    end
end