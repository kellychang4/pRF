function [params,err] = fitcon(funName, params, freeList, varargin)
% [params,err] = fitcon(funName, params, freeList, var1, var2, var3, ...)
%
% Helpful interface to matlab's 'fmincon' function.
%
% Inputs:
%   funName        Function to be optimized. Must have form
%                  [err] = <funName>(params, var1, var2, ...)
%
%   params         A structure of with field names with corresponding
%                  parameter values for fitted function. 'freeList'
%                  parameters must only have a singular value per parameter
%       options    A structure with options for fminsearch program
%                  (defaults: 'MaxFunEvals', 1e6, 'Display', off;
%                  see OPTIMSET)
%
%   freeList       Cell array containing list of parameter names (strings)
%                  to be free in fitting. Free strings can contain either
%                  variable names (as in 'fit.m'), or can contain
%                  inequalitites to restrict ranges. For example, the
%                  following are valid.
%
%                  {'x>0','x<pi','0<x','0>x>10','z>exp(1)','0<y<1'}
%
%   var<n>         Extra variables to be sent into fitted function
%
% Outputs:
%   params         A structure with best fitting parameters as fieldnames
%   err            Error value at minimum, numeric
%
% Notes:
% - Dependencies: params2varcon.m, var2params.m, fitFunction.m

% Written by Geoffrey M. Boynton, 9/26/14
% Adapted from 'fit.m' written by gmb in the summer of '00
% Edited by Kelly Chang, February 10, 2017

%% Input Control

if isfield(params,'options')
    options = params.options;
else
    options = optimset('fmincon');
    options = optimset(options, 'MaxFunEvals', 1e6, 'Display', 'off');
end

if isempty(freeList)
    freeList = fieldnames(params);
end

%% Turn Initial Free Parameters into vars, lower, and upper bounds

% turn free parameters in to vars, lower and upper bounds
[vars,lb,ub,varList] = params2varcon(params, freeList);

% call non-linear optimization fitting
vars = fminsearchcon('fitFunction',vars,lb,ub,[],[],[],options,funName,params,varList,varargin);

% assign final parameters into 'params'
params = var2params(vars, params, varList);

% evaluate the function 'funName' for error at minimum
err = fitFunction(vars, funName, params, varList, varargin);