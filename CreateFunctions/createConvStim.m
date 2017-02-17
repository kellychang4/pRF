function [convStim] = createConvStim(scan, hrf)
% [convStim] = createConvStim(scan, hrf)
%
% Calulates the hemodynamic response and outputs the convolution of the
% hemodynamic response with the stimulus as a 2D matrix, regardless of how
% many stimuli dimensions there are
%
% Inputs:
%   scan            A structure containing all scan information, but must
%                   contain fields:
%       stimImg     The stimulus image as given by
%                   stimImg = createStimImg(scan, opt)
%       TR          The scan TR (seconds)
%       nVols       The number of volumes in the scan
%       paradigm    A structure contain the paradigm sequences for each
%                   stimulus dimension
%   hrf             A structure contain all hemodynamic response
%                   information as given by hrf = createHRF(hrfOpt)
%
% Outputs:
%   convStim        The convolution of the hemodynamic response function
%                   (hrf) with the stimulus

% Written by Kelly Chang - June 21, 2016

%% Convolve Stimulus Image with HRF

hemo = GammaHRF(hrf, hrf);
tmp = scan.TR * convn(scan.stimImg, hemo(:));
stimInterval = scan.dur / unique(structfun(@length, scan.paradigm));
if stimInterval == scan.TR % if stimulus time locked with TRs
    convStim = eval(sprintf('tmp(1:scan.nVols%s);', repmat(',:',1,ndims(tmp)-1)));
else % else interpolate from stimulus time to TR time
    stimSize = size(scan.stimImg);
    tmp = eval(sprintf('tmp(1:stimImgSize(1)%s);', repmat(',:',1,ndims(tmp)-1)));
    stimTiming = lengthOut(0, stimInterval, numel(tmp));
    volTiming = lengthOut(0, scan.TR, scan.nVols*prod(stimSize(2:end)));
    convStim = spline(stimTiming(:), tmp(:), volTiming(:));
    convStim = eval(sprintf('reshape(convStim,[scan.nVols %s]);', strjoin(arrayfun(@(x) ...
        sprintf('stimSize(%d)',x), 2:ndims(scan.stimImg), 'UniformOutput', false), ' ')));
end
tmp = size(convStim);
convStim = reshape(convStim, [tmp(1) prod(tmp(2:end))]);