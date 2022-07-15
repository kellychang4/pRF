function [var] = fld2var(fld)

str = strsplit(fld, '.');
str(2:end) = cellfun(@capitalize, str(2:end), 'UniformOutput', false);
var = strjoin(str, ''); 