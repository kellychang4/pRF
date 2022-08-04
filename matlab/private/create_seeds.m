function [seeds] = create_seeds(options)
% [seeds] = create_seeds(options)

%%% ensure unique seeds values only
options = structfun(@unique, options, 'UniformOutput', false);

%%% initialize seed structure
flds = fieldnames(options); 
n = prod(structfun(@length, options));
seeds = initialize_structure(n, flds); 

%%% create ndgrid of all unique seeds
eval(sprintf('[options.%1$s] = ndgrid(options.%1$s);', ...
    strjoin(flds, ',options.')));

%%% assign each seed into 'seeds' structure
for i = 1:n % for each seed
    for f = 1:length(flds) % for each parameter        
        seeds(i).(flds{f}) = options.(flds{f})(i);
    end
end