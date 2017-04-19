function [vmp] = createVMP(collated, opt)
% [vmp] = createVMP(collated, opt)
%
% Creates a .vmp file from the given pRF model, modified by the given
% options 
%
% Inputs:
%   collated            A structure containing fitted pRF information as
%                       given by [collated] = estpRF(scan, seeds, hrf, opt)
%   opt                 A structure containing options to create the .vmp
%                       file with fields:
%       maps            Name(s) of the VMP maps to be created, string
%                       (i.e, {'mu', 'sigma', 'exp', 'correlation'}),
%                       (default: all available parameters)
%       oltFile         Path to the .olt file used for the VMP maps, string
%                       (default: '<default>')
%       <parameters>    Adjustment [minimum maximum] of the specified
%                       parameter (i.e., opt.mu = [0 1]) (default: [minimum
%                       maximum] of an estimated pRF parameter)
%       saveName        Name the .vmp file will be saved as, string
%
% Output:
%   vmp                 A structure containing information of the .vmp file
%                       (See Notes for link to BrainVoyager Documentation)
%
% Notes:
% - Documentation: <a href="matlab: web('http://support.brainvoyager.com/automation-aamp-development/23-file-formats/377-users-guide-23-the-format-of-nr-vmp-files.html')">NR-VMP Format</a>
% - Dependencies: <a href="matlab: web('http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html')">BVQXTools/NeuroElf</a>

% Written by Kelly Chang - July 15, 2016

%% Input Control

if ~exist('opt', 'var') || ~isfield(opt, 'maps')
    opt.maps = setdiff(fieldnames(collated.pRF), {'id', 'didFit', 'tau', 'delta', 'bestSeed'});
end

if ischar(opt.maps)
    opt.maps = {opt.maps};
end

% requested maps must be a subset within all pRF estimated parameters
prfParams = setdiff(fieldnames(collated.pRF), {'id', 'didFit', 'tau', 'delta', 'bestSeed'});
if ~all(ismember(opt.maps, prfParams))
    errParams = opt.maps(~ismember(opt.maps, prfParams));
    error('Requested map(s) unavailable: %s', strjoin(errParams, ', '));
end

if ~isfield(opt, 'oltFile')
    opt.oltFile = '<default>';
end

if ~isfield(opt, 'saveName')
    error('Need to specify opt.saveName for the .vmp to be saved as');
end

%% Adjustment Structure

% adjustment parameters must be a subset within all requested maps
adjParams = setdiff(fieldnames(opt), {'maps', 'oltFile', 'saveName'});
if ~all(ismember(adjParams, opt.maps))
    errParams = adjParams(~ismember(adjParams, opt.maps));
    error('Too many specified adjustment parameters\nCould not find pRF parameter(s): %s', ...
        strjoin(errParams, ', '));
end

tmp = setdiff(opt.maps, adjParams);
for i = 1:length(tmp)
    opt.(tmp{i}) = [min([collated.pRF.(tmp{i})]) max([collated.pRF.(tmp{i})])];
end

%% Color Map Scaling

switch opt.oltFile
    case '<default>'
        mapScale = 19;
    otherwise
        olt = BVQXfile(opt.oltFile);
        
        mapScale = olt.NrOfColors - 1; % number of colors - 1 of .olt
end

%% Min/Max Adjustments

indx = [collated.pRF.didFit]; % voxels that did fit
maps.id = [collated.pRF(indx).id];
for i = 1:length(opt.maps)
    maps.(opt.maps{i}) = [collated.pRF(indx).(opt.maps{i})];
    maps.(opt.maps{i})(maps.(opt.maps{i}) < opt.(opt.maps{i})(1)) = opt.(opt.maps{i})(1);
    maps.(opt.maps{i})(maps.(opt.maps{i}) > opt.(opt.maps{i})(2)) = opt.(opt.maps{i})(2);
end

%% Create .vmp Maps

vmp = BVQXfile('new:vmp'); % create template .vmp
vmp.NrOfMaps = length(opt.maps);

map = vmp.Map;
map.Type = 3; % modifiable .vmp type
map.LowerThreshold = 0;
map.UpperThreshold = 1;
map.LUTName = opt.oltFile;
map.MaxLag = mapScale;
map.NrOfLags = mapScale + 1;
map.DF1 = 0;
map.DF2 = 0;
map.BonferroniValue = 0;
for i = 1:length(opt.maps)
    map.Name = upper1(opt.maps{i}); % name of the map
    
    tmp = zeros(collated.scan(1).vtcSize(2:4)); % initialize map in the 3D functional space
    [~,maps.(opt.maps{i})] = arrayfun(@(x) ...
        min((linspace(opt.(opt.maps{i})(1),opt.(opt.maps{i})(2),mapScale)-x).^2), ...
        maps.(opt.maps{i}));
    tmp(maps.id) = maps.(opt.maps{i}) + [collated.pRF(indx).corr] - 1;

    map.VMPData = single(tmp);
    vmp.Map(i) = map;
end

%% Save .vmp

vmp.SaveAs(opt.saveName);
[~,vmpName] = fileparts(opt.saveName);
fprintf('Saved As: %s.vmp\n', vmpName); 