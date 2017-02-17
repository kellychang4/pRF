function [olt] = createOlt(opt)
% [olt] = createOlt(opt)
%
% Creates a .olt file with 'n' colors, compatiable with BrainVoyager QX
%
% Input:
%   opt                 A structure containing options to create the .olt 
%                       file with fields:
%       n               Number of colors, numeric (default: 20)
%       saveName        Name the .olt file will be saved as, string
%                       (default: 'olt<n>.olt')
% 
% Output:
%   olt                 A structure containing information of the created 
%                       .olt file
% 
% Note:
% - Dependencies: <a href="matlab: web('http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html')">BVQXTools/NeuroElf</a>

% Written by Kelly Chang - August 9, 2016

%% Input Control

if ~exist('opt', 'var')
    opt = struct();
end

if ~isfield(opt, 'n');
    opt.n = 20;
end

if ~isfield(opt, 'saveName')
    opt.saveName = sprintf('olt%d.olt', opt.n);
end

%% Create .olt 

olt = BVQXfile('new:olt'); % ~!~BVQXTools Dependency~!~
olt.NrOfColors = opt.n;
olt.Colors = round(fliplr(jet(opt.n)) .* 255);

%% Save .olt 

olt.saveAs(opt.saveName);
[~,oltName] = fileparts(opt.saveName);
fprintf('Saved As: %s.olt\n', oltName);