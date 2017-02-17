function [seeds] = createSeeds(opt)
% [seeds] = createSeeds(opt)
%
% Creates a 'seeds' structure with all the possible combinations of all the
% specified parameters passed through in the 'opt' argument. Each instance
% in the 'seeds' structure is a single combination out of all the possible
% combinations from the given parameters.
% Uses ndgrid() to create all possible combinations.
% Can handle free and fixed parameters.
%
% Inputs:
%   opt                  A structure containing fields for creating the 
%                        'seed' structure:
%       <parameter       A vector that specifies all possible seeds for 
%          name(s)>      the given <parameter name>, numeric
%                        (i.e., linespace(0.5, 4, 100))
%             
% Outputs:
%   seeds                A 1 x nSeeds structure containing all possible 
%                        seed combinations based on the given parameters:
%       <parameter       A seed combination based on the given parameters 
%           name(s)>     from opt.seedList
%                              
% Note:
% - Fixed parameters have a length of 1 (i.e., see Example 'exp')
%
% Example:
% opt.mu = linspace(2, 4, 21);
% opt.sigma = linspace(0.5, 4, 100);
% opt.exp = 0.5; % fixed parameter
%
% [seeds] = createSeeds(opt)

% Written by Kelly Chang - May 23, 2016

%% Create All Possible Seed Combinations

params = fieldnames(opt);
tmp = cellfun(@(x) sprintf('opt.%s',x), params, 'UniformOutput', false);
eval(sprintf('[%s]=ndgrid(%s);', strjoin(params, ','), strjoin(tmp, ',')));

nSeeds = prod(structfun(@length, opt));
for i = 1:nSeeds
    for i2 = 1:length(params)
        seeds(i).(params{i2}) = eval(sprintf('%s(i);', params{i2}));
    end
end