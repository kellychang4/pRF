function [out] = callModel(model, params, funcOf)
% [out] = callModel(model, params, funcOf)
%
% Calls the specified model and returns the model function output as given 
% with the specified paramaters 'params' as a function of 'funcOf'.
%
% If the called model function has more than one dimension, M, automatically 
% computes the model function of parameters into M coordinate dimensional 
% space, still outputs as a column vector
% 
% Inputs:
%   model         Model name, also the function name, string
%   params        A structure that specifes the parameters of the called
%                 function, for more information see the called model 
%   funcOf        A structure that speficies the dimensions of the called
%                 function, for more information see the called model
%
% Output:
%   out           Output of the called model function with the given
%                 parameters given as a column

% Written by Kelly Chang - October 17, 2016

%% Call Model

paramNames = eval(model);
if length(paramNames.funcOf) > 1 % greater than 1D
    eval(sprintf('[funcOf.%s]=meshgrid(funcOf.%s);',...
        strjoin(fliplr(paramNames.funcOf), ',funcOf.'), ...
        strjoin(fliplr(paramNames.funcOf), ',funcOf.')))
end
out = feval(model, params, funcOf); 