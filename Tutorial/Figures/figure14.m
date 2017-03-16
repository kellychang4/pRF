function figure14(mu, sigma, voxelTuningFit)

fitMu = [voxelTuningFit.mu];
fitSigma = [voxelTuningFit.sigma];
fitCorr = [voxelTuningFit.corr];

err = corrcoef(fitMu(:), mu(:));
figure(14); clf; 
subplot('Position', [0.08 0.51 0.38 0.44]); hold on;
plot(mu, fitMu, '.', 'MarkerSize', 10);
plot([floor(min([mu;fitMu'])) ceil(max([mu;fitMu']))], ...
    [floor(min([mu;fitMu'])) ceil(max([mu;fitMu']))], 'Color', [0.75 0.75 0.75]);
xlabel('Actual \mu');
ylabel('Estimated \mu');
title(sprintf('\\mu Correlation: %5.4f', err(1,2)));
set(gca, 'XTick', floor(min([mu;fitMu'])):ceil(max([mu;fitMu'])), ...
    'YTick', floor(min([mu;fitMu'])):ceil(max([mu;fitMu'])), ...
    'XLim', [floor(min([mu;fitMu'])) ceil(max([mu;fitMu']))], ...
    'YLim', [floor(min([mu;fitMu'])) ceil(max([mu;fitMu']))]);

err = corrcoef(fitSigma(:), sigma(:));
subplot('Position', [0.57 0.51 0.38 0.44]); hold on;
plot(sigma, fitSigma, '.', 'MarkerSize', 10);
plot([floor(min([sigma;fitSigma'])) ceil(max([sigma;fitSigma']))], ...
    [floor(min([sigma;fitSigma'])) ceil(max([sigma;fitSigma']))], 'Color', [0.75 0.75 0.75]);
xlabel('Actual \sigma');
ylabel('Estimated \sigma');
title(sprintf('\\sigma Correlation: %5.4f', err(1,2)));
set(gca, 'XLim', [0 ceil(max([sigma;fitSigma']))], ...
    'YLim', [0 ceil(max([sigma;fitSigma']))], ...
    'XTick', 0:ceil(max([sigma;fitSigma'])), 'YTick', 0:ceil(max([sigma;fitSigma'])));

subplot('Position', [0.08 0.08 0.88 0.33]); hold on;
histogram(fitCorr, 0.6:0.01:1);
plot(repmat(mean(fitCorr),1,2), ylim, 'r', 'LineWidth', 2);
xlabel('Voxel-wise Goodness-of-Fits');
ylabel('Frequency');
title(sprintf('Mean Goodness-of-Fit: %5.2f', mean(fitCorr)));
set(gca, 'YTick', 0:ceil(max(get(gca,'YLim'))));