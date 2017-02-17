function [opt] = createOpt(type)
% [opt] = createOpt(type)
%
% Creates a 'opt' structure initialized with all possible fields
% (see Outputs for the list of field names)
%
% Inputs:
%   type                Type of 'opt' structure that should be created.
%                       If called with no type, the function will return an
%                       'opt' structure filled with the basic options for
%                       each field. There are also types for commonly used
%                       pRF fitting (i.e., 'Tonotopy')
%
% Outputs:
%   opt
%       map             Map name, string (i.e., 'Tonotopy') (default: '')
%       model           Model name, also the function name to be fitted,
%                       string (default: 'Gaussian1D')
%       freeList        Free parameters to be estimated with opt.model,
%                       cell of strings (default: {'mu', 'sigma'})
%       roi             Name of the .voi if fitting a within a ROI, string
%                       (default: '')
%       fitpRF          Fit pRF (true) OR find best seed (false), logical
%                       (default: true)
%       estHDR          Estimate individual HDR (true) OR not (false),
%                       logical (default: false)
%       CSS             Fit exponential (true) OR not (false) from the 
%                       compressive spatial summation, logical 
%                       (default: false)
%       corr            Name of the correlation to use as the measure of
%                       error during fitting, also the function name,
%                       string (default: 'pearson')
%       corrThr         Correlation threshold where anything below will not
%                       be fitted, numeric (default: 0.01)
%       nSamples        Desired resolution of the stimulus image, numeric
%                       (default: NaN)
%       parallel        Parallel processing (true) OR not (false), logical
%                       (default: false)
%       quiet           Output progress in command window when fitting
%                       (false) OR not (true), logical (default: false)
%
% Notes:
% - opt.CSS: Fits an exponential that accounts for non-linearities in a 
%            commpressive spatial summation model (see Kay et al., 2013)
% - If including a new 'type', please incoporate the new chunk of code
%   within the existing switch statement as additional case statement.

% Written by Kelly Chang - June 23, 2016

%% Input Control

if ~exist('type', 'var')
    type = 'default';
end

%% Load and Create 'opt' Structure

switch lower(type)
    case {'tonotopy', 'tono', 't'}
        vals = {'''Tonotopy''', '''Gaussian1D''', ...
            '{{''mu'',''0.01<sigma'',''0<exp<1''}}', '''''', 'true', ...
            'false', 'true', '''pearson''', '0.01', 'NaN', 'false', ...
            'false'};
    case {'default'}
        vals = {'''''', '''Gaussian1D''', '{{''mu'',''sigma''}}', ...
            '''''', 'true', 'false', 'false', '''pearson''', '0.01', 'NaN', ...
            'false', 'false'};
end

flds = {'map', 'model', 'freeList', 'roi', 'fitpRF', 'estHDR', 'CSS', ...
    'corr', 'corrThr', 'nSamples', 'parallel', 'quiet'};
evalStr = strcat('''', flds, '''', ',', vals);
evalStr = strcat('struct(', strjoin(evalStr,','), ');');
opt = eval(evalStr);