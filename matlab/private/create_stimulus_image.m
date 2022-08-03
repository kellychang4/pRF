function [stim] = create_stimulus_image(stimFile, options)
% [stim] = create_stimulus_image(stimFile, options)

%% Extract Stimulus Image to Create 'stim' Structure

%%% read source stimulus information
m = load(stimFile); % load .mat file
stimImg = m.(options.stimImg); % assign stimulus image variable
funcOf = m.(options.funcOf);   % assign function of variable

%%% validation / error checking
validate_funcof(stimImg, funcOf); 

%%% save stimulus information in 'stim' output
stim.file = filename(stimFile);
stim.funcOf = rmfield(funcOf, 't');
stim.dt = funcOf.t(2) - funcOf.t(1); 
stim.t = funcOf.t(:); 
stim.stimImg = stimImg;