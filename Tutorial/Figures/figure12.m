function figure12(decodeMatrix, opt)

f = figure(12);
clickModel = f.UserData;
if isempty(clickModel) || iscell(clickModel); clickModel = [7*opt.nStim 0]; end;
clickModel = ceil(clickModel(1) / opt.nStim);
set(f, 'UserData', {'figure12', {decodeMatrix, opt}});

subplot('Position', [0.08 0.08 0.2 0.87]); hold on;
imagesc(decodeMatrix(:,(((clickModel-1)*opt.nStim)+1):(clickModel*opt.nStim)));
plot([0 opt.nVols*opt.nStim], repmat(1.5:(opt.nVols-0.5),2,1), ':', 'Color', [0.5 0.5 0.5]);
xlabel('Stimuli');
ylabel('Time (s)');
set(gca, 'XLim', [0.5 opt.nStim+0.5], 'YLim', [0.5 opt.nVols+0.5], ...
    'XTick', opt.stimuli, 'YTick', [], 'YDir', 'reverse', ...
    'YTick', 0.5:(opt.nVols+0.5), 'YTickLabel', 0:opt.TR:((opt.TR*opt.nVols)+opt.TR), ...
    'XTickLabel', arrayfun(@(x) sprintf('S%d',x), opt.stimuli, 'UniformOutput', false));

subplot('Position', [0.35 0.08 0.63 0.87]); hold on;
imagesc(decodeMatrix, 'ButtonDownFcn', @graphChange);
plot(repmat((opt.nStim+0.5):opt.nStim:(opt.nStim*opt.nVols),2,1), ...
    [0.5; opt.nVols+0.5], ':', 'Color', [0.5 0.5 0.5]);
plot([0 opt.nVols*opt.nStim], repmat(1.5:(opt.nVols-0.5),2,1), ':', ...
    'Color', [0.5 0.5 0.5]);
plot(repmat(([(clickModel-1) clickModel]*opt.nStim)+0.5,2,1), ...
    [0; opt.nVols+0.5], 'r', 'LineWidth', 2);
title('Convolved: Decoding Matrix \ast HRF');
xlabel('Model Stimuli Response through Time');
ylabel('Time (s)');
set(gca, 'XLim', [0.5 108], 'XTick', [], ...
    'XTickLabel', arrayfun(@(x) sprintf('V%d',x), 1:opt.nVols, 'UniformOutput', false), ...
    'YLim', [0.5 opt.nVols+0.5], 'YDir', 'reverse', ...
    'YTick', 0.5:(opt.nVols+0.5), 'YTickLabel', 0:opt.TR:((opt.TR*opt.nVols)+opt.TR));
colormap gray