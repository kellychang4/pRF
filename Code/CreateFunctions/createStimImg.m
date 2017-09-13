function [scan] = createStimImg(scan, scanOpt, nScan, opt)
% [scan] = createStimImg(scan, scanOpt, nScan, opt)
%
% Creates a MxNi stimulus image where M is the number of volumes in the scan
% (time progresses down the y-axis) and Ni is the length upsampled (or not)
% unique units of the stimulus. 1s in the matrix indicate when and which
% stimulus was presented depending on the row (when, volume number) and
% column (which, upsampled (or not) stimulus index)
%
% Inputs:
%   scan                  A stucture containing information about the
%                         scan(s), MUST include fields:
%       paradigm          A structure containing the stimulus paradigm
%                         sequences for each stimulus dimension as field
%                         names:
%           <model        Stimulus paradigm sequence, given in units that
%             funcOf>     are to estimated, blanks should be coded as NaNs,
%                         numeric
%       k                 A structure containing the unique units of the
%                         given stimulus dimension as field names:
%           <model        A vector containing the unique units of the given
%             funcOf>     stimulus dimension
%                         (i.e., unique(paradigm(~isnan(paradigm))) )
%       nVols             Number of volumes in the scan
%   opt                   Options for creating the stimulus image with
%                         fields:
%       upSample          Optional, desired up sampling factor for the new
%                         resolution of the stimulus image
%
% Outputs:
%   scan                  The same 'scan' structure, but with additional
%                         fields depending on opt.map type. However, in the
%                         case of code modification of this function, the
%                         outputed 'scan' structure MUST include the
%                         following fields:
%       <model funcOf>    Upsampled (or not) unique units of the given
%                         stimulus
%       stimImg           A MxN matrix where M is the number of instances
%                         of the paradigm as specified by the paradigm
%                         sequence for the particular scan and N is the
%                         length(scan.<funcOf>) or the desired resolution
%                         of the stimulus image
%
% Note:
% - scan.paradigm.<funcOf> MUST be specified in the units that will
% eventually be estimated for the pRF model

% Written by Kelly Chang - June 21, 2016
% Edited by Kelly Chang - July 19, 2017

%% Interpolate Up Sampled Stimulus Resolution

[~,file,ext] = fileparts(scanOpt.matPath{nScan}); 
scan.matFile = [file ext]; % name of .mat file

funcOf = getfield(eval(opt.model), 'funcOf');
load(scanOpt.matPath{nScan}); % load paradigm file
for i = 1:length(funcOf)
    scan.paradigm.(funcOf{i}) = eval(['[' scanOpt.paradigm.(funcOf{i}) ']']);
    scan.k.(funcOf{i}) = unique(scan.paradigm.(funcOf{i})(~isnan(scan.paradigm.(funcOf{i}))));
    
    % Interpolate Up-Sampled Resolution of funcOf Variables
    scan.funcOf.(funcOf{i}) = interp1(1:opt.upSample:length(scan.k.(funcOf{i}))*opt.upSample, ...
        scan.k.(funcOf{i}), 1:(length(scan.k.(funcOf{i}))*opt.upSample));
    scan.funcOf.(funcOf{i}) = scan.funcOf.(funcOf{i})(1:end-(opt.upSample-1));
end

%% Error Check

if length(unique(structfun(@length, scan.paradigm))) > 1
    errs = cellfun(@(x,y) sprintf('%s (%d)',x,y), fieldnames(scan.paradigm), ...
    num2cell(structfun(@length, scan.paradigm)), 'UniformOutput', false);
    error('Given paradigm sequences mismatch in length:\n\t%s', ...
        strjoin(errs, '\n\t'));
end

%% Calculate Stimulus Image / Paradigm Time Sampling Rate (dt)

scan.dt = scan.dur/length(scan.paradigm.(funcOf{1}));

%% Create Stimulus Image

stimImg = eval(['zeros(length(scan.paradigm.(funcOf{1})),', ...
    sprintf('length(scan.funcOf.%s)', strjoin(funcOf, '),length(scan.funcOf.')) ');']);
for i = 1:size(stimImg,1) % for each paradigm instance
    if ~isnan(scan.paradigm.(funcOf{1})(i))
        tmp = arrayfun(@num2str, cellfun(@(x) find(scan.funcOf.(x)==scan.paradigm.(x)(i)), ...
            funcOf), 'UniformOutput', false);
        eval(sprintf('stimImg(%d,%s)=1;', i, strjoin(tmp, ',')));
    end
end
scan.stimImg = stimImg;

%% Meshgrid 'funcOf' Parameters for Models with more than 1 Dimension

if length(funcOf) > 1
    eval(sprintf('[scan.funcOf.%1$s]=meshgrid(scan.funcOf.%1$s);', ...
        strjoin(funcOf, ',scan.funcOf.')));
end

%% Error Check

if ~all(ismember(funcOf, fieldnames(scan.funcOf)))
    errFlds = setdiff(funcOf, fieldnames(scan.funcOf));
    error('createStimImg did not create %s() field(s) for ''scan'' structure: %s', ...
        opt.model, strjoin(errFlds, ', '));
end

%% Organize Output

scan = orderfields(scan, {'matFile', 'paradigm', 'k', 'funcOf', ...
    'boldFile', 'boldSize', 'nVols', 'dur', 'TR', 'dt', 't', ...
    'voxID', 'vtc', 'stimImg'});