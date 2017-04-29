function [fittedParams] = callFitModel(fitParams, freeList, scan, opt)
% [fittedParams] = callFitModel(fitParams, freeList, scan, opt)
%
% Returns a structure containing the best fitting parameters for pRF
% fitting. 
%
% Inputs:
%   fitParams       A structire of parameter values to be fitted in the pRF
%                   model
%   freeList        Cell array containing list of parameter names, can
%                   contain inequalities to restrict parameter estimate
%                   ranges, string
%   scan            A structure containing all scan(s) information
%   opt             A structure containing options for pRF fitting
%
% Outputs:
%   fittedParams    A structure with the best fitting parameters from only 
%                   fitting the pRF model

% Written by Kelly Chang - July 12, 2016

%% Variables and Input Control

nVox = length(scan(1).vtc);
freeName = regexprep(freeList, '[^A-Za-z]', '');
barName = sprintf('Estimating: %s', strjoin(freeName, ' & '));

%% Fitting Model

fittedParams = fitParams;
parfor i = 1:nVox
    if ~opt.quiet && opt.parallel
        parallelProgressBar(nVox, barName);
    elseif ~opt.quiet && mod(i,floor(nVox/10)) == 0 % display voxel count every 100 voxels
        fprintf('Fitting pRF: Voxel %d of %d\n', i, nVox);
    end
    if ~isnan(fitParams(i).seedCorr) && fitParams(i).seedCorr > opt.corrThr
        [fittedParams(i),err] = fitcon('fitModel', fitParams(i), freeList, ...
            i, scan, opt);
        
        fittedParams(i).didFit = true;
        fittedParams(i).corr = -err;
    end
end
if ~opt.quiet && opt.parallel % clean up parallel progress bar
    parallelProgressBar(-1, barName);
end