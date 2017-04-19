function [predicted] = plotPredicted(collated, nVox, nScan)
% [predicted] = plotPredicted(collated, opt)
%
% Plot 2 figures with the PREDICTED (dashed red) vs. ACTUAL (grey) time
% course:
% (1) Predicted vs. Actual time course of a specified voxel across all
% scans (scans delinelted with green vertical lines)
% (2) Predicted vs. Actual time course of a specified voxel in a specified
% scan
%
% Inputs:
%   collated        A structure containing all fitted pRF information as
%                   as given by [collated] = estpRF(scan, seeds, hrf, opt)
%   nVox            Voxel index number to be plotted, numeric (default:
%                   random voxel from the fitted pRF estimates)
%   nScan           Scan index number to be plotted, numeric (default:
%                   random scan from all the scans available)
%
% Outputs:
%   predicted       A structure containing information about the predicted
%                   time course of data estimated by the pRF model (see
%                   predictpRF.m for more information)

% Written by Kelly Chang - July 25, 2016

%% Input Control

if ~exist('nVox', 'var') || isempty(nVox)
    nVox = randsample(find([collated.pRF.didFit]), 1);
end

if ~exist('nScan', 'var') || isempty(nScan)
    nScan = randsample(length(collated.scan), 1);
end

%% Predicted Time Course

predicted = predictpRF(collated, collated.scan);

%% All Scans

btwScan = collated.scan(1).dur;
if length(collated.scan) > 1
    btwScan = (1:(length(collated.scan)-1))' .* collated.scan(1).dur;
end

allScans = cellfun(@(x) x(nVox), struct2cell(predicted'));
actual = cat(1,allScans.tc);
pred = cat(1,allScans.pred);
t = lengthOut(0, collated.scan(1).TR, size(actual,1));

figure();
subplot(2,1,1); hold on;
plot(t, zscore(actual), 'Color', [0.75 0.75 0.75]);
plot(t, zscore(pred), 'r--');
plot(repmat(btwScan,1,2), ylim, 'g');
xlabel('Time (s)');
title(sprintf('Voxel %d (%d)', nVox, predicted(nScan).vtc(nVox).id));
axis tight

%% Individual Scan

tPred = lengthOut(0, collated.scan(nScan).dur/size(predicted(nScan).vtc(nVox).pred,1), ...
    size(predicted(nScan).vtc(nVox).pred,1));

subplot(2,1,2); hold on;
plot(collated.scan(nScan).t, zscore(predicted(nScan).vtc(nVox).tc), 'Color', [0.75 0.75 0.75]);
plot(tPred, zscore(predicted(nScan).vtc(nVox).pred), 'r--');
if isfield(collated.scan(1), 'paradigm')
    paramNames = eval(collated.opt.model);
    breaks = asrow(find(isnan(collated.scan(nScan).paradigm.(paramNames.funcOf{1}))) * ...
        (collated.scan(nScan).dur/length(collated.scan(nScan).paradigm.(paramNames.funcOf{1}))));
    plot(repmat(breaks,2,1), ylim, ':', 'Color', [0 .65 0]);
end
xlabel('Time (s)');
title(sprintf('Voxel %d (%d)\nScan %d', nVox, ...
    predicted(nScan).vtc(nVox).id, nScan));
axis tight