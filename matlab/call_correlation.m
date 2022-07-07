function [coeff] = call_correlation(corrName, tc, pred, scan)
% [coeff] = call_correlation(corrName, tc, pred, scan)
%
% Calls the specified correlation and returns the correlation coeffecient
% of the actual time course 'tc' and the predicted time course 'pred'
%
% If the called correlation on 'tc' and 'pred' has different lengths, then
% the predicted time course will be sampled to match the actual 'tc' time
% course.
%
% Inputs:
%   corrName      Correlation name, also the function name, string
%   tc            Actual time course
%   pred          Predicted time course(s), each time course must be a
%                 column
%   scan          A structure containing scan information
%
% Output:
%   coeff         Correlation coefficient(s) of the given correlation 
%                 method for each column of the predicted time course(s),
%                 'pred'

% Written by Kelly Chang - March 29, 2017

%% Input Control and Timing Interpolation

if length(tc) ~= size(pred,1)
    tStim = lengthOut(0, scan.dt, size(pred,1)); % stimulus time vector
    nanIndx = any(isnan(pred),1); % find columns with NaNs
    tmp = cell(1,size(pred,2)); % initialize cell array for predicted
    tmp(~nanIndx) = cellfun(@(x) spline(tStim, x, scan.t)', ...
        num2cell(pred(:,~nanIndx),1), 'UniformOutput', false); % interpolate
    tmp(nanIndx) = {NaN(length(tc),1)}; % replace NaNs
    pred = cell2mat(tmp);
end

%% Call Correlation

coeff = feval(corrName, tc, pred);