function [scan] = create_gifti_scan(boldFile, roiFile, TR)
% [scan] = create_gifti_scan(boldFile, roiFile, TR)
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

%% Extract Scan Information from GIfTI File (and .label)

%%% read source bold data information
bold = gifti(boldFile); % load .gii file
tc = permute(bold.cdata, [2 1]); % reverse dimensions to [nt nv]
vertices = readLabels(roiFile);  % read label ROI file
[~,fname,ext] = extract_fileparts(boldFile);

%%% save scan information in 'scan' output
scan.boldFile = [fname ext]; % name of bold data file
scan.boldSize = size(tc); % size of the bold data
scan.t = (0:(size(tc,1)-1)) .* TR; % time vector, seconds
scan.vertex = vertices(:)'; % vertex indices
scan.vtc = tc(:,vertices); % extract time course of vertices