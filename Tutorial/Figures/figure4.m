function [stimulusImpulse] = figure4(stimulusMatrix, neural, opt)

figure(4); clf;
subplot('Position', [0.1 0.38 0.85 0.55]);
imagesc(stimulusMatrix);
ylabel('Stimuli');
title('Stimulus Matrix');
set(gca, 'XTick', '', 'YTick', 1:length(opt.stimuli), ...
    'YTickLabel', arrayfun(@(x) sprintf('S%d',x), 1:length(opt.stimuli), ...
    'UniformOutput', false));
colormap gray

indx = [(find(sum(stimulusMatrix))*opt.TR)-opt.TR; ...
    find(sum(stimulusMatrix))*opt.TR]';
t = linspace(0,opt.TR*opt.nVols,1000);
stimulusImpulse = zeros(length(t), length(opt.stimuli));
for i = 1:length(opt.stimuli)
    [~,tmp] = arrayfun(@(x) min((t-x).^2), indx(i,:));
    stimulusImpulse(tmp(1):tmp(2),i) = neural(i);
end

subplot('Position', [0.1 0.08 0.85 0.25]); hold on;
h = plot(t, stimulusImpulse);
xlabel('Time (s)');
ylabel('Neural Response');
set(h, {'Color'}, num2cell(opt.cMap,2));
set(gca, 'XLim', [0 opt.TR*opt.nVols], 'XTick', 0:opt.TR:(opt.TR*opt.nVols), ...
    'TickLength', [0 0], 'YTick', []);