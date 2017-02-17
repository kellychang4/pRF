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
%   vtc             A structure containing VTC indices and data
%       id          Indices of voxels in used for the vtc matrix
%       tc          Time course of VTC data (vtcData(:,vtc.id))

% Written by Kelly Chang - May 24, 2016

%% Input Control

% if normalize does not exist, default = 1
if ~exist('normalize', 'var')
    normalize = 1;
end

%% Extract .vtc Data

% vtc data and size
vtcData = bc.VTCData;
vtcSize = size(vtcData);

% normalize vtc
if normalize
    vtcData = vtcData - repmat(mean(vtcData), vtcSize(1), 1); % subject each voxel by its mean
    vtcData = vtcData ./ repmat(std(vtcData), vtcSize(1), 1); % normalize each voxel by it SD
end

% create voxel ids
id = 1:(size(vtcData(:))/size(vtcData,1));

for i = id
    vtc(i).id = id(i);
    vtc(i).tc = vtcData(:,id(i));
end