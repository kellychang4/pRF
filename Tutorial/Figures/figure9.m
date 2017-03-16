function [convolvedMatrix,responseMatrix] = figure9(stimulusMatrix, tuning, opt)

figure(9); clf;
subplot(4,1,1);
imagesc(stimulusMatrix);
ylabel('Stimuli');
title('Stimulus Matrix');
set(gca, 'XTick', [], 'YTick', 1:length(opt.stimuli), 'TickLength', [0 0], ...
    'YTickLabel', arrayfun(@(x) sprintf('S%d',x), 1:length(opt.stimuli), 'UniformOutput', false));
colormap gray

hrf = gammaHRF(opt.n, opt.tau, opt.delta, 0:opt.TR:30);
convolvedMatrix = convn(stimulusMatrix, hrf);
convolvedMatrix = convolvedMatrix(:,1:opt.nVols);
subplot(4,1,2);
imagesc(convolvedMatrix);
ylabel('Stimuli');
title('Stimulus Matrix \ast HRF');
set(gca, 'XTick', [], 'YTick', 1:length(opt.stimuli), 'TickLength', [0 0], ...
    'YTickLabel', arrayfun(@(x) sprintf('S%d',x), 1:length(opt.stimuli), 'UniformOutput', false));
colormap gray

responseMatrix = diag(tuning) * convolvedMatrix;
subplot(4,1,3);
imagesc(responseMatrix);
ylabel('Stimuli');
title('Neural Tuning x (Stimulus Matrix \ast HRF)');
set(gca, 'XTick', [], 'YTick', 1:length(opt.stimuli), 'TickLength', [0 0], ...
    'YTickLabel', arrayfun(@(x) sprintf('S%d',x), 1:length(opt.stimuli), 'UniformOutput', false));

subplot(4,1,4); hold on;
h = plot(0:opt.TR:((opt.TR*opt.nVols)-opt.TR), responseMatrix, '--');
plot(0:opt.TR:((opt.TR*opt.nVols)-opt.TR), sum(responseMatrix), 'o-', 'Color', [0.5 0.5 0.5]);
xlabel('Time (s)');
ylabel('Response');
title('Response');
set(h, {'Color'}, num2cell(opt.cMap,2));
set(gca, 'XLim', [0 opt.TR*opt.nVols], 'XTick', 0:opt.TR:(opt.TR*opt.nVols), 'TickLength', [0 0], ...
    'YTick', []);