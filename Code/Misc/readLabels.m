function [vertices,ras] = readLabels(labelFile)
% [vertices,ras] = readLabels(labelFile)
%
% Reads a FreeSurfer .label file and returns unique vertices and the RAS
% ("right-anterior-superior") spatial coordinates
%
% Input: 
%   fileName           Name of the .label file, string
%
% Outputs:
%   vertices           Unique vertices in .label file, numeric
%   ras                A N x 3 matrix containing the RAS spatial
%                      coordinates in each column respectively, numeric

% Written by Ione Fine - December 27, 2015
% Edited by Kelly Chang - June 20, 2017

%% Input Control

[~,~,ext] = fileparts(labelFile);
if ~strcmp(ext, '.label')
    error('\nUnrecognized file extension: %s\nA .LABEL file must be provided', ext);
end

%% Open .label File

fid = fopen(labelFile,'r');
data = textscan(fid, '%f%f%f%f%f\n', 'HeaderLines', 2);
fclose(fid); % close text file

%% Collect .label Data

vertices = data{1}; % note: zero-based indexing!
ras = [data{2} data{3} data{4}]; % right-anterior-superior 

%% Extract the Unique Vertices

[ras,indx] = unique(round(ras), 'rows'); % find unique vertices
vertices = vertices(indx); % unique vertices, zero based indexing