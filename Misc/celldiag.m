function [C] = celldiag(C,M)
% [C] = celldiag(C, M)
%
% Assigns or extracts the diagonal of cell array C. 
%
% Inputs:
%   C          Cell array to assign or extract from, must be square in
%              dimension
%   M          Matrix to be assigned along the diagonal if passed, optional
%
% Output:
%   C          Cell array with diagonal assigned to be M if passed or a
%              cell array of the diagonal elements extracted

% Written by Kelly Chang - March 12, 2017

%% Input Control

if ~all(size(C) == size(C,1))
    error('Cell array is not a square');
end

cellClass = strcmp(cellfun(@class, C, 'UniformOutput', false), class(C{1}));
if ~all(cellClass(:))
    error('Class types inconsisntent throughout cell array');
end

%% Assign / Extract Diagonal of Cell Array

cellSize = size(C,1);
if exist('M', 'var'); % assign M along diagonal of cell
    for i = 1:cellSize
        C{i,i} = M;
    end
else % extract diagonal of cell
    oldC = C;
    C = cell(cellSize,1);
    for i = 1:cellSize
        C{i} = oldC{i,i};
    end
end