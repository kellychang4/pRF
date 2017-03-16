function [C] = cellzeros(C,matrixSize)

M = zeros(matrixSize);
for i = 1:numel(C)
    C{i} = M;
end