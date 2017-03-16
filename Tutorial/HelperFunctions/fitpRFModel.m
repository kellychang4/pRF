function [err] = fitpRFModel(params, convolvedMatrix, actual, stimuli)

%% Fit pRF Model

pred = gaussian(params.mu, params.sigma, stimuli) * convolvedMatrix;
err = -corr(actual(:), pred(:)); % mean (negative) correlation