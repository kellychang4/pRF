function [tokens] = parse_inequalities(str)

str = regexprep(str, '[= ]*', ''); % remove spaces and '='
expr = '(?<l>[^<>]*)(?<s1>(<|>))(?<m>[^<>]*)(?<s2>(<|>))?(?<r>.*)?';
tokens = regexp(str, expr, 'names'); 