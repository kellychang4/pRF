function [stats] = nestedF(model1, model2)
% [stats] = nestedF(model1, model2)
%
% Computes the F-statistics and p-value for each voxel using a nested
% F-test. Model 1 must be simpler (fewer parameters estimated) and nested
% within model 2 for this test be valid.
%
% Input:
%   model1          Output of [collated] = estpRF() for the simpler model
%   model2          Output of [collated] = estpRF() for the complex model
%
% Output:
%   stats           A structure containing voxel id(s), F-statistic(s), and
%                   p-value(s) for each voxel after a nested F-test

% Written by Kelly Chang - February 2, 2017

%% Error Checking

if ~isequal([model1.pRF.id], [model2.pRF.id])
    error('Voxels between the two models are not identical');
end

if ~isequal(model1.scan(1).nVols, model2.scan(1).nVols)
    error('Number of volumes between the two models are not identical');
end

if length(model2.opt.freeList) < length(model1.opt.freeList)
    error('Model 2 has fewer parameters (simpler) than Model 1');
end

if ~all(ismember(regexprep(model1.opt.freeList, '[^A-Za-z]', ''), ...
        regexprep(model2.opt.freeList, '[^A-Za-z]', '')))
    errParams = model1.opt.freeList(~ismember(regexprep(model1.opt.freeList, '[^A-Za-z]', ''), ...
        regexprep(model2.opt.freeList, '[^A-Za-z]', '')));
    error('Model 1 is not nested within Model 2\nUnknown Model 1 Parameter(s): %s', ...
        strjoin(errParams, ', '));
end

%% Extract Information from Model 1 (Simple) and Model 2 (Complex)

n = model1.scan(1).nVols;
r1 = [model1.pRF.corr];
p1 = length(model1.opt.freeList);

r2 = [model2.pRF.corr];
p2 = length(model2.opt.freeList);

%% Calculate Nested F Test Statistics

stats.id = [model1.pRF.id];
stats.F = (((r2.^2)-(r1.^2))/(p2-p1)) ./ ((1-(r2.^2))/(n-p2));
stats.p = 1 - fcdf(stats.F, p2-p1, n-p2);