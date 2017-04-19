function [cv] = cvpRF(collated)
% function [cv] = cvpRF(scan, seeds, hrf, opt)
%
% Performs a Leave-One-Scan-Out cross validation 
%
% (1) Estimates a pRF model as given by the options on the training set of
%     scans
% (2) Predicts the time course on the test set with the pRF model created
%     from step (1)
% 
% Inputs:
%   collated                A structure containing information about the 
%                           model that will be in a leave-one-scan-out 
%                           cross validation 
%
% Outputs:
%   cv                      A structure containing information from the
%                           cross-validation process with fields:
%       test                A structure containing all scan(s) information
%                           that comprise of the test set 
%       train               A structure containing all scan(s) information
%                           that comprise the training set
%       model               A structure containing the model information
%                           created from estimating the pRF model on the 
%                           training set (output as given by 
%                           [model] = estpRF(...))
%       predicted           A structure containing information about the
%                           predicted time course of the testing set given 
%                           the estimated model created from the training
%                           set with fields:
%           id              Voxel id number
%           tc              Voxel time course (trom the testing set)
%           pred            Predicted time course created by predicting on
%                           the test set with the model estimated from the 
%                           training set
%           corr            Correlation coefficient of the actual time
%                           course with the predicted time course

% Written by Kelly Chang - July 19, 2016

%% Input Control

if ~isnan(collated.opt.estHRF) % if HRF was estimated
    collated.opt.estHRF = NaN; % turn off HRF for cross validation
    collated.hrf.tau = collated.hdr.fit.tau; % update tau hrf parameter
    collated.hrf.delta = collated.hrf.fit.delta; % update delta hrf parameter
end

%% Initializing for Cross-Validatiaon

for i = 1:length(collated.scan)
    cv(i).test = rmfield(collated.scan(i), {'seedpRF', 'seedPred'});
    cv(i).train = rmfield(collated.scan(setdiff(1:length(collated.scan), i)), {'seedpRF', 'seedPred', 'convStim'});
    cv(i).model = NaN;
    cv(i).predicted = NaN;
end

%% Staring Cross-Validation

for i = 1:length(cv)
    if ~collated.opt.quiet 
        fprintf('Cross-Validation Fold: %d out of %d\n', i, length(cv));
    end
    cv(i).model = estpRF(cv(i).train, collated.seeds, collated.hrf, collated.opt); 
    cv(i).predicted = getfield(predictpRF(cv(i).model, cv(i).test), 'vtc'); % testing on one scan, so extract a structure level
end