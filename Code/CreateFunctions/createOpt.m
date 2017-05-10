function [opt] = createOpt(type)
% [opt] = createOpt(type)
%
% Creates a 'opt' structure initialized with all possible fields
% (see Outputs for the list of field names)
%
% Inputs:
%   <No arg>            Returns an 'opt' structure with all fields at
%                       default settings
%   type                Type of 'opt' structure that should be created.
%                       If specified, will return an 'opt' structure with
%                       fields with settings of the given pRF model 
%                       (i.e., Tonotopy)
%
% Outputs:
%   opt
%       map             Map name, string (i.e., 'Retinotopy', 'Tonotopy')
%                       (default: '')
%       model           Model name, also the function name to be fitted,
%                       string (default: 'Gaussian1D')
%       freeList        Free parameters to be estimated with opt.model,
%                       cell of strings (default: {'mu', 'sigma'})
%       roi             Name of the .voi if fitting a within a ROI, string
%                       (default: '')
%       estHRF          Number of iterations to estimate individual HRF. If
%                       NaN, will not estimate HRF, numeric (default: NaN)
%       hrfThr          Correlation threshold for voxels to be used in HRF
%                       estimation (default: 0.25)
%       corrThr         Correlation threshold of best seed fit for voxels 
%                       to be used in pRF fitting (default: 0.01)
%       corr            Name of the correlation to use as the measure of
%                       error during fitting, also the function name,
%                       string (default: 'pearson')
%       CSS             Fit exponential (true) OR not (false) from the 
%                       compressive spatial summation, logical 
%                       (default: false)
%       cost            A structure containing parameters that will be
%                       implemented in a cost function with fields that 
%                       correpond to the free parameters being estimated:
%       <parameter      A vector with the free parameter [minimum maximum]
%           name(s)>    boundaries in the cost function
%       upSample        The desired up-sampling factor to create a new
%                       resolution of the stimulus image (default: 1)
%       parallel        Parallel processing (true) OR not (false), logical
%                       (default: trues)
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

%% Create 'opt' Structure

flds = {'map', 'model', 'freeList', 'roi', 'estHRF', 'hrfThr', 'corrThr', ...
    'corr', 'CSS', 'cost', 'upSample', 'parallel', 'quiet'}; % field names

switch lower(type)
    case {'retinotopy', 'retina', 'ret', 'r'}
        vals = {'''Retinotopy''', '''Gaussian2D''', ...
            '{{''xMu'',''yMu'',''sigma''}}', '''''', 'NaN', '0.25', ...
            '0.01', '''pearson''', 'false', 'struct()', '1', 'true', 'false'};
    case {'tonotopy', 'tono', 't'}
        vals = {'''Tonotopy''', '''Gaussian1D''', ...
            '{{''mu'',''0.01<sigma'',''0<exp<1''}}', '''''', 'NaN', '0.25', ...
            '0.01', '''pearson''', 'true', 'struct()', '1', 'true', 'false'};
    case {'default'}
        vals = {'''''', '''Gaussian1D''', '{{''mu'',''sigma''}}', ...
            '''''', 'NaN', '0.25', '0.01', '''pearson''', 'false', ...
            'struct()', '1', 'true', 'false'};
end

evalStr = strcat('''', flds, '''', ',', vals);
evalStr = strcat('struct(', strjoin(evalStr,','), ');');
opt = eval(evalStr);