function [coeff] = callCorr(corrName, tc, pred, scan)
% [coeff] = callCorr(corrName, tc, pred)
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
%   tc            Actual voxel time course 
%   pred          Predicted voxel time course
%   scan          A structure containing scan information
%
% Output:
%   coeff         Output of the called model function with the given
%                 parameters given as a column

% Written by Kelly Chang - March 29, 2017

%% Down Sample if Needed

if length(tc) ~= length(pred) 
    pred = spline(lengthOut(0, scan.dur/length(pred), length(pred)), pred, scan.t);
end

%% Call Correlation 

coeff = feval(corrName, tc(:), pred(:));