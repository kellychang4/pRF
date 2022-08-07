function [varargout] = get_global_parameters(varargin)

global GLOBAL_PARAMETERS;

sprintfEval = @(x) sprintf('GLOBAL_PARAMETERS.%s', x); 

if nargin == nargout
    varargout = cell(1, nargout); 
    for i = 1:nargout
        varargout{i} = eval(sprintfEval(varargin{i}));
    end
elseif nargin > 1 && nargout == 1
    %%% assign all inputs to field of output variable
    outFld = cellfun(@fld2var, varargin, 'UniformOutput', false);
    for i = 1:nargin % for each argument
        varargout{1}.(outFld{i}) = eval(sprintfEval(varargin{i}));
    end
end
        
   
        
   