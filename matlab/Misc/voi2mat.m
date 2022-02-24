function [roi] = voi2mat(voiPath, vtcPath)
% [roi] = voi2mat(voiPath, vtcPath)
%
% Converts BrainVoyager QX .voi ROI linear indices into a .mat file. The
% linear indices are in reference to the given BrainVoyager .vtc file. The
% saved .mat file will bear the same name as the original .voi file.
% 
% Inputs: 
%   voiPath              Path to .voi file, string
%   vtcPath              Path to reference .vtc file, string
% 
% Output:
%   roi                  Structure containing the roi indices
%
% Notes:
% - Dependencies: <a href="matlab: web('http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html')">BVQXTools/NeuroElf</a>

% Written by Kelly Chang - November 30, 2016

%% Convert .VOI to .MAT

[roiPath,saveName] = fileparts(voiPath);
saveName = [saveName '.mat'];

roi = rmfield(VTCinVOI(BVQXfile(vtcPath), BVQXfile(voiPath)), 'vtcData');

save(fullfile(roiPath, saveName), 'roi');
fprintf('Saved As: %s\n', saveName);