function [fittedParams] = callFitModel(fitParams, freeList, scan, opt)
% [fittedParams] = callFitModel(fitParams, freeList, scan, opt)
%
% Returns a structure containing the best fitting parameters for pRF
% fitting. 
%
% Inputs:
%   fitParams       A structire of parameter values to be fitted in the pRF
%                   model as fields
%   freeList        Cell array containing list of parameter names, can
%                   contain inequalities to restrict parameter estimate
%                   ranges, string (see fitcon.m for inequality help)
%   scan            A structure containing all scan(s) information
%   opt             A structure containing options for pRF fitting
%
% Output:
%   fittedParams    A structure with the best fitting parameters from only 
%                   fitting the pRF model

% Written by Kelly Chang - July 12, 2016

%% Variables and Input Control

try nv = length(scan(1).voxID); catch; nv = length(scan(1).vertex); end
freeName = regexprep(freeList, '[^A-Za-z]', '');
barName = sprintf('Estimating: %s', strjoin(freeName, ' & '));

%% Fitting Model

fittedParams = fitParams;
for i = 1:nv % for each voxel or vertex
    if ~opt.quiet && opt.parallel
        parallelProgressBar(nv, barName);
    elseif ~opt.quiet && mod(i,floor(nv/10)) == 0 % display voxel count every 100 voxels
        fprintf('Fitting pRF: %d of %d\n', i, nv);
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