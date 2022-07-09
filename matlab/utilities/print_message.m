function print_message(varargin)

global GLOBAL_PARAMETERS;

str = varargin{1}; params = varargin(3:end); 

if ~GLOBAL_PARAMETERS.print.quiet
    fprintf(str, params{:}); 
end