function [predicted,opt] = plotPredicted(collated, opt)
% [predicted,opt] = plotPredicted(collated, opt)
%
% Plots 2 figures with the PREDICTED (dashed red) vs. ACTUAL (grey) time
% course:
% (1) Predicted vs. Actual time course of a specified voxel across all
% scans (scans delinelted with green vertical lines)
% (2) Predicted vs. Actual time course of a specified voxel in a specified
% scan
%
% Inputs:
%   collated        A structure containing all fitted pRF information as
%                   as given by [collated] = estpRF(scan, seeds, hdr, opt)
%   opt             A structure containg options for the predicted vs.
%                   actual time course plots with fields:
%       voxel       Voxel index number to be plotted, numeric (default:
%                   random voxel from the fitted pRF estimates)
%       scan        Scan index number to be plotted, numeric (default:
%                   random scan from all the scans available)
%
% Outputs:
%   predicted       A structure containing information about the predicted
%                   time course of data estimated by the pRF model (see
%                   predictpRF.m for more information)
%   opt             The same 'opt' structure with additional fields filled
%                   in if previously empty

% Written by Kelly Chang - July 25, 2016

%% Input Control

if ~exist('opt', 'var')
    opt.voxel = [];
    opt.scan = [];
end

if ~isfield(opt, 'voxel') || isempty(opt.voxel)
    opt.voxel = randsample(find([collated.pRF.didFit]), 1);
end

if ~isfield(opt, 'scan') || isempty(opt.scan)
    opt.scan = randsample(length(collated.scan), 1);
end

%% Predicted Time Course

predicted = predictpRF(collated, collated.scan);

%% All Scans

btwScan = collated.scan(1).dur;
if length(collated.scan) > 1
    btwScan = (1:(length(collated.scan)-1))' .* collated.scan(1).dur;
end

allScans = cellfun(@(x) x(opt.voxel), struct2cell(predicted'));
actual = ascolumn([allScans.tc]);
pred = ascolumn([allScans.pred]);
t = lengthOut(0, collated.scan(1).TR, size(actual,1));

figure();
hold on;
plot(t, actual, 'Color', [0.75 0.75 0.75]);
plot(t, zscore(pred), 'r--');
plot(repmat(btwScan,1,2), ylim, 'g');
xlabel('Time (s)');
title(sprintf('Voxel %d (%d)', opt.voxel, predicted(opt.scan).vtc(opt.voxel).id));
axis tight

%% Individual Scan

breaks = asrow(find(isnan(collated.scan(opt.scan).paradigm)) * ...
    (collated.scan(opt.scan).dur/length(collated.scan(opt.scan).paradigm)));

figure();
hold on;
plot(collated.scan(opt.scan).t, predicted(opt.scan).vtc(opt.voxel).tc, 'Color', [0.75 0.75 0.75]);
plot(collated.scan(opt.scan).t, zscore(predicted(opt.scan).vtc(opt.voxel).pred), 'r--');
plot(repmat(breaks,2,1), ylim, ':', 'Color', [0 .65 0]);
xlabel('Time (s)');
title(sprintf('Voxel %d (%d)\nScan %d', opt.voxel, ...
    predicted(opt.scan).vtc(opt.voxel).id, opt.scan));
axis tight