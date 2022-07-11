function figure13(stimulusMatrix, decodedStimulus, opt)

figure(13); clf;
subplot('Position', [0.1 0.53 0.85 0.4]);
imagesc(stimulusMatrix);
ylabel('Stimuli');
title('Actual Stimulus Matrix');
set(gca, 'XTick', [], 'YTick', opt.stimuli,  ...
    'YTickLabel', arrayfun(@(x) sprintf('S%d',x), 1:length(opt.stimuli), 'UniformOutput', false));

subplot('Position', [0.1 0.08 0.85 0.4]);
imagesc(decodedStimulus);
xlabel('Time (s)');
ylabel('Stimuli');
title('Decoded Stimulus Matrix');
colormap gray
set(gca, 'XTick', (0:(opt.TR*opt.nVols))+0.5, 'XTickLabel', 0:opt.TR:(opt.TR*opt.nVols), ...
    'YTickLabel', arrayfun(@(x) sprintf('S%d',x), 1:length(opt.stimuli), 'UniformOutput', false));