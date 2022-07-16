function [str] = capitalize(str)

str = [upper(str(1)) lower(str(2:end))];