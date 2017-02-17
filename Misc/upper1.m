function [out] = upper1(str)
% [out] = upper1(str)
%
% Returns the given string or cell of strings with the first letter of each
% capitalized and the rest of the string in lower case.
% 
% Inputs:
%   str        A string or cell of strings that will capitialize the first
%              letter and lower case the rest of the string
%
% Outputs:
%   out        A string or cell of strings with capitalized first letter
%              and rest of the string in lower case

% Written by Kelly Chang - July 12, 2016

%% Capitalize First Letter of String(s)

if ischar(str) && ~iscell(str)
    out = strcat(upper(str(1)), lower(str(2:end)));
else
    out = cellfun(@(x) strcat(upper(x(1)),lower(x(2:end))), str, ...
        'UniformOutput', false);
end