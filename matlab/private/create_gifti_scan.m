function [scan] = create_gifti_scan(boldFile, roiFile, TR)
% [scan] = create_gifti_scan(boldFile, roiFile, TR)
%
% Dependencies: 
% - <a href="matlab: web('https://www.artefact.tk/software/matlab/gifti/')">GIfTI Library</a>

% Written by Kelly Chang - June 6, 2022

%% Extract Scan Information from GIfTI File (and .label)

%%% read source bold data information
bold = gifti(boldFile); % load .gii file
tc = permute(bold.cdata, [2 1]); % reverse dimensions to [nt nv]
vertices = readLabels(roiFile);  % read label ROI file

%%% save scan information in 'scan' output
scan.file = filename(boldFile); % name of bold data file
scan.size = size(tc); % size of the bold data
scan.dt = TR; % repetition time, seconds
scan.t = (0:(size(tc,1)-1)) .* scan.dt; % time vector, seconds
scan.vertex = vertices(:)'; % vertex indices
scan.vtc = tc(:,vertices); % extract time course of vertices