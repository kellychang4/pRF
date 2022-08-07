function [err] = fit_function(vars, errorFunc, params, freeList, origVarargin)
% [err] = fit_function(vars, errorFunc, params, freeList, origVarargin)

% Adapted from 'fitFunction.m' written by gmb - Summer 2000
% Edited by Kelly Chang for pRF package - June 21, 2016

%% Calling Specified Function to be Fitted

% store values of 'var' into 'params'
params = var2params(vars, params, freeList);

% evaluate the error function
err = double(errorFunc(params, origVarargin{:}));