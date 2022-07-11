function [scan] = create_brainvoyager_scan(boldFile, roiFile)
% [scan] = create_brainvoyager_scan(boldFile, roiFile)
% 
% Helpful function to createScan.m. Extracts the scan information from
% BrainVoyager .vtc files (boldFile) within a given .voi ROI.
%
% Inputs: 
%   boldFile            BOLD file name (.vtc), string
%   roiFile             ROI file name (.voi), string.
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
%       voxel           Voxel index number, numeric
%       vtc             Voxel time course in [nVolumes nVox] format,
%                       numeric
%
% Note:
% - Dependencies: <a href="matlab:
% web('http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html')">BVQXTools/NeuroElf</a>

% Written by Kelly Chang - July 19, 2017
% Edited by Kelly Chang - June 29, 2022

%% Extract Scan Information from .vtc (and .voi)

bold = xff(boldFile); roi = xff(roiFile); 
vtc = VTCinVOI(bold, roi); 

scan.boldFile = filename(boldFile); % name of bold data file
scan.boldSize = size(bold.VTCData); % size of the .vtc data
scan.nVols = bold.NrOfVolumes; % number of volumes in the scan
scan.TR = bold.TR/1000; % seconds
scan.dur = scan.nVols*scan.TR; % scan duration, seconds
scan.t = 0:scan.TR:(scan.dur-scan.TR); % time vector, seconds
scan.voxIndex = cat(1, vtc.index); % voxel index (functional space)
scan.voxID = cat(1, vtc.id); % voxel id number (linearized)
scan.vtc = cat(2, vtc.vtcData); % voxel time course