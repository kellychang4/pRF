function [modelEstimateFit] = figure10(modelEstimate, modelEstimateNoise, fitParams, opt)

x = linspace(min(opt.stimuli)-1, max(opt.stimuli)+1, 1000);
modelEstimateFit = gaussian(fitParams.mu, fitParams.sigma, opt.stimuli);

figure(10); clf;
subplot(3,1,1); hold on;
plot(x, gaussian(opt.mu, opt.sigma, x), '--', 'Color', [0.5 0.5 0.5]);
for i = opt.stimuli; stem(i, modelEstimate(i), 'Color', opt.cMap(i,:)); end
ylabel('Neural Response');
title('Model Estimate without Noise');
set(gca, 'XTick', opt.stimuli, 'XLim', [min(opt.stimuli)-1 max(opt.stimuli)+1], ...
    'XTickLabel', arrayfun(@(x) sprintf('S%d',x), opt.stimuli, 'UniformOutput', false), ...
    'TickLength', [0 0], 'YLim', [0 1], 'YTick', [0 1]);

subplot(3,1,2); hold on;
plot(x, gaussian(3.55, 0.7, x), '--', 'Color', [0.5 0.5 0.5]);
for i = opt.stimuli; stem(i, modelEstimateNoise(i)/max(modelEstimateNoise), 'Color', opt.cMap(i,:)); end
ylabel('Neural Response');
title('Model Estimate with Noise');
set(gca, 'XTick', opt.stimuli, 'XLim', [min(opt.stimuli)-1 max(opt.stimuli)+1], ...
    'XTickLabel', arrayfun(@(x) sprintf('S%d',x), opt.stimuli, 'UniformOutput', false), ...
    'TickLength', [0 0], 'YLim', [-0.3 1], 'YTick', [-1 0 1]);

subplot(3,1,3); hold on;
plot(x, gaussian(fitParams.mu, fitParams.sigma, x), '--', 'Color', [0.5 0.5 0.5]);
for i = opt.stimuli; stem(i, modelEstimateFit(i)/max(modelEstimateFit), 'Color', opt.cMap(i,:)); end
ylabel('Neural Response');
title('Model Fit Estimate with Noise');
set(gca, 'XTick', opt.stimuli, 'XLim', [min(opt.stimuli)-1 max(opt.stimuli)+1], ...
    'XTickLabel', arrayfun(@(x) sprintf('S%d',x), opt.stimuli, 'UniformOutput', false), ...
    'TickLength', [0 0], 'YTick', [0 1]);