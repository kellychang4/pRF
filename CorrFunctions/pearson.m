function [coef] = pearson(x,y)
% [coef] = pearson(x,y)
%
% Calculates the Pearson cross correlation coefficient for x and y
% 
% Inputs: 
%   x           The first data series (column)
%   y           The second data series, a matrix which may contain one or
%               multiple columns
%
% Output:
%   coef        The Pearson correlation coefficient

% Written by Paola Binda - Feburary 11, 2012
% Edited by Kelly Chang for pRF fitting - June 21, 2016

%% Input Control

if size(x,1) ~= size(y,1)
    error('X and Y must have the same number of rows');
end

%% Calcuate Correlationn Coefficient

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
        
        x0 = xi - mean(xi);
        y0 = yi2 - mean(yi2);
        coef(i,i2) = (x0./norm(x0))' * (y0./norm(y0));    
    end
end
coef(coef > 1) = 1; 
coef(coef < -1) = -1; % min/max drops NaNs