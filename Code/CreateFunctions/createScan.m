function [scan] = createScan(scanOpt, opt)
% [scan] = createScan(scanOpt, opt)
%
% Creates a structure 'scan' containing information about the scan(s) given
% by the corresponding 'scanOpt.boldPath' and 'scanOpt.matPath' through
% one of two methods
%
% METHOD 1: PARADIGM
% Will create a 'scan' structure based on the given
% 'scanOpt.paradigm.<funcOf>' sequence(s), will create a stimulus image
% from the given paradigm sequence(s)
% 
% METHOD 2: STIMULUS IMAGE
% Will create a 'scan' structre based on pre-defined stimulus image(s)
%
% Inputs:
%   scanOpt                  A structure containing option to create the
%                            'scan' structure with fields:
%       boldPath             Path(s) to all BrainVoyager or FreeSurfer BOLD
%                            files(s), string
%       matPath              Path(s) to all .mat paradigm files, string
%       roiPath              Path(s) to all BrainVoyager or FreeSurfer ROI
%                            file(s), string
% -------------------------------------------------------------------------
% METHOD 1: PARADIGM
%       paradigm             A structure containing variable name(s) of the
%                            paradigm sequence(s) located within the
%                            paradigm files; optional, specifying will
%                            let the code create the stimulus image 
%            <funcOf         Stimulus paradigm sequence of the field
%             parameters>    specified 'funcOf' parameter name
%
% METHOD 2: STIMULUS IMAGE
%       stimImg              Name of the stimulus image variable within the
%                            paradigm file(s), string; optional, specifying
%                            will use this variable as the stimulus image
%       dt                   Time step size, numeric (default:
%                            scan.dur/size(stimImg,1))
%       order                Order of the stimulus image dimensions
%                            (default: [nVolumes <opt.model's funcOf>])
% -------------------------------------------------------------------------
%   opt                      A structure containing option for pRF model
%                            fitting containing fields:
%       model                Model name, also the function name to be
%                            fitted string
%       roi                  Name(s) of the ROI files if fitting within 
%                            ROI(s), string
%
% Output:
%   scan                     A structure with length 1xN where N is the
%                            length of 'scanOpt.boldPath' containing the
%                            .vtc and scan's information with fields:
%       matFile              Name of .mat file , string
%                            (i.e., 'Subj1_Paradigm_Set1.mat')
%       paradigm             A structure containing the paradigm sequences
%                            for each stimulus dimension given as fields:
%           <funcOf          Stimulus paradigm sequence, should be given in
%             parameters>    units that are to be estimated for each
%                            stimulus dimension, blanks should be coded as
%                            NaNs, numeric
%       k                    A structure containing the unique stimulus
%                            values for each stimulus dimension given as
%                            fields:
%           <funcOf          Unique stimulus values for each stimulus
%             parameters>    dimension, excludes NaNs
%       funcOf               A structure containing the actual function of
%                            parameters as matrices scan given the model as
%                            fields:
%           <funcOf          Full function of stimulus values for each 
%             parameters>    stimulus dimension, meshgrid applied if
%                            multiple funcOf parameters
%       boldFile             Name of the BOLD file, string
%                            (i.e., 'Subj1_Set1.<vtc/nii>')
%       boldSize             Size of the functional data
%       nVols                Number of volumes in the scan
%       dur                  Total scan duration, seconds
%       TR                   TR of the scan, seconds
%       dt                   Time step for the paradigm or stimulus image,
%                            seconds
%       t                    Time vector of the scan in TRs, seconds
%       voxID                Voxel index number
%       vtc                  Voxel time course 
%       stimImg              A M x Ni x ... x Nn matrix where M is the
%                            number of volumes of the scan and Ni through
%                            Nn is the length(scan.paradigm.<funcOf>) or
%                            the desired resolution of the stimulus image 
%                            for each stimulus dimension
%
% Note:
% - Dependencies: <a href="matlab:
% web('http://support.brainvoyager.com/available-tools/52-matlab-tools-bvxqtools/232-getting-started.html')">BVQXTools/NeuroElf</a>, <a href="matlab: web('https://github.com/vistalab/vistasoft/tree/master/external/freesurfer')">mrVista/FreeSurfer</a>

% Written by Kelly Chang - June 23, 2016
% Edited by Kelly Chang - September 1, 2017

%% Input Control

if ~isfield(scanOpt, 'boldPath') || isempty(scanOpt.boldPath)
    error('No bold files selected');
end

if ischar(scanOpt.boldPath)
    scanOpt.boldPath = {scanOpt.boldPath};
end

if ~isfield(scanOpt, 'matPath') && isempty(scanOpt.matPath)
    error('No .mat files selected');
end

if ischar(scanOpt.matPath)
    scanOpt.matPath = {scanOpt.matPath};
end

if length(scanOpt.boldPath) ~= length(scanOpt.matPath)
    error('All bold files must have corresponding .mat files');
end

if ~isfield(scanOpt, 'roiPath')
    scanOpt.roiPath = {''};
end

if ischar(scanOpt.roiPath)
    scanOpt.roiPath = {scanOpt.roiPath};
end

if isempty(opt.roi) && ~all(cellfun(@isempty, scanOpt.roiPath))
    error('No ''opt.roi'' when ''scanOpt.roiPath'' is specified');
end

if ~isempty(opt.roi) && all(cellfun(@isempty, scanOpt.roiPath))
    error('No ''scanOpt.roiPath'' when ''opt.roi'' is specified');
end

if isfield(scanOpt, 'paradigm') && isfield(scanOpt, 'stimImg')
    error('Cannot specify both ''scanOpt.paradigm.<var>'' and ''scanOpt.stimImg''');
end

if isfield(scanOpt, 'paradigm') && ~isstruct(scanOpt.paradigm)
    error('Must specify variable name(s) for ''scanOpt.paradigm.<var>''');
end

paramNames = eval(opt.model);
if isfield(scanOpt, 'paradigm') && ~all(ismember(paramNames.funcOf, fieldnames(scanOpt.paradigm)))
    errFlds = setdiff(paramNames.funcOf, fieldnames(scanOpt.paradigm));
    error('Must specify paradigm.<var> for variable(s): %s', strjoin(errFlds, ', '));
end

if isfield(scanOpt, 'paradigm') && any(structfun(@isempty, scanOpt.paradigm))
    errFlds = fieldnames(scanOpt.paradigm);
    error('Must specify ''paradigm.<var>'' variable name(s) for: %s', ...
        strjoin(errFlds(structfun(@isempty, scanOpt.paradigm)), ', '));
end

if isfield(scanOpt, 'stimImg') && isempty(scanOpt.stimImg)
    error('Must specify a variable name for ''scanOpt.stimImg''');
end

if isfield(scanOpt, 'stimImg') && ~isfield(scanOpt, 'order')
    scanOpt.order = ['nVols' paramNames.funcOf];
end

%% Bold File Name(s)

[~,file,ext] = cellfun(@fileparts, scanOpt.boldPath, 'UniformOutput', false);
boldFile = strcat(file, ext);

%% Creating 'scan' Structure

flds = fieldnames(scanOpt);
stimImgMethod = char(flds(ismember(flds, {'paradigm', 'stimImg'})));
[~,~,software] = cellfun(@fileparts, scanOpt.boldPath, 'UniformOutput', false);
for i = 1:length(scanOpt.boldPath)
    if ~opt.quiet
        fprintf('Loading: %s\n', boldFile{i});
    end
    
    switch software{i} % loading bold data
        case '.vtc' % BrainVoyager
            tmp = createBVScan(scanOpt.boldPath{i}, scanOpt.roiPath);
        case {'.nii', '.gz', '.mgh'} % FreeSurfer
            tmp = createFreeSurferScan(scanOpt.boldPath{i}, scanOpt.roiPath);
        otherwise
            error('Unrecognized file extension: %s', software{i});
    end
    
    switch stimImgMethod % load stimulus data
        case 'paradigm' % specifying with paradigm sequence
            scan(i) = createStimImg(tmp, scanOpt, i, opt);
        case 'stimImg' % extracting pre-made stimImg
            scan(i) = extractStimImg(tmp, scanOpt, i, opt);
    end
end