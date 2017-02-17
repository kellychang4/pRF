function [scan,opt] = createScan(scanOpt, opt)
% [scan,opt] = createScan(scanOpt, opt)
%
% Creates a structure 'scan' containing information about the scan(s) given
% by the corresponding 'scanOpt.vtcPath' and 'scanOpt.paradigmPath'
%
% Inputs:
%   scanOpt                  A structure containing option to create the 
%                            'scan' structure with fields:
%       vtcPath              Path(s) to all .vtc files, string  
%       paradigmPath         Path(s) to all .mat paradigm files, string
%       paradigmVar          Variable name of paradigm sequence located
%                            within paradigm files 
%                            (i.e., [scanOpt.paradigmVar])
%       voiPath              Path to .voi file, string
%   opt                      A structure containing option for pRF model
%                            fitting containing fields:
%       roi                  Name of the .voi if fitting a within a ROI, 
%                            string
%       nSamples             Desired resolution of the stimulus image,
%                            numeric
%
% Outputs:
%   scan                     A structure with length 1xN where N is the
%                            length of 'scanOpt.vtcPath' containing the 
%                            .vtc and scan's information with fields:
%       <folderName>         Directory name of paradigm and .vtc files,
%                            string (i.e., 'Subj1-23Jun2016')
%       <paradigmFolder>     Directory name of paradigm file(s), string
%       paradigmFile         Name of paradigm file , string
%                            (i.e., 'Subj1_Paradigm_Set1.mat')
%       paradigm             Stimulus paradigm sequence, should be given in
%                            units that are to estimated, blanks should be
%                            coded as NaNs, numeric
%       k                    Unique stimulus values 
%                            (i.e., unique(scan.paradigm))
%       <vtcFolder>          Directory name of .vtc file(s), string
%       vtcFile              Name of the .vtc file, string
%                            (i.e., 'Subj1_Set1.vtc')
%       vtcSize              Size of the vtc data
%       nVols                Number of volumes in the scan
%       TR                   TR of the scan, seconds
%       dur                  Total scan duration with no blanks, seconds
%       t                    Time vector of the scan, seconds
%       vtc                  A structure containing .vtc data with fields:                   
%           id               Voxel index number
%           tc               Time course of the indexed voxel
%       <model funcOf>       Upsampled (or not) unique units of the given 
%                            stimulus
%       stimImg              A MxN matrix where M is the number of volumes of 
%                            the scan and N is the length(scan.<funcOf>) or 
%                            the desired resolution of the stimulus image
%
% Notes:
% - Dependencies: <a href="matlab: web('http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html')">BVQXTools/NeuroElf</a>

% Written by Kelly Chang - June 23, 2016

%% Input Control

if ~isfield(scanOpt, 'voiPath')
    scanOpt.voiPath = '';
end

%% Error Check

if isempty(scanOpt.vtcPath)
    error('No .vtc files selected');
elseif isempty(scanOpt.paradigmPath)
    error('No paradigm files selected');
elseif length(scanOpt.vtcPath) ~= length(scanOpt.paradigmPath)
    error('All vtc files must have corresponding paradigm files');
end

if ~isfield(scanOpt, 'paradigmVar') || isempty(scanOpt.paradigmVar)
    error('Must specify ''scanOpt.paradigmVar''');
end

if ~isempty(opt.roi) && isempty(scanOpt.voiPath)
    error('No ''scanOpt.voiPath'' when ''opt.roi'' is specified');
end

if iscell(scanOpt.voiPath) && length(scanOpt.voiPath) > 1
    error('Too many .voi files specified');
end

if ~isempty(scanOpt.voiPath) && isempty(opt.roi)
    [~,opt.roi] = fileparts(scanOpt.voiPath);
    opt.roi = [opt.roi '.voi'];
end

%% .vtc File(s) and Folder Names

[~,tmp] = cellfun(@fileparts, scanOpt.vtcPath, 'UniformOutput', false);
vtcFile = strcat(tmp, '.vtc');

tmp = cellfun(@(x) ['(/|\\)(?<folder>[(\w)\-]+)(/|\\)' x], vtcFile, ...
    'UniformOutput', false);
vtcFolder = cellfun(@(x,y) struct2cell(regexp(x,y,'names')), ...
    scanOpt.vtcPath, tmp, 'UniformOutput', false);
vtcFolder = [vtcFolder{:}];
if length(unique(vtcFolder))
    vtcFolder = unique(vtcFolder);
end

%% Paradigm File(s) and Folder Names

[~,tmp,ext] = cellfun(@fileparts, scanOpt.paradigmPath, ...
    'UniformOutput', false);
paradigmFile = strcat(tmp, ext);
tmp = cellfun(@(x) ['(/|\\)(?<folder>[(\w)\-]+)(/|\\)' x], paradigmFile, ...
    'UniformOutput', false);
paradigmFolder = cellfun(@(x,y) struct2cell(regexp(x,y,'names')), ...
    scanOpt.paradigmPath, tmp, 'UniformOutput', false);
paradigmFolder = [paradigmFolder{:}];
if length(unique(paradigmFolder))
    paradigmFolder = unique(paradigmFolder);
end

if strcmp(vtcFolder, paradigmFolder)
    folderName = vtcFolder{:};
end

%% Creating 'scan' Structure

for i = 1:length(scanOpt.vtcPath)
    if ~opt.quiet
        disp(['Loading: ' vtcFile{i}]);
    end
    
    bc = BVQXfile(scanOpt.vtcPath{i}); % load .vtc file
    if ~isempty(opt.roi)
        voi = BVQXfile(scanOpt.voiPath);
        vtc = unpackROI(VTCinVOI(bc, voi));
    else
        vtc = fullVTC(bc);
    end
    
    load(scanOpt.paradigmPath{i}); % load paradigm file
    
    if exist('folderName', 'var')
        tmpScan.folderName = folderName; % name of the folder of the scan;
    else
        tmpScan.paradigmFolder = paradigmFolder{i}; % paradigm folder
        tmpScan.vtcFolder = vtcFolder{i}; % vtc folder
    end
    tmpScan.paradigmFile = paradigmFile{i}; % paradigm file name
    tmpScan.paradigm = eval(['[' scanOpt.paradigmVar '];']); % stimulus paradigm sequence
    tmpScan.k = unique(tmpScan.paradigm(~isnan(tmpScan.paradigm)));
    tmpScan.vtcFile = vtcFile{i}; % name of the .vtc file
    tmpScan.vtcSize = size(bc.VTCData); % size of the .vtc data
    tmpScan.nVols = bc.NrOfVolumes; % number of volumes in the scan
    tmpScan.TR = bc.TR/1000; % seconds
    tmpScan.dur = tmpScan.nVols*tmpScan.TR; % scan duration with no breaks, seconds
    tmpScan.t = 0:tmpScan.TR:(tmpScan.dur-tmpScan.TR);
    tmpScan.vtc = vtc;
    scan(i) = createStimImg(tmpScan, opt); % collect into one 'scan' stucture
end