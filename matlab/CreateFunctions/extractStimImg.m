function [scan] = extractStimImg(scan, scanOpt, nScan, opt)
% [scan] = createStimImg(scan, scanOpt, nScan, opt)
%
% Extracts a MxN stimulus image where M is the number of volumes in the scan
% (time progresses down the y-axis) and N is the length of unique units of 
% the stimulus. 1s in the matrix indicate when and which stimulus was 
% presented depending on the row (when, volume number) and column (which, 
% stimulus index)
%
% Inputs:
%   scan                  A stucture containing information about the
%                         scan(s):
%   scanOpt               A structure containing option to create the
%                         'scan' structure, MUST include field:
%       stimImg           Name of the stimulus image variable within the
%                         paradigm file(s), string
%       dt                Time step size, numeric (default:
%                         scan.dur/size(stimImg,1))
%   nScan                 Scan number within 'scanOpt'
%   opt                   A structure containing options for pRF model
%                         fitting, MUST include field:
%       model             Model name, also the function name to be fitted,
%                         string
%
% Outputs:
%   scan                  The same 'scan' structure, but with additional
%                         fields depending on opt.map type. However, in the
%                         case of code modification of this function, the
%                         outputed 'scan' structure MUST include the
%                         following fields:
%       <model funcOf>    The unique units of the given stimulus
%       stimImg           A M x Ni x ... x Nn matrix where M is the number
%                         of volumes of the scan and Ni through Nn is the
%                         length(scan.<funcOf>) or the desired resolution
%                         of the stimulus image for each stimulus dimension
%
% Note:
% - The stimulus image can be visualized with imagesc(scan.stimImg)

% Written by Kelly Chang - March 29, 2017
% Edited by Kelly Chang - July 19, 2017

%% Error Checking

funcVars = getfield(feval(opt.model), 'funcOf'); % <funcOf> variables
if ~all(ismember(funcVars, scanOpt.order))
    errFlds = funcVars(~ismember(funcVars, scanOpt.order));
    error('Missing ''scanOpt.order'' for these ''funcOf'' variable(s): %s', strjoin(errFlds, ', '));
end

if ~ismember('nVols', scanOpt.order)
    error('Missing ''nVols'' when defining ''scanOpt.order''');
end

%% Extract Stimulus Image

[~,file,ext] = fileparts(scanOpt.matPath{nScan}); 
scan.matFile = [file ext]; % name of .mat file

indx = cellfun(@(x) find(strcmp(['nVols' funcVars],x)), scanOpt.order);

load(scanOpt.matPath{nScan}); % load .mat file
stimImg = eval(scanOpt.stimImg); % assign stimulus image
stimImg = permute(stimImg, indx); % reorder stimulus image
stimSize = size(stimImg);

if ~isfield(scanOpt, 'dt')
    scan.dt = scan.dur / stimSize(1); % seconds per frame
else 
    scan.dt = scanOpt.dt;
end

%% Extract Stimulus Dimensions

if isfield(scanOpt, 'funcOf')
    for i = 1:length(funcVars)
        scan.funcOf.(funcVars{i}) = eval(scanOpt.funcOf.(funcVars{i}));
    end
else % not given
    for i = 1:length(funcVars)
        scan.funcOf.(funcVars{i}) = 1:stimSize(i+1);
    end
end
scan.stimImg = stimImg;

%% Meshgrid 'funcOf' Parameters for Models with more than 1 Dimension

if length(funcVars) > 1 && ~isequal(size(scan.funcOf.(funcVars{1})), size(scan.stimImg,2:3))
   eval(sprintf('[scan.funcOf.%1$s]=meshgrid(scan.funcOf.%1$s);', ...
       strjoin(funcVars, ',scan.funcOf.')));
end

%% Organize Output

scan = orderfields(scan, {'matFile', 'funcOf', 'boldFile', 'boldSize', ...
    'nVols', 'dur', 'TR', 'dt', 't', 'voxIndex', 'voxID', 'vtc', 'stimImg'});