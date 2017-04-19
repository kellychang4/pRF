% demopRF.m

clear all; close all;

%% Variables

% subject information
subject = 'Demo';

% directories
% paths = createPaths(); % initialize paths structure
% paths.data = fullfile(paths.main, 'Demo', 'DemoData'); % path to demostration data directory
% paths.results = fullfile(paths.main, 'Demo', 'DemoExampleResults'); % path to output results directory
% paths = createPaths(paths); % create paths if they do not already exist

% model options
opt = createOpt('Tonotopy');
opt.roi = 'DemoROI.voi';
opt.estHRF = 3; 
opt.upSample = 3;
opt.parallel = true;

%% Convert DemoVTC.mat to DemoData.vtc
% This section exists because of GitHub's file size limit. This section can
% be deleted or commented 'DemoData.vtc' has been created. 

if ~exist(fullfile(paths.data, 'DemoData.vtc'), 'file')
    load(fullfile(paths.data, 'DemoVTC.mat')); % load .mat version of .vtc data
    tmp = BVQXfile('new:vtc'); % ~!~BVQXTools Dependency~!~
    flds = fieldnames(vtc);
    for i = 1:length(flds)
        tmp.(flds{i}) = vtc.(flds{i});
    end
    tmp.saveAs(fullfile(paths.data, 'DemoData.vtc'));
end

%% Variables (cont.)

% scan options
scanOpt.vtcPath = fullfile(paths.data, 'DemoData.vtc');
scanOpt.paradigmPath = fullfile(paths.data, 'DemoData.mat');
scanOpt.voiPath = fullfile(paths.data, opt.roi);
scanOpt.paradigm.x = 'paradigm';

scan = createScan(scanOpt, opt); % creating 'scan' structure

% seed options
seedOpt.mu = linspace(2, 4, 21);
seedOpt.sigma = linspace(1, 4, 20);
seedOpt.exp = 0.5; % fixed parameter

seeds = createSeeds(seedOpt); % creating 'seeds' structure

% hdr options
hrfOpt.type = 'audition';
hrfOpt.dt = scan(1).TR;

hrf = createHRF(hrfOpt); % creating 'hdr' structure

%% Estimate and Save pRF

[collated] = estpRF(scan, seeds, hrf, opt);

saveName = fullfile(paths.results, ...
    sprintf('%s_pRF_%s_%s_%s', upper1(subject), opt.map, opt.model, ...
    datestr(now, 'ddmmmyyyy')));

safeSave(saveName, 'collated');

%% Visualizations

% estimated paramaters
paramOpt.params = {'mu', 'sigma', 'exp', 'corr'};
paramOpt.measure = @median;
plotParams(collated, paramOpt);

% predicted time course
plotPredicted(collated);
