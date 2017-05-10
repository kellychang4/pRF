function [hemo] = plotHRF(collated)
% [hemo] = plotHRF(collated)
%
% Plots the estimated HRF parameters if fitted, else plots the initial HRF
% parameters used to fit the pRF model.
%
% Inputs: 
%   collated        A structure containing all fitted pRF information as
%                   as given by [collated] = estpRF(scan, seeds, hrf, opt)
%   
% Output:
%   hemo            A vector containing the hemodynamic response function
%                   as calcuated or extracted from the 'collated' structure

% Written by Kelly Chang - May 8, 2017

%% Extract Hemodynamic Response

t = collated.hrf.t;
if isfield(collated.hrf, 'fit') 
    params = collated.hrf.fit;
    hemo = GammaHRF(params, collated.hrf);
else % hrf was not fit
    params = collated.hrf;
    hemo = GammaHRF(params, collated.hrf);
end

if isfield (collated.hrf, 'hrf') % pre-defined hrf
    hemo = collated.hrf.hrf;
end

%% Plot HRF

figure(); clf;
plot(t, hemo);
xlabel('Time (s)');
ylabel('Response');
title('Hemodynamic Response Function');