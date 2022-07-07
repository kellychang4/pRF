function [varargout] = get_global_variables(varargin)

global GLOBAL_PARAMETERS;

for i = 1:nargin
    varargout{i} = GLOBAL_PARAMETERS.(varargin{i});
end