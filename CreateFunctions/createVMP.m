function [vmp] = createVMP(collated, opt)
% [vmp] = createVMP(collated, opt)
%
% Creates a .vmp file from the given pRF information
%
% Inputs:
%   collated            A structure containing fitted pRF information as
%                       given by [collated] = estpRF(scan, seeds, hdr, opt)
%   opt                 A structure containing options to create the .vmp
%                       file with fields:
%       maps            Name(s) of the VMP maps to be created, string
%                       (i.e, {'mu', 'sigma', 'exp', 'correlation'})
%       oltFile         Name of the .olt file used for the VMP maps, string
%                       (default: '<default>')
%       <parameters>    Adjustment [minimum maximum] of the specified
%                       parameter (i.e., opt.mu = [0 1])
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

%% Special Maps (if available)

pRFMap = collated.opt.map;
switch lower(pRFMap)
    case {'tonotopy', 'tono'}
        extraMaps = {'Qvalue' 'Bandwidth'};
        opt.maps = regexprep(opt.maps, 'q', 'Qvalue', 'ignorecase');
        opt.maps = regexprep(opt.maps, 'bw', 'Bandwidth', 'ignorecase');
    case 'none'
        extraMaps = {};
end

%% Parameters

adjParams = setdiff(fieldnames(opt), {'maps', 'oltFile', 'saveName'});
prfParams = setdiff(fieldnames(collated.pRF), {'id', 'didFit', 'tau', 'delta', 'bestSeed'});

%% Input Control

if ~isfield(opt, 'maps')
    opt.maps = [prfParams' extraMaps];
end

if ischar(opt.maps)
    opt.maps = {opt.maps};
end

if ~isfield(opt, 'oltFile')
    opt.oltFile = '<default>';
end

if ~isfield(opt, 'saveName')
    error('Need to specify opt.saveName for the .vmp to be saved as');
end

%% Adjustment Structure

% adjustment parameters must be a subset within all possible maps
if ~all(ismember(adjParams, prfParams))
    errFlds = setdiff(adjParams, prfParams);
    error('Too many specified adjustment parameters\nCould not find pRF parameter(s): %s', ...
        strjoin(errFlds, ', '));
end

%% Error Check

% opt.maps must be a subset within all possible maps (+ extra maps)
if ~all(ismember(opt.maps, [prfParams' extraMaps]))
    errMaps = reqMaps(~ismember(reqMaps, prfParams));
    error('Requested unknown map(s): %s', strjoin(errMaps, ', '));
end

%% Color Map Scaling

switch opt.oltFile
    case '<default>'
        mapScale = 19;
    otherwise
        olt = BVQXfile(opt.oltFile);
        mapScale = olt.NrOfColors - 1; % max number of intervals - 1 of .olt
end

%% Selecting Parameter Values and Loading into Maps

nanIndx = ~[collated.pRF.didFit]; % voxels that did NOT fit
id = [collated.pRF.id]; % voxel ids
bestSeed = cat(2, collated.pRF.bestSeed); % best seeds for each voxel

dims = collated.scan(1).vtcSize;
vmpData = zeros(1, prod(dims(2:4)));
for i = 1:length(prfParams)
    tmpVals = eval(['[collated.pRF.' prfParams{i} '];']); % pRF value
    switch lower(prfParams{i}) % special cases of NaN adjustment
        case 'exp'
            tmpVals(nanIndx) = 0;
        case 'corr'
            tmpVals(nanIndx) = 0.01;
        otherwise % if nan, replace with best seed value
            tmpVals(nanIndx) = eval(['[bestSeed(nanIndx).' prfParams{i} '];']);
    end
    tmp = zeros(size(vmpData)); % initialize maps
    tmp(id) = tmpVals; % load with values
    maps.(prfParams{i}) = tmp;
end

%% Min/Max Adjustments

if ~isempty(adjParams) % if any parameters to be adjusted exist
    for i = 1:length(adjParams)
        maps.(adjParams{i})(maps.(adjParams{i}) < opt.(adjParams{i})(1)) = opt.(adjParams{i})(1);
        maps.(adjParams{i})(maps.(adjParams{i}) > opt.(adjParams{i})(2)) = opt.(adjParams{i})(2);
    end
end

%% Calculations for Special Maps

switch lower(pRFMap)
    case {'tonotopy', 'tono'}
        f1 = 10.^(maps.mu-maps.sigma); % log10 --> freq (mu - sigma)
        f2 = 10.^(maps.mu+maps.sigma); % log10 --> freq (mu + sigma)
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
    
    tmp = zeros(dims(2:4)); % initialize map in the 3D functional space
    switch opt.maps{i}
        case 'Qvalue'
            tmp = (10.^maps.mu)./(f2-f1);
            tmp = round(scaleif(tmp, 0, mapScale)) + maps.corr;
        case 'Bandwidth'
            tmp = (log10(f2./f1)/log10(2));
            tmp = round(scaleif(tmp, 0, mapScale)) + maps.corr;
        otherwise
            tmp = round(scaleif(maps.(opt.maps{i}), 0, mapScale)) + maps.corr;
    end
    map.VMPData = single(reshape(tmp, dims(2:4)));
    vmp.Map(i) = map;
end

%% Save .vmp

vmp.SaveAs(opt.saveName);
[~,vmpName] = fileparts(opt.saveName);
disp(['Saved As: ' vmpName '.vmp']);