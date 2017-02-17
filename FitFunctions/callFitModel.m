function [fittedParams] = callFitModel(fitParams, freeList, scan, pRF, opt)
% [fittedParams] = callFitMdodel(fitParams, scan, opt)
%
% Returns a structure containing the best fitting parameters.
%
% Inputs:
%   fitParams       A structire of parameter values to be fitted in the pRF
%                   model, and if opt.estHDR, values to estimate subject's
%                   HDR parameters
%   freeList        Cell array containing list of parameter names, can 
%                   contain inequalities to restrict parameter estimate
%                   ranges, string
%   scan            A structure containing all scan(s) information
%   pRF             A structure containing the (to be) fitted pRF
%                   infomation, MUST contain the field:
%       bestSeed    A structure contain the best seed information for all
%                   voxels to be fitted
%   opt             A structure containing options for the model fitting
%
% Outputs:
%   fittedParams    A structure with the best fitting parameters. If
%                   opt.estHDR, the structure has been (1) first fitted for
%                   the free paramaters in opt.freeList and (2) second
%                   fitted for 'tau' and 'delta' in the HDR gamma function.
%                   Else if opt.estHDR is false, only the pRF model is
%                   fitted

% Written by Kelly Chang - July 12, 2016

%% Variables and Input Control

nVox = length(scan(1).vtc);
freeName = regexprep(freeList, '[^A-Za-z]', '');
parallelOpt.title = sprintf('Estimating: %s', strjoin(upper1(freeName), ' & '));

% if not estimating HDR
if ~all(ismember({'tau', 'delta'}, freeList))
    opt.estHDR = false;
end

%% Fitting Model

fittedParams = fitParams;
parfor i = 1:nVox
    if ~opt.quiet && opt.parallel
        parallelProgressBar(nVox, parallelOpt);
    elseif ~opt.quiet && mod(i, 100) == 0 % display voxel count every 100 voxels
        disp(sprintf('Fitting pRF for Voxel %d of %d', i, nVox));
    end
    if opt.fitpRF && ~isnan(pRF(i).bestSeed.corr) && ...
            pRF(i).bestSeed.corr > opt.corrThr
        [fittedParams(i),err] = fitcon('fitModel', fitParams(i), freeList, ...
            i, scan, opt);
        
        fittedParams(i).didFit = true;
        fittedParams(i).corr = -err;
    end
end
if ~opt.quiet && opt.parallel % clean up parallel progress bar
    parallelProgressBar(-1, parallelOpt);
end