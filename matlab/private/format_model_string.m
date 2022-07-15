function [str] = format_model_string(str)

%%% delete spaces and transform to lower case
str = lower(regexprep(str, ' ', '')); 
