function [params,err] = fitcon(funName, params, freeList, varargin)
% [params,err] = fitcon(funName, params, freeList, var1, var2, var3, ...)
%
% Helpful interface to matlab's 'fmincon' function.
%
% INPUTS
%  'funName': function to be optimized.
%             Must have form err = <funName>(params, var1, var2, ...)
%
%  params   : structure of parameter values for fitted function
%             can have field: params.options which sets options for
%             fminsearch program (see OPTIMSET)
%
%  freeList : cell array containing list of parameter names (strings) to be
%             free strings in this cell array can contain  either varable
%             names (as in 'fit.m'), or they can contain inequalities to
%             restrict variable ranges.  For example, the following are
%             valid.
%
%             {'x>0','x<pi','0<x','0>x>10','z(1:2)>exp(1)','0<y<1'}
%
%  var<n>   : extra variables to be sent into fitted function
%
% OUTPUTS
%  params   : structure for best fitting parameters
%  err      : error value at minimum
%
% Requires the functions:
%
% fitminsearchcon, params2varcon, var2params, fitFun

% Written by Geoffrey M. Boynton - September 26, 2014
% Adapted from 'fit.m' written by gmb - Summer 2000
% Edited by Kelly Chang for pRF package - June 21, 2016

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

if ischar(freeList) 
    freeList = {freeList};
end

%% Turn Initial Free Parameters into vars, lower, and upper bounds

% parse params into variables to use for 'fminsearchcon'
[vars,lb,ub,varList] = params2varcon(params, freeList);

% minimizing best params
vars = fminsearchcon('fitFun', vars, lb, ub, [], [], [], options, ...
    funName, params, varList, varargin);

% load final parameters
params = var2params(vars, params, varList);

% estimate err of final parameters
err = fitFun(vars, funName, params, varList, varargin);