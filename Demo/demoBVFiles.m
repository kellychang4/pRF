% demoBVFiles.m

clear all; close all;

%% Create .olt and .vmp
 
% load pRF file
paths.main = ''; % main working directory
paths.results = fullfile(paths.main, 'Ver2.0', 'Demo', 'DemoExampleResults');
load(fullfile(paths.results, 'Demo_pRF_Tonotopy_Gaussian1D_Example.mat')); % collated

% .olt options
oltOpt.n = 20; % number of colors
oltOpt.saveName = fullfile(paths.results, sprintf('rainbow%d.olt', oltOpt.n));

olt = createOlt(oltOpt); % creat e .olt

vmpOpt.maps = {'mu', 'sigma', 'exp', 'corr'};
vmpOpt.oltFile = oltOpt.saveName;
vmpOpt.mu = log10([88 8000]);
vmpOpt.sigma = [0.01 2];
vmpOpt.exp = [0 1];
vmpOpt.saveName = fullfile(paths.results, 'DemoData_Example.vmp');

vmp = createVMP(collated, vmpOpt); % create .vmp