function [fittedParams] = callFitHRF(fitParams, scan, opt)
% [fittedParams] = callFitMdodel(fitParams, scan, opt)
%
% Returns a structure containing the best fitting parameters after an
% iterative HRF and pRF fitting.
%
% The HRF fitting process only takes the voxels that have passed the 
% specified correlation threshold 'opt.hrfThr' and/or are apart of the top 
% fitting percentage 'opt.topHRF'. 
%
% While holding the pRF parameters constant, the HRF free parameters are
% fitted. Then the estimated HRF parameters are held constant, the pRF 
% parameters are fitted again. This process repeats for the specified 
% 'opt.estHRF' iterations.
%
% Inputs:
%   fitParams       A structure of parameter values of HRF and pRF that are
%                   to be fitted as fields
%   scan            A structure containing all scan(s) information
%   opt             A structure containing options for the model fitting
%
% Output:
%   fittedParams    A structure with the best fitting parameters from  
%                   fitting the HRF and pRF model.

% Written by Kelly Chang - February 2, 2017

%% Calculating Voxel Thresholding Method 

indx = false(2, length(fitParams));
if ~isnan(opt.topHRF) % top percentage hrf voxels
    n = floor(length(fitParams) * opt.topHRF);
    [~,id] = sort([fitParams.corr], 'descend');
    indx(1,id(1:n)) = true;
end

if ~isnan(opt.hrfThr) % thresholded hrf voxels
    indx(2,:) = [fitParams.corr] > opt.hrfThr;
end

if ~isnan(opt.topHRF) && ~isnan(opt.hrfThr)
    indx = all(indx);
else
    indx = any(indx);
end

%% Fitting HRF (if Voxel Surpassed Thresholds)

if sum(indx) < 1
    warning('Cannot complete HRF fitting as no voxels surpassed thresholds');
    fittedParams = fitParams;
else
    % Select Voxels that Surpassed HRF Thresholds
    
    fprintf('%d voxels were selected for HRF fitting\n', sum(indx));
    freeListHRF = fitParams(1).freeList;
    fitParams = fitParams(indx);
    for i = 1:length(scan)
        scan(i).voxID = scan(i).voxID(indx);
        scan(i).vtc = scan(i).vtc(:,indx);
    end
    barName = sprintf('Estimating HRF (%d voxels, %s): %s', ...
        sum(indx), '%d', strjoin(freeListHRF, ' & '));
    
    %% Fitting HRF
    
    fittedParams = fitParams;
    for i = 1:opt.estHRF
        fprintf('HRF Fitting Iteration %d of %d\n',  i, opt.estHRF);
        parfor nV = 1:sum(indx) % for each voxel
            if ~opt.quiet && opt.parallel
                parallelProgressBar(sum(indx), sprintf(barName,i));
            elseif ~opt.quiet && mod(nV,floor(sum(indx)/10)) == 0 % display voxel count every 100 voxels
                fprintf('Fitting HRF: Voxel %d of %d\n', nV, sum(indx));
            end
            fittedParams(nV) = fitcon('fitHRF', fittedParams(nV), ...
                freeListHRF, nV, scan, opt);
        end
        if ~opt.quiet && opt.parallel % clean up parallel progress bar
            parallelProgressBar(-1, sprintf(barName,i));
        end
        for i2 = 1:length(fittedParams)   
            for i3 = 1:length(freeListHRF)
                fittedParams(i2).(freeListHRF{i3}) = median([fittedParams.(freeListHRF{i3})], 'omitnan');
            end
        end
        if i ~= opt.estHRF % not the last hrf fitting iteration
            fittedParams = callFitModel(fittedParams, opt.freeList, scan, opt);
        end
    end
end