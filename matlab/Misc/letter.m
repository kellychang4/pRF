function [out] = letter(n, letterCase)
% [out] = letter(n, letterCase)
%
% Returns an alpha code based on the given 'n' integer. The alpha code is
% constructed from the position the a letter occupies in the English
% alphabet. As 'n' increases, the code with cycle through the alphabet.
% Once 'n' exceeds the letters in the alphabet, the code will add another
% letter and then continue to cycle through the alphabet.
%
% Inputs:
%   n               An integer that specifies which alpha code
%   letterCase      Upper or lower case, function handle (default: @lower)
%
% Outputs:
%   out             Specified alpha code based on 'n'
%
% Examples:
% letter(1) % a
% letter(2) % b
% letter(27) % aa
% letter(28) % ab

% Written by Kelly Chang - June 27, 2016

%% Input Control

if ~exist('letterCase', 'var')
    letterCase = @lower;
end

%% Create Alphabetical Code

alphabet = 'abcdefghijklmnopqrstuvwxyz';

if n < 0
    error('n must be greater than 0');
elseif n > length(alphabet)
    raise = cumsum(length(alphabet) .^ (1:100));
    raise = sum(n > raise) + 1;
    unit = length(alphabet) .^ (1:raise);
    
    place = n;
    for i = 1:(raise-1)
        tmp = mod(1:n, unit(i));
        place(i+1) = sum(tmp(1:(end-1)) == 0);
    end
    
    place = mod(place, length(alphabet));
    place(place == 0) = length(alphabet);
    out = alphabet(fliplr(place));
else
    out = alphabet(n);
end

out = letterCase(out);