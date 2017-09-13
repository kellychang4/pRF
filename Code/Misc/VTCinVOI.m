function [roi] = VTCinVOI(vtc, voi, voiNum, normalize)
% [roi] = VTCinVOI(vtc, voi, voiNum, normalize)
%
% Extracts .VTC time courses within the specified .VOI region
%
% Input:
%   vtc             As given by vtc = BVQXfile(vtcPath)
%   voi             As given by voi = BVQXfile(voiPath)
%   voiNum          Index number (or range) of the voi(s) to be indexed 
%                   (default: 1:length(voi.VOI))
%   normalize       Normalize vtc data: (vtc - mean(vtc)) / sd(vtc) (true) 
%                   OR not (false), logical (default: true)
%
% Output:
%   roi             A structure containing VTC indices and data
%       id          Linear indices of voi used for the vtc matrix
%       vtcData     VTC data within the VOI (vtcData(:,roi.id))
%
% Note:
% - Use [x,y,z] = ind2sub(vtcSize(2:end), roi.id) to transform from linear
%   indices into 3D indices
% - Dependencies: <a href="matlab: web('http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html')">BVQXTools/NeuroElf</a>

% Stolen primarily from vtc_VOITimeCourse from BVQXtools_v08b
% Modified from getVOIcoordinates from Paola 20 Sep 2010
% Edited by Kelly Chang - April 19, 2016

%% Input Control

% if voiNum does not exist, default = 1:length(voi.VOI)
if ~exist('voiNum', 'var')
    voiNum = 1:length(voi.VOI);
end

% if normalize does not exist, default = true
if ~exist('normalize', 'var')
    normalize = true;
end

%% Extract .vtc Data Located within .voi Space

% vtc size and relative position (offset) within vmr volume
vtcData = vtc.VTCData;
vtcSize = size(vtcData);
vtcOffset = [vtc.XStart vtc.YStart vtc.ZStart];

% normalize vtc
if normalize
    vtcData = bsxfun(@minus, vtcData, mean(vtcData)); % subtract each voxel by its mean
    vtcData = bsxfun(@rdivide, vtcData, std(vtcData)); % normalize each voxel by its SD
end

for i = voiNum
    % voi coordinates in anatomical resolution
    v = voi.BVCoords(i);
    
    % convert voi coordinates to vtc coordinates and resolution
    v = round(bsxfun(@minus, v, vtcOffset)/vtc.Resolution) + 1;
    
    % take only voi voxels inside the vtc volume
    indx = (v(:,1) > 0 & v(:,1) <= vtcSize(2) & ...
            v(:,2) > 0 & v(:,2) <= vtcSize(3) & ...
            v(:,3) > 0 & v(:,3) <= vtcSize(4));
    v = v(indx,:);
    
    % transform voi [x y z] coordinates into linear index equivalents
    v = sub2ind(vtcSize(2:end), v(:,1), v(:,2), v(:,3));
    
    % name of the roi
    roi(i).name = voi.VOI(i).Name;
    
    % only keep the unique indices
    roi(i).id = unique(v)';
    
    % reshape vtc data into linear space
    vtcData = reshape(vtcData, [vtcSize(1) prod(vtcSize(2:end))]);
    
    % take only vtc data inside voi voxels in linear space
    roi(i).vtcData = vtcData(:,roi(i).id);
end