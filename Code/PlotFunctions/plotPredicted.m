function [predicted] = plotPredicted(collated, nVox, nScan)
% [predicted] = plotPredicted(collated, nVox, nScan)
%
% Plot a figure with two subplots that depicts the PREDICTED (dashed red)
% vs. ACTUAL (grey) time course:
% (1) Predicted vs. Actual time course of a specified voxel across all
% scans (scans delineated with green vertical lines)
% (2) Predicted vs. Actual time course of a specified voxel in a specified
% scan (rests delineated with green vertical dotted lines)
%
% Inputs:
%   collated        A structure containing all fitted pRF information as
%                   as given by [collated] = estpRF(scan, seeds, hrf, opt)
%   nVox            Voxel index number to be plotted, numeric (default:
%                   random voxel from the fitted pRF estimates)
%   nScan           Scan index number to be plotted, numeric (default:
%                   random scan from all the scans available)
%
% Output:
%   predicted       A structure containing information about the actual and
%                   predicted time course of data estimated by the pRF 
%                   model (see predictpRF.m for more information)
%
% Examples:
% predicted = plotPredicted(collated);
% plotPredicted(collated, 5, 1); % plot 5th voxel from the 1st scan

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

btwScan = collated.scan(nScan).dur;
if length(collated.scan) > 1
    btwScan = (1:(length(collated.scan)-1))' .* collated.scan(nScan).dur;
end

actual = cat(1, predicted.tc);
pred = cat(1, predicted.pred);
t = lengthOut(0, collated.scan(1).TR, size(actual,1));

figure();
subplot(2,1,1); hold on;
plot(t, zscore(actual(:,nVox)), 'Color', [0.75 0.75 0.75]);
plot(t, zscore(pred(:,nVox)), 'r--');
plot(repmat(btwScan,1,2), ylim, 'g');
xlabel('Time (s)');
title(sprintf('Voxel %d (%d)', nVox, predicted(nScan).voxID(nVox)));
axis tight

%% Individual Scan

tPred = lengthOut(0, collated.scan(nScan).dur/size(predicted(nScan).pred(:,nVox),1), ...
    size(predicted(nScan).pred(:,nVox),1));

subplot(2,1,2); hold on;
plot(collated.scan(nScan).t, zscore(predicted(nScan).tc(:,nVox)), 'Color', [0.75 0.75 0.75]);
plot(tPred, zscore(predicted(nScan).pred(:,nVox)), 'r--');
if isfield(collated.scan(1), 'paradigm') % calculate breaks, paradigm method
    tmp = struct2cell(collated.scan(nScan).paradigm);
    breaks = asrow(find(any(isnan(cell2mat(asrow(tmp))),2)) * collated.scan(nScan).dt);
else % stimImg method 
    tmp = reshape(collated.scan(nScan).stimImg, size(collated.scan(nScan).stimImg,1), []);
    breaks = asrow(find(~any(tmp,2)) * collated.scan(nScan).dt);
end
plot(repmat(breaks,2,1), ylim, ':', 'Color', [0 .65 0]);
xlabel('Time (s)');
title(sprintf('Voxel %d (%d)\nScan %d', nVox, predicted(nScan).voxID(nVox), nScan));
axis tight