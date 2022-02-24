function [var,lb,ub,varStr] = params2varcon(params, freeList)
% [var,lb,ub,varStr] = params2varcon(params, freeList)
%
% Extracts 'freeList' variables from the 'params' structure into 'var' 
% with corresponding field names only into 'varStr'. Extracts lower 'lb'
% and upper boundaries 'ub' of values 'var' from 'freeList' if specified.
% Support function for 'fitcon.m'. 
% 
% Inputs:
%   params      A structure of parameter values with field names that
%               correspond with the parameter names in 'freeList'
% 
%   freeList    Cell array containing list of parameter names (strings) to
%               be free strings in this cell array can contain  either
%               varable names, or they can contain inequalities to
%               restrict variable ranges. For example, the following are
%               valid.
%
%               {'x>0','x<pi','0<x','0>x>10','z>exp(1)','0<y<1'}
%
% Outputs:
%   var         Variable value(s) as given in 'params' structure
% 
%   lb          Lower boundary if given, else -Inf, numeric
% 
%   ub          Upper boundary if given, else Inf, numeric
% 
%   varStr      Variable name(s) as given in 'freeList' without
%               inequalities

% Written by G.M. Boynton on 9/26/14
% Adapted from 'params2var', written Summer of '00
% Rewritten by Kelly Chang, February 10, 2017

%% Evaluating 

freeList = regexprep(freeList, '[= ]*', ''); % remove spaces and '='
expr = '(?<l>[^<>]*)(?<s1>(<|>))(?<m>[^<>]*)(?<s2>(<|>))?(?<r>.*)?';
token = regexp(freeList, expr, 'names'); 

for i = 1:length(freeList)
    if isempty(token{i}) % no inequality symbols
        order = {'-Inf' 'Inf' 'freeList{i}'};
    elseif isempty(token{i}.s2) % one inequality symbol
        indx = cellfun(@(x) ~isempty(str2num(x)), struct2cell(token{i}));
        if indx(1) && strcmp(token{i}.s1,'>') % ub > var
            order = {'-Inf' 'str2num(token{i}.l)' 'token{i}.m'};
        elseif indx(1) && strcmp(token{i}.s1,'<') % lb < var
            order = {'str2num(token{i}.l)' 'Inf' 'token{i}.m'};
        elseif indx(3) && strcmp(token{i}.s1,'>') % var > lb
            order = {'str2num(token{i}.m)' 'Inf' 'token{i}.l'};
        elseif indx(3) && strcmp(token{i}.s1,'<') % var < ub
            order = {'-Inf' 'str2num(token{i}.m)' 'token{i}.l'};
        end
    elseif ~isempty(token{i}.r) % two inequality symbols
        if strcmp(token{i}.s2,'>') % ub > var > lb
            order = {'str2num(token{i}.r)' 'str2num(token{i}.l)' 'token{i}.m'};
        elseif strcmp(token{i}.s2,'<') % lb < var < ub
            order = {'str2num(token{i}.l)' 'str2num(token{i}.r)' 'token{i}.m'};
        end
    end
    varStr{i} = eval(order{3});
    numOrder = cellfun(@(x) regexprep(x,'[()]',''), regexp(varStr{i}, '(\(.*\))', 'match'));
    if isempty(numOrder)
        var{i} = params.(regexprep(varStr{i},'(\(.*\))',''));
    else
        var{i} = params.(regexprep(varStr{i},'(\(.*\))',''))(str2num(numOrder));
    end
    lb{i} = repmat(eval(order{1}),1,length(var{i}));
    ub{i} = repmat(eval(order{2}),1,length(var{i}));
end
lb = cell2mat(lb);
ub = cell2mat(ub);
var = cell2mat(var);