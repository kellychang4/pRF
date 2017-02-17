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
%       <parameter       Statement that specifies all possible seeds for 
%          name(s)>      the given <parameter name>, string 
%                        (i.e., 'linespace(0.5, 4, 100);')
%             
%                          
%
% Outputs:
%   seeds                A 1xnSeeds structure containing all possible seed 
%                        combinations based on the given parameters:
%       <parameter       A seed combination based on the given parameters 
%           name(s)>     from opt.seedList
%                              
% Note:
% - Fixed parameters have a length of 1 (i.e., see Example 'exp')
%
% Example:
% opt.mu = 'linspace(2, 4, 21);';
% opt.sigma = 'linspace(0.5, 4, 100);';
% opt.exp = '0.5;'; % fixed parameter
%
% [seeds] = createSeeds(opt)

% Written by Kelly Chang - May 23, 2016

%% Parameter Names

seedList = fieldnames(opt);

%% Create 1D Vectors of Each Parameter's Seeds

for i = 1:length(seedList)
    eval([seedList{i} '=' getfield(opt, seedList{i}) ';']);
    eval(['indx(i)=length(' seedList{i} ');']);
end

%% Separate Free vs. Fixed Parameters

fixNames = seedList(indx == 1);

freeNames = seedList(indx > 1);
freeLists = strcat(freeNames, 'List');

%% Create All Possible Seed Combinations (Free Parameters)

nSeed = 1;
if ~isempty(freeNames)
    eval(['[' strjoin(freeLists, ',') ']=ndgrid(' strjoin(freeNames, ',') ');']);
    
    % flatten into 1D vectors
    for i = 1:length(freeLists)
        eval([freeLists{i} '=' freeLists{i} '(:);']);
    end
    
    nSeed = eval(['size(' freeLists{1} ',1);']); % number of seeds
    for i = 1:nSeed
        for i2 = 1:length(freeLists)
            seeds(i).(freeNames{i2}) = eval([freeLists{i2} '(i)']);
        end
    end
end

%% Create All Possible Seed Combinations (Fixed Parameters)

for i = 1:nSeed
    for i2 = 1:length(fixNames)
        seeds(i).(fixNames{i2}) = eval(fixNames{i2});
    end
end