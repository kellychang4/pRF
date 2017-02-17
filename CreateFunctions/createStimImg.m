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
%       paradigm          Stimulus paradigm sequence, given in units that 
%                         are to estimated, blanks should be coded as NaNs,
%                         numeric
%       k                 A vector containing the unique units of the given
%                         stimulus 
%                         (i.e., unique(paradigm(~isnan(paradigm))) )
%       nVols             Number of volumes in the scan
%   opt                   Options for creating the stimulus image with 
%                         fields:
%       nSamples          Optional, desired up sampling resolution for the
%                         stimulus image (default: length(scan.k))
%
% Outputs:
%   scan                  The same 'scan' structure, but with additional 
%                         fields depending on opt.map type. However, in the
%                         case of code modification of this function, the
%                         outputed 'scan' structure MUST include the 
%                         following fields:
%       <model funcOf>    Upsampled (or not) unique units of the given 
%                         stimulus
%       stimImg           A MxN matrix where M is the number of volumes of 
%                         the scan and N is the length(scan.<funcOf>) or 
%                         the desired resolution of the stimulus image
%
% Note:
% - scan.paradigm MUST be specified in the units that will eventually be
% estimated for the pRF model
% - The stimulus image can be visualized with imagesc(scan.stimImg)

% Written by Kelly Chang - June 21, 2016

%% Calculate Up Sample Factor for Stimulus Image

upSampFactor = 1;
if isfield(opt, 'nSamples') && ~isnan(opt.nSamples)
    upSampFactor = round(opt.nSamples/length(scan.k));
end

%% Interpolate Up Sampled Resolution of Image 

paramNames = eval(opt.model);
scan.(paramNames.funcOf{:}) = interp1(1:upSampFactor:length(scan.k)*upSampFactor, ...
    scan.k, 1:(length(scan.k)*upSampFactor));
scan.(paramNames.funcOf{:}) = scan.(paramNames.funcOf{:})(1:end-(upSampFactor-1));

%% Create Stimulus Image

stimImg = zeros(length(scan.paradigm), length(scan.(paramNames.funcOf{:})));
for i = 1:size(stimImg,1) % for each row of the stimulus image/paradigm length
    if ~isnan(scan.paradigm(i))
        stimImg(i,:) = scan.(paramNames.funcOf{:}) == scan.paradigm(i);
    end
end
scan.stimImg = stimImg;

%% Error Check

if ~all(ismember(paramNames.funcOf, fieldnames(scan)))
    errFlds = setdiff(paramNames.funcOf, fieldnames(scan));
    error('createStimImg() did not create %s() field(s) for ''scan'' structure: %s', ...
        opt.model, strjoin(errFlds, ', '));
end