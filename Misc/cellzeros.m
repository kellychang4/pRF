function [C] = cellzeros(C, matrixSize)
% [C] = cellzeros(C, matrixSize)
%
% Assign matrices of zeros the size of 'matrixSize' into the cell array C.
% C can also be a vector for the size of the cell array.
% 
% Inputs: 
%   C                 A cell array to be filled with zeros or a vector
%                     specifying the cell array size
%   matrixSize        Matrix size for the zeros (default: [1 1])
%
% Output: 
%   C                 A cell array filled with matrices of zeros of size
%                     'matrixSize'

% Written by Kelly Chang - March 12, 2017

%% Input Control

if ~exist('C', 'var');
    error('Cell array must be provided');
end

if ~iscell(C) && isvector(C)
    C = cell(C);
end

if ~exist('matrixSize', 'var');
    matrixSize = [1 1];
end

%% Assign Zeros Matrix into Cell Array

M = zeros(matrixSize);
for i = 1:numel(C)
    C{i} = M;
end