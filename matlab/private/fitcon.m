function [params,err] = fitcon(errorFunc, params, freeList, varargin)
% [params,err] = fitcon(errorFunc, params, freeList [, varargin])
%
% Inputs:
%   errorFunc      Error function to be minimized. Must have form
%                  [err] = <errorFunc>(params [, varargin])
%
%   params         A structure of with field names with corresponding
%                  parameter values for fitted function. 'freeList'
%                  parameters must only have a singular value per parameter
%
%   freeList       Cell array containing list of parameter names (strings)
%                  to be free in fitting. Free strings can contain either
%                  variable names (as in 'fit.m'), or can contain
%                  inequalitites to restrict ranges. For example, the
%                  following are valid.
%
%                  {'x>0','x<pi','0<x','0>x>10','z>exp(1)','0<y<1'}
%
%   var<n>         Extra variables to be sent into error function
%
% Outputs:
%   params         A structure with best fitting parameters as fieldnames
%   err            Error value at minimum, numeric
%
% Notes:
% - Dependencies: params2varcon.m, var2params.m, fit_function.m

% Written by Geoffrey M. Boynton, 9/26/14
% Adapted from 'fit.m' written by gmb in the summer of '00
% Edited by Kelly Chang, February 10, 2017
% Edited by Kelly Chang, July 15, 2022

%% Start Fitting Procedure

%%% fitting options
options = optimset('fmincon');
options = optimset(options, 'MaxFunEvals', 1e6, 'Display', 'off');

%%% turn free parameters in to vars, lower and upper bounds
[vars,lb,ub,varNames] = params2varcon(params, freeList);

%%% call non-linear optimization fitting
vars = fminsearchcon(@fit_function, vars, lb, ub, [], [], [], options, ...
    errorFunc, params, varNames, varargin);

%%% assign final parameters into 'params'
params = var2params(vars, params, varNames);

%%% evaluate the function 'errorFunc' for error at minimum
err = fit_function(vars, errorFunc, params, varNames, varargin);