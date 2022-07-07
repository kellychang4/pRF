function [str] = capitalize(str)

if ~ischar(str); error('has to be string.'); end

str = [upper(str(1)) lower(str(2:end))];