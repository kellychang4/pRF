function [out] = upper1(str)
% [out] = upper1(str)
%
% Returns the given string or cell array of strings with the first letter
% capitalized and the rest of the string in lower case.
% 
% Input:
%   str        A string or cell of strings to have the first letter
%              capitialize and the rest of the string in lower case
%
% Output:
%   out        A string or cell of strings with capitalized first letter
%              and rest of the string in lower case
%
% Examples:
% upper1('hello') % Hello
% upper1({'hello', 'world'}) % {'Hello', 'World'}

% Written by Kelly Chang - July 12, 2016

%% Input Control

if ~any([ischar(str) iscell(str)])
    error('Input must be a string or a cell array of strings');
end

if iscell(str) && ~all(cellfun(@ischar, str))
    error('All cell array elements must be a string');
end

%% Capitalize First Letter of String(s)

if ischar(str) && ~iscell(str)
    out = strcat(upper(str(1)), lower(str(2:end)));
else
    out = cellfun(@(x) strcat(upper(x(1)),lower(x(2:end))), str, ...
        'UniformOutput', false);
end