function figure7(convolvedMatrix, stimulusImpulse, opt)

figure(7); clf;
subplot('Position', [0.1 0.38 0.85 0.55]);
imagesc(convolvedMatrix);
ylabel('Stimuli');
title('Convolved: Stimulus Matrix \ast HRF');
set(gca, 'XTick', '', 'YTick', 1:length(opt.stimuli), ...
    'YTickLabel', arrayfun(@(x) sprintf('S%d',x), 1:length(opt.stimuli), 'UniformOutput', false));
colormap gray

t = linspace(0,opt.TR*opt.nVols,1000);
convolvedImpulse = convn(stimulusImpulse, gammaHRF(opt.n,opt.tau,opt.delta,t)');
convolvedImpulse = convolvedImpulse(1:length(t),:);
subplot('Position', [0.1 0.08 0.85 0.25]); hold on;
h = plot(t, convolvedImpulse, '--');
plot(t, sum(convolvedImpulse,2), 'Color', [0.25 0.25 0.25]);
xlabel('Time (s)');
ylabel('Voxel Response');
yLim = get(gca, 'YLim');
set(h, {'Color'}, num2cell(opt.cMap,2));
set(gca, 'XLim', [0 opt.TR*opt.nVols], 'XTick', 0:opt.TR:(opt.TR*opt.nVols), 'YTick', []);