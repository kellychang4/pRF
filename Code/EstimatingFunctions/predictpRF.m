function [predicted] = predictpRF(collated, data)
% [predicted] = predictpRF(collated, data)
%
% Returns a predicted structure containing information about the actual
% time course from data and the predicted time course of data as predicted
% using the model (collated) on the given data.
%
% Inputs:
%   collated        A structure containing information about the model
%                   that will be used to predict a time course from the
%                   given data created from [collated] = estpRF()
%   data            A structure containing all scan(s) information that the
%                   model will be predicting a time course on as given from
%                   [data] = createScan(scanOpt, opt)
%
% Output:
%   predicted       A structure containing information about the actual and
%                   predicted time course of data estimated by the pRF 
%                   model (collated) with fields:
%       voxID       Voxel id number
%       tc          Voxel time course (from the given data structure)
%       pred        Predicted time course created by predicting on data
%                   with the model (collated)
%       corr        Correlation coefficient of the actual time course with
%                   the predicted time course
%
% Example:
% % create predicted time courses of the scans used to create the pRFs
% predicted = predictpRF(collated, collated.scan);

% Written by Kelly Chang - July 19, 2016

%% Input Control

if ~isfield(data, 'convStim')
    for i = 1:length(data)
        data(i).convStim = createConvStim(data(i), collated.hrf);
    end
end

scanExp = ones(1,length(collated.pRF));
if collated.opt.CSS
    scanExp = [collated.pRF.exp];
end

%% Initialize 'Predicted' Structure

nVox = length(data(1).voxID);
for i = 1:length(data)
    predicted(i).voxID = data(i).voxID;
    predicted(i).tc = data(i).vtc;
    predicted(i).pred = NaN(size(data(i).stimImg,1), nVox);
    predicted(i).corr = NaN(1,nVox);
end

%% Predict Time Course

for i = 1:length(data) % for each scan
    for i2 = 1:nVox % for each voxel
        if collated.pRF(i2).didFit % if the voxel was fitted
            model = feval(collated.opt.model, collated.pRF(i2), data(i).funcOf);
            predicted(i).pred(:,i2) = pos0(data(i).convStim * model(:)) .^ scanExp(i2);
            
            predicted(i).corr(i2) = callCorr(collated.opt.corr, predicted(i).tc(:,i2), ...
                predicted(i).pred(:,i2), data);
        end
    end
end