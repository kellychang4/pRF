function [coef] = spearman(x,y)
% [coef] = spearman(x,y)
%
% Calculates the Spearman rank correlation coefficient for x and y
%
% Inputs:
%   x           The first data series (column)
%   y           The second data series, a matrix which may contain one or
%               multiple columns
%
% Output:
%   coef        The Spearman rank correlation coefficient

% Written by Kelly Chang - July 18, 2016

%% Input Control

if size(x,1) ~= size(y,1)
    error('X and Y must have the same number of rows');
end

%% Calculate Correlation Coefficient

n = size(x,1);
outClass = superiorfloat(x,y);
coef = zeros(1, size(y,2), outClass);
for i = 1:size(x,2) % loop through x columns
    for i2 = 1:size(y,2) % loop through y columns
        xi = x(:,i);
        yi2 = y(:,i2);
        
        if ~all(~(isnan(xi) | isnan(yi2)))
            coef(i,i2) = NaN;
            continue
        end
        
        rankXi = tiedrank(xi); % rank of x
        rankYi2 = tiedrank(yi2); % rank of y
        
        coef(i,i2) = 1 - ((6*sum((rankXi-rankYi2).^2)) / (n*((n^2)-1)));
    end
end