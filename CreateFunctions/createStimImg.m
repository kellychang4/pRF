function [scan] = createStimImg(scan, opt)
% [scan] = createStimImg(scan, opt)
%
% Creates a MxN stimulus image where M is the number of volumes in the scan
% (time progresses down the y-axis) and N is the length upsampled (or not)
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
% - The stimulus image can be visualized with imagesc(scan.stimImg)

% Written by Kelly Chang - June 21, 2016

%% Error Check

paramNames = eval(opt.model);
if length(paramNames.funcOf) > 1 && range(structfun(@length, scan.paradigm)) ~= 0
    error('Paradigm sequences are not equivalent in length');
end

%% Interpolate Up Sampled Resolution of Image

for i = 1:length(paramNames.funcOf)
    scan.(paramNames.funcOf{i}) = interp1(1:pt.upSample:length(scan.k.(paramNames.funcOf{i}))*opt.upSample, ...
        scan.k.(paramNames.funcOf{i}), 1:(length(scan.k.(paramNames.funcOf{i}))*opt.upSample));
    scan.(paramNames.funcOf{i}) = scan.(paramNames.funcOf{i})(1:end-(opt.upSample-1));
end

%% Create Stimulus Image

stimImg = eval(['zeros(length(scan.paradigm.(paramNames.funcOf{1})),', ...
    sprintf('length(scan.%s)', strjoin(paramNames.funcOf, '),length(scan.')) ');']);
for i = 1:size(stimImg,1) % for each paradigm instance
    if ~isnan(scan.paradigm.(paramNames.funcOf{1})(i))
        tmp = arrayfun(@num2str, cellfun(@(x) find(scan.(x)==scan.paradigm.(x)(i)), ...
            paramNames.funcOf), 'UniformOutput', false);
        eval(sprintf('stimImg(%d,%s)=1;', i, strjoin(tmp, ',')));
    end
end
scan.stimImg = stimImg;

%% Error Check

if ~all(ismember(paramNames.funcOf, fieldnames(scan)))
    errFlds = setdiff(paramNames.funcOf, fieldnames(scan));
    error('createStimImg() did not create %s() field(s) for ''scan'' structure: %s', ...
        opt.model, strjoin(errFlds, ', '));
end