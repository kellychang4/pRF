function [coeff] = callCorr(corrName, tc, pred, scan)
% [coeff] = callCorr(corrName, tc, pred, scan)
%
% Calls the specified correlation and returns the correlation coeffecient
% of the actual time course 'tc' and the predicted time course 'pred'
%
% If the called correlation on 'tc' and 'pred' has different lengths, then
% the predicted time course will be down sampled to match the actual 'tc'
% time course.
%
% Inputs:
%   corrName      Correlation name, also the function name, string
%   tc            Actual time course
%   pred          Predicted time course(s), each time course must be a
%                 column
%   scan          A structure containing scan information
%
% Output:
%   coeff         Output of the called model function with the given
%                 parameters given as a column

% Written by Kelly Chang - March 29, 2017

%% Down Sample if Needed

if length(tc) ~= size(pred,1)
    nanIndx = any(isnan(pred),1);
    tmp = cell(1,size(pred,2));
    tmp(nanIndx) = {NaN(size(tc))};
    tmp(~nanIndx) = cellfun(@(x) spline(lengthOut(0,scan.dt,length(x)),x,scan.t)', ...
        num2cell(pred(:,~nanIndx),1), 'UniformOutput', false);
    pred = cell2mat(tmp);
end

%% Call Correlation

coeff = feval(corrName, tc, pred);