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
% Edited by Kelly Chang - June 6, 2022

%% Input Control

[~,~,ext] = fileparts(labelFile);
if ~strcmp(ext, '.label')
    error('\nUnrecognized file extension: %s\nA .LABEL file must be provided', ext);
end

%% Open .LABEL File

fid = fopen(labelFile,'r');
data = textscan(fid, '%f%f%f%f%f\n', 'HeaderLines', 2);
fclose(fid); % close text file

%% Extract Vertex Indice and RAS Coodinates from .LABEL File

vertices = data{1}; % note: zero-based indexing!
ras = [data{2} data{3} data{4}]; % right-anterior-superior 

%% Only Return Unique Vertices 

[~,uIndx] = unique(vertices); % locate unique vertices
vertices = vertices(uIndx) + 1; % for matlab, one-based indexing
ras = ras(uIndx,:); % matching unique RAS coordinates