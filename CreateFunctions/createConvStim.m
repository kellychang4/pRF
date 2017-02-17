function [convStim] = createConvStim(scan, hdr)
% [convStim] = createConvStim(scan, hdr)
%
% Calulates the hemodynamic response and find the convolution of the
% hemodynamic response with the stimulus
%
% Inputs:
%   scan            A structure containing all scan information, but must
%                   contain fields:
%       stimImg     The stimulus image as given by
%                   stimImg = createStimImg(scan, opt)
%       TR          The scan TR (seconds)
%       nVols       The number of volumes in the scan
%   hdr             A structure contain all hemodynamic response
%                   information as given by hdr = createHDR(hdrOpt)
%
% Outputs:
%   convStim        The convolution of the hemodynamic response (hdr) with
%                   the stimulus

% Written by Kelly Chang - June 21, 2016

%% Convolve Stimulus Image with HDR

hemo = GammaHDR(hdr, hdr)';
tmp = scan.TR * convn(scan.stimImg, hemo);
stimulusInterval = scan.dur / length(scan.paradigm);
if stimulusInterval == scan.TR % if stimulus time locked with TRs
    convStim(:,:) = tmp(1:scan.nVols, :);
else % else interpolate from stimulus time to TR time
    stimTiming = lengthOut(0, stimulusInterval, numel(scan.stimImg));
    volTiming = lengthOut(0, scan.TR, scan.nVols*size(scan.stimImg,2));
    tmp = spline(stimTiming(:), tmp(1:size(stimTiming,2)), volTiming(:));
    convStim = reshape(tmp, scan.nVols, []);
end