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
convStim(:,:) = tmp(1:scan.nVols, :);