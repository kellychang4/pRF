function [S] = structcat(varargin)
% [s] = structcat(s1, s2, s3, ...)
%
% Concatenates given structures into one structure containing all fields
% from the inputed structures
%
% Inputs:
%   s<n>            Structures to be concatenated, must all have the same
%                   length
%
% Output:
%   S               A concatenated structure created from the given 
%                   structures, will have the same length as the given                        
%                   structures. If there were matching field names across
%                   the given structure(s, will add an increment to the end
%                   of the field names with multiples

% Written  by Kelly Chang - June 21, 2016

%% Error Checking

structLen = unique(cellfun(@length, varargin));
if length(structLen) > 1
    error('All structures must have the same length');
end

%% Manipulate Fieldnames

flds = cellfun(@(x) fieldnames(x)', varargin, 'UniformOutput', false);
nFlds = cellfun(@length, flds);

nStruct = arrayfun(@(x,y) repmat(x,1,y), 1:length(varargin), nFlds, ...
    'UniformOutput', false);
nField = arrayfun(@(x) 1:x, nFlds, 'UniformOutput', false);
vals = arrayfun(@(x,y) sprintf('varargin{%d}(i).(flds{%d}{%d})',x,x,y), ...
    [nStruct{:}], [nField{:}], 'UniformOutput', false);

allFlds = [flds{:}];
indx = cellfun(@(x) sum(ismember(allFlds,x)), allFlds) > 1;
matchNames = unique(allFlds(indx));
matchIndx = cellfun(@(x) ismember(allFlds,x), matchNames, ...
    'UniformOutput', false);
matchCount = cellfun(@sum, matchIndx);
matchCount = arrayfun(@(x) 2:x, matchCount, 'UniformOutput', false);
anon = @(x,y) arrayfun(@(y) strcat(x,num2str(y)), y, 'UniformOutput', false);
matchNames = cellfun(@(x,y) [x anon(x,y)], matchNames, matchCount, ...
    'UniformOutput', false);
matchStr = arrayfun(@(x) sprintf('allFlds(matchIndx{%d})=matchNames{%d};',x, x), ...
    1:length(matchIndx), 'UniformOutput', false);
cellfun(@eval, matchStr);

%% Create Concatenated Structure

evalStr = strcat('''', allFlds, ''',', vals);
evalStr = ['struct(' strjoin(evalStr, ',') ')'];
for i = 1:structLen
    S(i) = eval(evalStr);
end