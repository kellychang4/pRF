function [err] = fitpRFVoxelModel(params, nVox, convolvedMatrix, responseMatrix, stimuli)

%% Fit pRF Model

pred = gaussian(params.mu, params.sigma, stimuli) * convolvedMatrix;
err = -corr(responseMatrix(nVox,:)', pred(:)); % mean (negative) correlation