% demoBVFiles.m

clear all; close all;

%% Create .olt and .vmp
 
% load pRF file
load(fullfile(pwd, 'Demo', 'DemoExampleResults', ...
    'Demo_pRF_Tonotopy_Gaussian1D_Example.mat')); % collated

% .olt options
oltOpt.n = 20; % number of colors
oltOpt.saveName = sprintf('rainbow%d.olt', oltOpt.n);

olt = createOlt(oltOpt); % create .olt

vmpOpt.maps = {'mu', 'sigma', 'exp', 'corr'};
vmpOpt.oltFile = oltOpt.saveName;
vmpOpt.mu = log10([88 8000]);
vmpOpt.sigma = [0.01 2];
vmpOpt.exp = [0 1];
vmpOpt.saveName = 'DemoData.vmp';

vmp = createVMP(collated, vmpOpt); % create .vmp