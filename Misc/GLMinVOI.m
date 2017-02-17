function [b] = GLMinVOI(glm, voi, voiNum)
% [beta] = GLMinVOI(glm, voi [,voiNum])
%
% Inputs:
%   glm             As given by glm = BVQXfile(glmFileName)
%   voi             As given by voi = BVQXfile(voiFileName)
%   voiNum          Index number (or range) of the voi(s) to be indexed 
%                   (default: 1:length(voi.VOI))
% 
% Output:
%   b              A structure containing glm indices and data
%       id         Linear indices of voi used for the glm matrix
%       beta       A [nVoxel nPredictors] matrix of beta weights within the 
%                  roi

% Written by Kelly Chang - October 10, 2016

%% Input Control

if ~exist('voiNum', 'var')
    voiNum = 1:length(voi.VOI);
end

%% Start Extracting Beta Weights

% glm size and relative position (offset) within vmr volume
glmData = glm.GLMData.BetaMaps;
glmSize = size(glmData);
glmOffset = [glm.XStart glm.YStart glm.ZStart];

for i = voiNum
    % voi coordinates in anatomical resolution
    v = voi.BVCoords(i);
    
    % convert voi coordinates to vtc coordinates and resolution
    v = round((v - repmat(glmOffset, size(v,1), 1))/glm.Resolution) + 1;
    
    % take only voi voxels inside the vtc volume
    indx = (v(:,1) > 0 & v(:,1) <= glmSize(1) & ...
            v(:,2) > 0 & v(:,2) <= glmSize(2) & ...
            v(:,3) > 0 & v(:,3) <= glmSize(3));
    v = v(indx,:);
    
    % transform voi [x y z] coordinates into linear index equivalents
    v = sub2ind(glmSize(1:3), v(:,1), v(:,2), v(:,3));
    
    % name of the roi
    b(i).name = voi.VOI(i).Name;
    
    % only keep the unique indices
    b(i).id = unique(v);
    
    % reshape vtc data into linear space
    glmData = reshape(glmData, [prod(glmSize(1:3)) glmSize(4)]);
    
    % take only vtc data inside voi voxels in linear space
    b(i).beta = glmData(b(i).id,:);
end