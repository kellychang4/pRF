function [stim] = create_stimulus_image(stimFile, options)
% [stim] = create_stimulus_image(stimFile, options)
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
% Edited by Kelly Chang - July 11, 2022

%% Extract Stimulus Image to Create 'stim' Structure

%%% read source stimulus information
m = load(stimFile); % load .mat file
stimImg = m.(options.stimImg); % assign stimulus image variable
funcOf = m.(options.funcOf);   % assign function of variable

%%% validation / error checking
validate_funcof(stimImg, funcOf); 

%%% save stimulus information in 'stim' output
stim.stimFile = stimFile;
stim.funcOf = rmfield(funcOf, 't');
stim.dt = funcOf.t(2) - funcOf.t(1); 
stim.t = funcOf.t(:); 
stim.stimImg = stimImg;