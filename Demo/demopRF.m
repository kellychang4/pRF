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
opt.estHDR = true; % ~~~!!!~~~
opt.nSamples = 720;
opt.parallel = true;

%% Convert DemoVTC.mat to DemoData.vtc
% This section exists because of GitHub's file size limit. This section can
% be deleted after 'DemoData.vtc' has been created

load(fullfile(paths.data, 'DemoVTC.mat')); % vtc
tmp = BVQXfile('new:vtc');
flds = fieldnames(vtc);
for i = 1:length(flds)
    tmp.(flds{i}) = vtc.(flds{i});
end
tmp.saveAs(fullfile(paths.data, 'DemoData.vtc'));

%% Variables (cont.)

% scan options
scanOpt.vtcPath = fullfile(paths.data, 'DemoData.vtc');
scanOpt.paradigmPath = fullfile(paths.data, 'DemoData.mat');
scanOpt.voiPath = fullfile(paths.data, opt.roi);
scanOpt.paradigmVar = 'paradigm';

scan = createScan(scanOpt, opt); % creating 'scan' structure

% seed options
seedOpt.mu = linspace(2, 4, 21);
seedOpt.sigma = linspace(1, 4, 20);
seedOpt.exp = 0.5; % fixed parameter

seeds = createSeeds(seedOpt); % creating 'seeds' structure

% hdr options
hdrOpt.type = 'audition';
% hdrOpt.tau = <TAU>;
% hdrOpt.delta = <DELTA>;
hdrOpt.TR = scan(1).TR;

hdr = createHDR(hdrOpt); % creating 'hdr' structure

%% Estimate and Save pRF

[collated] = estpRF(scan, seeds, hdr, opt);

saveName = fullfile(paths.results, ...
    sprintf('%s_pRF_%s_%s_%s', upper1(subject), opt.map, opt.model, ...
    datestr(now, 'ddmmmyyyy')));
if opt.estHDR
    saveName = regexprep(saveName, '_pRF_', '_estHDR_');
end

safeSave(saveName, 'collated');

%% Visualizations

% estimated paramaters
paramOpt.params = {'mu', 'sigma', 'exp', 'corr'};
paramOpt.measure = @median;
plotParams(collated, paramOpt);

% predicted time course
plotPredicted(collated);
