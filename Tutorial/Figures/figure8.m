function figure8(stimulusMatrix, intensity, tuning, opt)

x = linspace(min(opt.stimuli)-1, max(opt.stimuli)+1, 1000);
indx = [(find(sum(stimulusMatrix))*opt.TR)-opt.TR; ...
    find(sum(stimulusMatrix))*opt.TR]';

t = linspace(0,opt.TR*opt.nVols,1000);
stimulusImpulse = zeros(length(t), length(opt.stimuli));
for i = 1:length(opt.stimuli)
    [~,tmp] = arrayfun(@(x) min((t-x).^2), indx(i,:));
    stimulusImpulse(tmp(1):tmp(2),i) = intensity(i);
end

figure(8); clf;
subplot(2,2,1);
h = plot(t, stimulusImpulse);
xlabel('Time (s)');
ylabel('Neural Response');
set(h, {'Color'}, num2cell(opt.cMap,2));
set(gca, 'XLim', [0 opt.TR*opt.nVols], 'XTick', 0:(opt.TR*2):(opt.TR*opt.nVols), ...
    'TickLength', [0 0], 'YTick', []);

step = repmat(0.5, size(x));
step(x <= 3) = 1;
subplot(2,2,2); hold on;
for i = opt.stimuli; stem(i, intensity(i), 'Color', opt.cMap(i,:)); end
plot(x, step, '--', 'Color', [0.5 0.5 0.5]);
xlabel('Stimuli');
set(gca, 'XTick', opt.stimuli, 'XLim', [min(opt.stimuli)-1 max(opt.stimuli)+1], ...
    'XTickLabel', arrayfun(@(x) sprintf('S%d',x), opt.stimuli, 'UniformOutput', false), ...
    'TickLength', [0 0], 'YTick', []);

stimulusImpulse = zeros(length(t), length(opt.stimuli));
for i = 1:length(opt.stimuli)
    [~,tmp] = arrayfun(@(x) min((t-x).^2), indx(i,:));
    stimulusImpulse(tmp(1):tmp(2),i) = tuning(i);
end

subplot(2,2,3);
h = plot(t, stimulusImpulse);
xlabel('Time (s)');
ylabel('Neural Response');
set(h, {'Color'}, num2cell(opt.cMap,2));
set(gca, 'XLim', [0 opt.TR*opt.nVols], 'XTick', 0:(opt.TR*2):(opt.TR*opt.nVols), ...
    'TickLength', [0 0], 'YTick', []);

subplot(2,2,4); hold on;
plot(x, gaussian(opt.mu, opt.sigma, x), '--', 'Color', [0.5 0.5 0.5]);
for i = opt.stimuli; stem(i, tuning(i), 'Color', opt.cMap(i,:)); end
xlabel('Stimuli');
set(gca, 'XTick', opt.stimuli, 'XLim', [min(opt.stimuli)-1 max(opt.stimuli)+1], ...
    'XTickLabel', arrayfun(@(x) sprintf('S%d',x), opt.stimuli, 'UniformOutput', false), ...
    'TickLength', [0 0], 'YTick', []);