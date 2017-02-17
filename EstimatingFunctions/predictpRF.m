function [predicted] = predictpRF(collated, data)
% [predicted] = predictpRF(collated, data)
%
% Returns a predicted structure containing information about the actual
% time course from data and the predicted time course of data as predicted
% using the model (collated)
%
% Inputs:
%   collated        A structure containing information about the model
%                   that will be used to predict a time course from the
%                   given data
%   data            A structure containing all scan(s) information that the
%                   model will be predicting a time course on
%
% Outputs:
%   predicted       A structure containing information about the predicted
%                   time course of data estimated by the pRF model
%                   (collated) with fields:
%       id          Voxel id number
%       tc          Voxel time course (trom data structure)
%       pred        Predicted time course created by predicting on data
%                   with the model (collated)
%       corr        Correlation coefficient of the actual time course with
%                   the predicted time course

% Written by Kelly Chang - July 19, 2016

%% Input Control

if ~isfield(data, 'convStim')
    for i = 1:length(data)
        data(i).convStim = createConvStim(data(i), collated.hrf);
    end
end

%% CSS Control

nVox = length(data(1).vtc);
scanExp = ones(1,nVox);
if collated.opt.CSS
    scanExp = [collated.pRF.exp];
end

%% Initialize 'Predicted' Structure

for i = 1:length(data)
    for i2 = 1:nVox
        tmp(i2).id = data(i).vtc(i2).id;
        tmp(i2).tc = data(i).vtc(i2).tc;
        tmp(i2).pred = NaN;
        tmp(i2).corr = NaN;
    end
    predicted(i).vtc = tmp;
end

%% Predict Time Course

for vN = 1:nVox
    if collated.pRF(vN).didFit
        for i = 1:length(data)
            tmp = data(i).convStim * callModel(collated.opt.model, collated.pRF(vN), data(i));
            predicted(i).vtc(vN).pred = pos0(tmp) .^ scanExp(i);
            
            predicted(i).vtc(vN).corr = callCorr(predicted(i).vtc(vN).tc, ...
                predicted(i).vtc(vN).pred, collated.opt.corr);
        end
    end
end