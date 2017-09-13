function [hemo] = plotHRF(hrf)
% [hemo] = plotHRF(hrf)
%
% Plots the estimated HRF parameters if fitted, else plots the initial HRF
% parameters used to fit the pRF model.
%
% Input: 
%   hrf             A structure containing all fitted pRF information as
%                   as given by hrf = createHRF(opt). Can also be passed
%                   through after a model has been fitted as 'hrf'
%   
% Output:
%   hemo            A vector containing the hemodynamic response function
%                   as calcuated or extracted from the 'hrf' structure
%
% Example:
% % plot hrf used to create the finish model
% hemo = plotHRF(collated.hrf); 

% Written by Kelly Chang - May 8, 2017

%% Extract Hemodynamic Response

t = hrf.t;
if isfield(hrf,'funcName') && isfield(hrf, 'fit') % parameterized + fitted
    params = hrf.fit;
    hemo = feval(hrf.funcName, params, t);
end

if isfield(hrf,'funcName') && ~isfield(hrf,'fit') % parameterized + not fitted
    params = hrf;
    hemo = feval(hrf.funcName, params, t);
end

if isfield (hrf, 'hrf') % pre-defined hrf
    hemo = hrf.hrf;
end

%% Plot HRF

figure(); clf;
plot(t, hemo);
xlabel('Time (s)');
ylabel('Response');
title('Hemodynamic Response Function');