function [scan] = create_brainvoyager_scan(boldFiles, roiFiles)
% [scan] = create_brainvoyager_scan(boldFiles, roiFiles)
% 
% Helpful function to createScan.m. Extracts the scan information from
% BrainVoyager .vtc files (boldFiles) within a given .voi ROI.
%
% Inputs: 
%   boldFiles           BOLD file nanes (.vtc), string
%   roiFiles            ROI file names (.voi), if empty string, 
%                       will extract full brain time courses, string.
%
% Output:
%   scan                A structure containing the provided scan 
%                       infromation as fields:
%       boldFile        Name of the BOLD data file (.vtc), string
%       boldSize        Size of the BOLD data in [nVolumes x y z] format, 
%                       numeric
%       nVols           Number of volumes, numeric
%       TR              Scan TR, seconds
%       dur             Total scan duration, seconds
%       t               Time vector of the scan in TRs, seconds
%       voxID           Voxel index number, numeric
%       vtc             Voxel time course in [nVolumes nVox] format,
%                       numeric
%
% Note:
% - Dependencies: <a href="matlab:
% web('http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html')">BVQXTools/NeuroElf</a>

% Written by Kelly Chang - July 19, 2017
% Edited by Kelly Chang - June 29, 2022

%% Extract Scan Information from .vtc (and .voi)

bold = xff(boldFiles); % load .vtc file
if ~all(cellfun(@isempty, roiFiles))
    vtc = []; % initialize vtc
    for i = 1:length(roiFiles)
        vtc = [vtc VTCinVOI(bold, xff(roiFiles{i}))];
    end
else
    vtc = fullVTC(bold);
end

[~,file,ext] = fileparts(boldFiles);
scan.boldFile = [file ext]; % name of bold data file
scan.boldSize = size(bold.VTCData); % size of the .vtc data
scan.nVols = bold.NrOfVolumes; % number of volumes in the scan
scan.TR = bold.TR/1000; % seconds
scan.dur = scan.nVols*scan.TR; % scan duration, seconds
scan.t = 0:scan.TR:(scan.dur-scan.TR); % time vector, seconds
scan.voxIndex = cat(1, vtc.index); % voxel index (functional space)
scan.voxID = cat(1, vtc.id); % voxel id number (linearized)
scan.vtc = cat(2, vtc.vtcData); % voxel time course