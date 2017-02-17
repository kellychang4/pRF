function [coef] = callCorr(x, y, corrName)
% [coef] = callCorr(x, y, corrName)
%
% Calculates the specified correlation coefficient for x and y
% 
% Inputs: 
%   x           The first data series (column)
%   y           The second data series, a matrix which may contain one or
%               multiple columns
%   corrName    Type of correlation to evaluate on x and y, also the
%               correlation function's script name, string
%
% Output:
%   coef        The correlation coefficient

% Written by Kelly Chang for pRF fitting - July 12, 2016

%% Call Correlation Function

coef = eval([corrName '(x,y);']);