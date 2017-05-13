function [scan] = extractStimImg(scan, scanOpt, nScan, opt)
% [scan] = createStimImg(scan, opt)
%
% Extracts a MxN stimulus image where M is the number of volumes in the scan
% (time progresses down the y-axis) and N is the length upsampled (or not)
% unique units of the stimulus. 1s in the matrix indicate when and which
% stimulus was presented depending on the row (when, volume number) and
% column (which, upsampled (or not) stimulus index)
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
%       <model funcOf>    Upsampled (or not) unique units of the given
%                         stimulus
%       stimImg           A M x Ni x ... x Nn matrix where M is the number
%                         of volumes of the scan and Ni through Nn is the
%                         length(scan.<funcOf>) or the desired resolution
%                         of the stimulus image for each stimulus dimension
%
% Note:
% - The stimulus image can be visualized with imagesc(scan.stimImg)

% Written by Kelly Chang - March 29, 2017

%% Extract Stimulus Image

load(scanOpt.paradigmPath{nScan}); % load paradigm file
stimImg = eval(scanOpt.stimImg{nScan});
stimSize = size(stimImg);

if ~isfield(scanOpt, 'dt')
    scan.dt = scan.dur / stimSize(1); % seconds per frame
else 
    scan.dt = scanOpt.dt;
end

%% Extract Stimulus Dimensions

paramNames = feval(opt.model);
for i = 1:length(paramNames.funcOf)
    scan.(paramNames.funcOf{i}) = 1:stimSize(i+1);
end
scan.stimImg = stimImg;