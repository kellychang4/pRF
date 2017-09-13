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
%       topHRF          Top proportion of voxels to be taken for HRF
%                       estimation, numeric (default: 0.1)
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
% - opt.topHRF + opt.hrfThr: If both options have a value, both methods
%                            will be implemented, such that after 
%                            thresholding, the top specified proportion of
%                            voxels will be taken for HRF estimation

% Written by Kelly Chang - June 23, 2016

%% Input Control

if ~exist('type', 'var') || isempty(type)
    type = 'default';
end

%% Create 'opt' Structure

switch lower(type)
    case {'retinotopy', 'retina', 'ret', 'r'}
        opt.map = 'Retinotopy';
        opt.model = 'Gaussian2D';
        opt.freeList = {'xMu', 'yMu', 'sigma'};
        opt.CSS = false;
        opt.roi = '';
        opt.estHRF = NaN;
        opt.topHRF = 0.1;
        opt.hrfThr = 0.25;
        opt.corrThr = 0.01;
        opt.corr = 'pearson';
        opt.cost = struct();
        opt.upSample = 1;
        opt.parallel = true;
        opt.quiet = false;
    case {'tonotopy', 'tono', 't'}
        opt.map = 'Tonotopy';
        opt.model = 'Gaussian1D';
        opt.freeList = {'mu', '0.01<sigma', '0<exp<1'};
        opt.CSS = true;
        opt.roi = '';
        opt.estHRF = NaN;
        opt.topHRF = 0.1;
        opt.hrfThr = 0.25;
        opt.corrThr = 0.01;
        opt.corr = 'pearson';
        opt.cost = struct();
        opt.upSample = 1;
        opt.parallel = true;
        opt.quiet = false;
    case 'default'
        opt.map = '';
        opt.model = 'Gaussian1D';
        opt.freeList = {'mu', 'sigma'};
        opt.CSS = false;
        opt.roi = '';
        opt.estHRF = NaN;
        opt.topHRF = 0.1;
        opt.hrfThr = 0.25;
        opt.corrThr = 0.01;
        opt.corr = 'pearson';
        opt.cost = struct();
        opt.upSample = 1;
        opt.parallel = true;
        opt.quiet = false;
    otherwise
        error('\nUnrecognized ''opt'' type: %s\n', type);
end