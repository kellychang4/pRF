function [C] = celldiag(C,M)

if ~all(size(C) == size(C,1))
    error('Dimensions of cell different');
end

cellClass = strcmp(cellfun(@class, C, 'UniformOutput', false), class(C{1}));
if ~all(cellClass(:))
    error('Class types inconsisntent throughout cell array');
end

cellSize = size(C,1);
for i = 1:cellSize
    C{i,i} = M;
end