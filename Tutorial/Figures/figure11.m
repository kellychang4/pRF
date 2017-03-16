function figure11(decodeMatrix, fitParams, opt)

x = linspace(min(opt.stimuli)-1, max(opt.stimuli)+1, 1000);
modelEstimateFit = gaussian(fitParams.mu, fitParams.sigma, opt.stimuli);

figure(11); clf;
subplot('Position', [0.08 0.55 0.2 0.4]);
imagesc(decodeMatrix(7,((6*opt.nStim)+1):(7*opt.nStim)));
ylabel('Neural Response');
title('Model Fit Estimates');
set(gca, 'XTick', opt.stimuli, 'YTick', [], ...
    'XTickLabel', arrayfun(@(x) sprintf('S%d',x), opt.stimuli, 'UniformOutput', false));

subplot('Position', [0.08 0.08 0.2 0.4]); hold on;
plot(x, gaussian(fitParams.mu, fitParams.sigma, x), '--', 'Color', [0.5 0.5 0.5]);
for i = opt.stimuli; stem(i, modelEstimateFit(i)/max(modelEstimateFit), 'Color', opt.cMap(i,:)); end
xlabel('Stimuli');
ylabel('Neural Response');
set(gca, 'XTick', opt.stimuli, 'XLim', [min(opt.stimuli)-0.5 max(opt.stimuli)+0.5], ...
    'XTickLabel', arrayfun(@(x) sprintf('S%d',x), opt.stimuli, 'UniformOutput', false), ...
    'TickLength', [0 0], 'YTick', []);

subplot('Position', [0.35 0.08 0.63 0.87]); hold on;
imagesc(decodeMatrix);
plot(repmat((opt.nStim+0.5):opt.nStim:(opt.nStim*opt.nVols),2,1), [0.5; opt.nVols+0.5], ':', 'Color', [0.5 0.5 0.5]);
plot([0 opt.nVols*opt.nStim], repmat(1.5:(opt.nVols-0.5),2,1), ':', 'Color', [0.5 0.5 0.5]);
plot(repmat([6*opt.nStim 7*opt.nStim]+0.5,2,1), [6; 7]+0.5, 'r', 'LineWidth', 2);
plot(([6; 7]*opt.nStim)+0.5, repmat([6 7]+0.5,2,1), 'r', 'LineWidth', 2);
title('Decoding Matrix');
xlabel('Model Stimuli Response through Time');
ylabel('Time (s)');
set(gca, 'XLim', [0.5 108], 'XTick', [],  ...
    'YLim', [0.5 opt.nVols+0.5], 'YDir', 'reverse', ...
    'YTick', 0.5:(opt.nVols+0.5), 'YTickLabel', 0:opt.TR:((opt.TR*opt.nVols)+opt.TR));
colormap gray
