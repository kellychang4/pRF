function figure16(decodeMatrix, opt)

opt.nVols = size(decodeMatrix,2)/opt.nStim;
opt.nVox = size(decodeMatrix,1)/opt.nVols;

f = figure(16);
clickVox = f.UserData;
if isempty(clickVox) || iscell(clickVox); clickVox = [0 15*opt.nVols]; end;
clickVox = ceil(clickVox(2) / opt.nVols);
set(f,'UserData', {'figure16', {decodeMatrix, opt}});

subplot('Position', [0.08 0.25 0.88 0.7]); hold on;
imagesc(decodeMatrix, 'ButtonDownFcn', @graphChange);
plot([0; opt.nStim*opt.nVols], repmat((opt.nVols+1):opt.nVols:(opt.nVols*opt.nVox),2,1), ...
    ':', 'Color', [0.5 0.5 0.5]); % rows
plot(repmat((opt.nStim+0.5):opt.nStim:(opt.nStim*opt.nVols),2,1), [0; opt.nVox*opt.nVols], ...
    ':', 'Color', [0.5 0.5 0.5]); % column
plot([0; opt.nStim*opt.nVols+0.5], repmat(([clickVox-1 clickVox]*opt.nVols)+0.5,2,1), 'r', 'LineWidth', 2);
ylabel('Voxels through Time');
title('Convolved: Decoding Matrix \ast HRF');
colormap gray
set(gca, 'YDir', 'reverse', 'YLim', [0.5 opt.nVox*opt.nVols], 'XLim', [0.5 (opt.nStim*opt.nVols)+0.5], ...
    'XTick', [], 'YTick', ((1+opt.nVols)/2):opt.nVols:(opt.nVols*opt.nVox), ...
    'YTickLabel', arrayfun(@(x) sprintf('Vox%d',x), 1:opt.nVox, 'UniformOutput', false));

subplot('Position', [0.08 0.06 0.88 0.15]); hold on;
imagesc(decodeMatrix((((clickVox-1)*opt.nVols)+1):(clickVox*opt.nVols),:));
plot(repmat((opt.nStim+0.5):opt.nStim:(opt.nStim*opt.nVols),2,1), [0; opt.nVols], ':', 'Color', [0.5 0.5 0.5]);
xlabel('Model Stimuli Response through Time');
ylabel('Time (s)');
set(gca, 'XLim', [0.5 (opt.nStim*opt.nVols)+0.5], 'YDir', 'reverse', 'YLim', [0.5 opt.nVols+0.5], ...
    'YTick', 0.5:2:(opt.nVols+0.5), 'YTickLabel', 0:(opt.TR*2):((opt.TR*opt.nVols)+opt.TR), 'XTick', []);