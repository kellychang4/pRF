function [vtc] = fullVTC(bc, normalize)
% [vtc] = fullVTC(bc, normalize)
% 
% Returns vtc with voxel indices and data for a voxel at throughout the
% entire time course
%
% Input:
%   bc              As given by bc = BVQXfile(vtcFileName)
%   normalize       Normalize vtc data: (vtc - mean(vtc)) / sd(vtc) (true) 
%                   OR not (false), logical (default: true)
%
% output:
%   vtc             A structure containing VTC indices and data with
%                   fields:
%       id          Indices of voxels in used for the vtc matrix
%       vtcData     Time course of VTC data (vtcData(:,roi.id))

% Written by Kelly Chang - May 24, 2016

%% Input Control

% if normalize does not exist, default = true
if ~exist('normalize', 'var')
    normalize = true;
end

%% Extract .vtc Data

% vtc data and size
vtcData = bc.VTCData;

% normalize vtc
if normalize
    vtcData = bsxfun(@minus, vtcData, mean(vtcData)); % subtract each voxel by its mean
    vtcData = bsxfun(@rdivide, vtcData, std(vtcData)); % normalize each voxel by its SD
end

% create voxel ids
id = 1:(size(vtcData(:))/size(vtcData,1));

% collect for output
vtc.id = id; 
vtc.vtcData = vtcData(:,id);