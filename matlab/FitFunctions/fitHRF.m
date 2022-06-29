function [err] = fitHRF(fitParams, vN, scan, opt)
% [err] = fitHRF(fitParams, vN, scan, opt)
%
% Calcuates the average correlation error (negative) for a given voxel
% across all scans
%
% Inputs:
%   fitParams           A structure of parameter values for fitted function
%   vN                  Voxel number
%   scan                A structure containing information about the
%                       scan(s)
%   opt                 A structure containing options for pRF fitting
%
% Outputs:
%   err                 Mean (negative) cross-correlation across all scans
%
% Note:
% - This funciton is trying to maximizing the cross-correlation, but
%   because 'fminsearchcon' is a MINIZATION function, we add a - sign in
%   front of the cross-correlation to make it negative

% Written by Jessica Thomas - October 20, 2014
% Edited by Kelly Chang for pRF package - June 21, 2016

%% Fit pRF Model

corr = 0;
for i = 1:length(scan)
    scan(i).convStim = createConvStim(scan(i), fitParams);
    model = feval(opt.model, fitParams, scan(i).funcOf);
    pred = pos0(scan(i).convStim * model(:)) .^ fitParams.exp;
    
    tmp = callCorr(opt.corr, scan(i).vtc(:,vN), pred, scan(i));
    corr = corr + tmp;
end
err = -corr/length(scan); % mean (negative) cross correlation across all scans

if isfield(opt, 'cost') && ~isempty(opt.cost) && ~isempty(fieldnames(opt.cost))
    flds = fieldnames(opt.cost);
    for i = 1:length(flds)
        tmp(1) = (min(fitParams.(flds{i}), opt.cost.(flds{i})(1)) - opt.cost.(flds{i})(1)).^2;
        tmp(2) = (max(fitParams.(flds{i}), opt.cost.(flds{i})(2)) - opt.cost.(flds{i})(2)).^2;
        err = err + sum(tmp(~isnan(tmp)));
    end
end