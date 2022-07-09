function [varargout] = get_global_variables(varargin)

global GLOBAL_PARAMETERS;

varargout = cell(1, nargin); 
for i = 1:nargin
    evalStr = sprintf('GLOBAL_PARAMETERS.%s', varargin{i});
    varargout{i} = eval(evalStr);
end