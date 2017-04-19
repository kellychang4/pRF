function [vtc] = unpackROI(roi)
% [vtc] = unpackROI(roi)
%
% Helper function to be used with 'VTCinVOI.m' to unpack vtc indices and
% data into a structure 'vtc' where each instance is the voxel index number 
% and the time course of the voxel is in a column format
% 
% Input:
%   roi             As given by roi = VTcinVOI(bc, voi, ...)
%
% Output:
%   vtc             A structure containing the voxel time course indices 
%                   and data with fields:
%       id          Linear indices of voi used for the vtc matrix
%       tc          VTC data of the given voxel 'id' in a column
% 
% Note:
% - Dependencies: <a href="matlab: web('http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html')">BVQXTools/NeuroElf</a>

% Written by Kelly Chang - May 10, 2016

%% Unpacking ROI

count = 0;
for i = 1:length(roi)
    for i2 = 1:length(roi(i).id)
        count = count + 1;
        vtc(count).id = roi(i).id(i2);
        vtc(count).tc = roi(i).vtcData(:,i2);
    end
end