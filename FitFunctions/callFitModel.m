function [finalParams] = callFitModel(fitParams, pRF, scan, opt)
% [finalParams] = callFitMdodel(fitParams, scan, opt)
%
% Returns a structure containing the best fitting parameters.
%
% Inputs:
%   fitParams       A structire of parameter values to be fitted in the pRF
%                   model, and if opt.estHDR, values to estimate subject's
%                   HDR parameters
%   pRF             A structure containing the (to be) fitted pRF
%                   infomation, MUST contain the field:
%       bestSeed    A structure contain the best seed information for all
%                   voxels to be fitted
%   scan            A structure containing all scan(s) information
%   opt             A structure containing options for the model fitting
%
% Outputs:
%   finalParams     A structure with the best fitting parameters. If
%                   opt.estHDR, the structure has been (1) first fitted for
%                   the free paramaters in opt.freeList and (2) second
%                   fitted for 'tau' and 'delta' in the HDR gamma function.
%                   Else if opt.estHDR is false, only the pRF model is
%                   fitted

% Written by Kelly Chang - July 12, 2016

%% Fitting pRF Model

nVox = length(scan(1).vtc);

disp('Fitting pRF Model');
fittedParams = fitParams;
parfor i = 1:nVox
    if ~opt.quiet && opt.parallel
        parallelProgressBar(nVox,  struct('title', 'Fitting pRF'));
    elseif ~opt.quiet && mod(i, 100) == 0 % display voxel count every 100 voxels
        disp(sprintf('Fitting pRF for Voxel %d of %d', i, nVox));
    end
    if opt.fitpRF && ~isnan(pRF(i).bestSeed.corr) && ...
            pRF(i).bestSeed.corr > opt.corrThr
        [out,err] = fitcon('fitModel', fitParams(i), opt.freeList, ...
            i, scan, opt);
        
        fittedParams(i) = out;
        fittedParams(i).didFit = true;
        fittedParams(i).corr = -err;
    end
end
if ~opt.quiet && opt.parallel
    parallelProgressBar(-1, struct('title', 'Fitting pRF')); % clean up parallel progress bar
end

%% Estimating HDR

finalParams = fittedParams;
if opt.estHDR
    disp('Estimating HDR');
    parfor i = 1:nVox
        if ~opt.quiet && opt.parallel
            parallelProgressBar(nVox,  struct('title', 'Estimating HDR'));
        elseif ~opt.quiet && mod(i, 100) == 0 % display voxel count every 100 voxels
            disp(sprintf('Estimating HDR for Voxel %d of %d', i, nVox));
        end
        
        if opt.fitpRF && ~isnan(pRF(i).bestSeed.corr) && ...
                pRF(i).bestSeed.corr > opt.corrThr
            [out,err] = fitcon('fitHDR', fittedParams(i), {'tau', 'delta'}, ...
                i, scan, opt);
            
            finalParams(i) = out;
            finalParams(i).corr = -err;
            finalParams(i).didFit = true;
        end
    end
    if ~opt.quiet && opt.parallel
        parallelProgressBar(-1, struct('title', 'Estimating HDR')); % clean up parallel progress bar
    end
end