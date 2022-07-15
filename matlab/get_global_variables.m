function [opt] = get_global_variables(varargin)

global GLOBAL_PARAMETERS;

switch nargin
    case 1
        opt = eval(sprintf('GLOBAL_PARAMETERS.%s', varargin{1})); 
    otherwise
        outFld = cellfun(@fld2var, varargin, 'UniformOutput', false);
        for i = 1:nargin % for each argument
            evalStr = sprintf('GLOBAL_PARAMETERS.%s', varargin{i});
            opt.(outFld{i}) = eval(evalStr);
        end
end