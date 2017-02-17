function [cv] = cvpRF(scan, seeds, hdr, opt)
% function [cv] = cvpRF(scan, seeds, hdr, opt)
%
% Performs a Leave-One-Scan-Out Cross-validation 
%
% (1) Estimates a pRF model as given by the options on the training set of
%     scans
% (2) Predicts the time course on the test set with the pRF model created
%     from step (1)
% 
% Inputs:
%   scan                    A structure containing information about the
%                           scan(s) (see 'createScan.m'). 
%                           When cross-validating, one scan will be held
%                           out to be the testing set, this results in a
%                           K-fold cross-validation process where K is the
%                           number of scans.
%   seeds                   A structure containing information about the
%                           seeds (see 'createSeeds.m')
%   hdr                     A structure containing information about the
%                           hemodynamic response function
%                           (see 'createHDR.m')
%   opt                     A structure containing information about model
%                           fitting options (see 'createOpt.m')
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

%% Initializing for Cross-Validatiaon

for i = 1:length(scan)
    cv(i).test = scan(i);
    cv(i).train = scan(setdiff(1:length(scan), i));
    cv(i).model = NaN;
    cv(i).predicted = NaN;
end

%% Staring Cross-Validation

disp('Starting Cross-Validation');
for i = 1:length(scan)
    if ~opt.quiet 
        disp(sprintf('Cross-Validation Fold: %d out of %d', i, length(scan)));
    end
    cv(i).model = estpRF(cv(i).train, seeds, hdr, opt); 
    cv(i).predicted = predictpRF(cv(i).model, cv(i).test);
end