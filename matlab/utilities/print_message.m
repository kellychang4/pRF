function print_message(varargin)

quietFlag = get_global_variables('print.quiet');
str = varargin{1}; params = varargin(2:end); 
if ~quietFlag; fprintf(str, params{:}); end