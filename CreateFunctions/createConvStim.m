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
convStim = eval(sprintf('tmp(1:size(scan.stimImg,1)%s);', repmat(',:',1,ndims(tmp)-1)));
convStim = reshape(convStim, size(convStim,1), []);