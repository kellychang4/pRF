function [params,err] = fitcon(funName, params, freeList, varargin)

options = optimset('fmincon');
options = optimset(options, 'MaxFunEvals', 1e6, 'Display', 'off');

% parse params into variables to use for 'fminsearchcon'
[vars,lb,ub,varList] = params2varcon(params, freeList);

% minimizing best params
vars = fminsearchcon('fitFunction', vars, lb, ub, [], [], [], options, ...
    funName, params, varList, varargin);

% load final parameters
params = var2params(vars, params, varList);

% estimate err of final parameters
err = fitFun(vars, funName, params, varList, varargin);
end

function [err] = fitFunction(var, funName, params, freeList, origVarargin)
% Calling Specified Function to be Fitted
params = var2params(var, params, freeList); % stick values of var into params
if ~isempty(origVarargin)
    tmp = arrayfun(@(x) sprintf('origVarargin{%d}',x), 1:length(origVarargin), ...
        'UniformOutput', false); % organize evaluation string for origVarargin
    err = eval(sprintf('%s(params,%s);', funName, strjoin(tmp, ','))); % evaluate the function
else
    err = eval(sprintf('%s(params);', funName));
end
end

function [params] = var2params(var, params, freeList)
for i = 1:length(freeList)
    params.(freeList{i}) = var(i);
end
end

function [var,lb,ub,varStr] = params2varcon(params, freeList)
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
    lb(i) = eval(order{1});
    ub(i) = eval(order{2});
    varStr{i} = eval(order{3});
    var(i) = params.(varStr{i});
end
end