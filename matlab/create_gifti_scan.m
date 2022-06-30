function [scan] = createGIfTiScan(boldPath, roiPath, TR)
% [scan] = createGIfTiScan(boldPath, roiPath)
%
% Helpful function for createScan. Extracts the scan information from
% FreeSurfer .gii files (boldPath) within a given .label ROI.
%
% Inputs: 
%   boldPath            Path to BOLD information (.gii), string
%   roiPath             Path to ROI information (.label), if empty string, 
%                       will extract full brain time courses, string.
%   TR                  Time to repetition of BOLD file, seconds
% 
% Output:
%   scan                A structure containing the provided scan 
%                       infromation as fields:
%       boldFile        Name of the BOLD data file (.gii), string
%       boldSize        Size of the BOLD data in [nVolumes nVertices], 
%                       numeric
%       nVols           Number of volumes, numeric
%       TR              Scan TR, seconds
%       dur             Total scan duration, seconds
%       t               Time vector of the scan in TRs, seconds
%       vertex          Vertex index number, numeric
%       vtc             Voxel time course in [nVolumes nVox] format,
%                       numeric
%
% Dependencies: 
% - <a href="matlab: web('https://surfer.nmr.mgh.harvard.edu/fswiki/rel7downloads')">FreeSurfer</a>
% - <a href="matlab: web('https://www.artefact.tk/software/matlab/gifti/')">GIfTI Library</a>

% Written by Kelly Chang - June 6, 2022

%% Extract Scan Information from .g (and .label)

bold = gifti(boldPath); % load .gii file
tc = permute(bold.cdata, [2 1]); % reverse dimensions
scan.boldSize = size(tc); % size of the bold data

if ~all(cellfun(@isempty, roiPath))
    vertices = [];
    for i = 1:length(roiPath) % for each roi
        vertices = [vertices readLabels(roiPath{i})']; % read .label file
    end
else
    vertices = 1:size(tc,2); % select all vertices
end

[~,fname,ext] = fileparts(boldPath);
scan.boldFile = [fname ext]; % name of bold data file
scan.nVols = size(tc,1); % number of volumes in the scan
scan.TR = TR; % seconds
scan.dur = scan.nVols .* scan.TR; % scan duration, seconds
scan.t = 0:scan.TR:(scan.dur-scan.TR); % time vector, seconds
scan.vertex = vertices; % vertex indices
scan.vtc = tc(:,vertices); % extract time course of vertices