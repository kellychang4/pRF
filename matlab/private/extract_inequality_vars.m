function [str] = extract_inequality_vars(str)

if ischar(str); str = {str}; end
if ~iscell(str); error('Requires string or cell array of strings.'); end

tokens = parse_inequalities(str);
for i = 1:length(tokens) % for each parameter
    %%% one inequality symbol
    if ~isempty(tokens{i}) && isempty(tokens{i}.s2) 
       l = str2double(tokens{i}.l); 
       if isnan(l); str{i} = tokens{i}.l; 
       else; str{i} = tokens{i}.m; end
    %%% two inequality symbols
    elseif ~isempty(tokens{i}) && ~isempty(tokens{i}.r) 
        str{i} = tokens{i}.m;
    end
end