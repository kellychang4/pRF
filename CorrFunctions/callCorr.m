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
    tmp = zeros(scan.nVols, size(pred,2));
    for i = 1:size(pred,2)
        tmp(:,i) = spline(lengthOut(0, scan.dur/size(pred,1), size(pred,1)), pred(:,i), scan.t);
    end
    pred = tmp;
end

%% Call Correlation

coeff = feval(corrName, tc, pred);