function print_message(varargin)

opt = varargin{1}; str = varargin{2}; params = varargin(3:end); 

if ~opt.quiet
    fprintf(str, params{:}); 
end