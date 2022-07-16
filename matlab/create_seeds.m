function [seeds] = create_seeds(options)
% [seeds] = create_seeds(options)
%
% Creates a 'seeds' structure with all the possible combinations of all the
% specified parameters passed through in the 'options' argument. Each instance
% in the 'seeds' structure is a single combination out of all the possible
% combinations from the given parameters.
% Uses ndgrid() to create all possible combinations.
% Can handle free and fixed parameters.
%
% Inputs:
%   options                  A structure containing fields for creating the 
%                        'seed' structure:
%       <parameter       A vector that specifies all possible seeds for 
%          name(s)>      the given <parameter name(s)>, numeric
%                        (i.e., linespace(0.5, 4, 100))
%             
% Outputs:
%   seeds                A 1 x nSeeds structure containing all possible 
%                        seed combinations based on the given parameters:
%       <parameter       A seed combination based on the given parameters 
%           name(s)>     from options.seedList
%                              
% Note:
% - Fixed parameters have a length of 1 (i.e., see Example 'exp')
%
% Example:
% optionsions.mu = linspace(2, 4, 21);
% optionsions.sigma = linspace(0.5, 4, 100);
% optionsions.exp = 0.5; % fixed parameter
%
% [seeds] = createSeeds(options)

% Written by Kelly Chang - May 23, 2016

%% Input Control

params = fieldnames(options);
if any(structfun(@(x) any(isnan(x)), options))
    errFlds = params(structfun(@(x) any(isnan(x)), options));
    error('''%s'' contain(s) NaNs', strjoin(errFlds, ''' & '''));
end

%% Create All Possible Seed Combinations

seeds = struct(); 
params = fieldnames(options);
nSeeds = prod(structfun(@length, options));
eval(sprintf('[options.%1$s]=ndgrid(options.%1$s);', ...
    strjoin(params, ',options.')));
for i = 1:nSeeds % for each seed
    for i2 = 1:length(params) % for each parameter        
        seeds(i).(params{i2}) = options.(params{i2})(i);
    end
end