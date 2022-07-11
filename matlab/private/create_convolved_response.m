function [convResp] = create_convolved_response(scan, hrf)
% [convResp] = create_convolved_response(scan, hrf)
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
%       dt          The scan image time steps, numeric (seconds)
%       nVols       The number of volumes in the scan
%   hrf             A structure contain all hemodynamic response
%                   information as given by hrf = createHRF(hrfOpt)
%
% Outputs:
%   convResp        The convolution of the hemodynamic response function
%                   (hrf) with the stimulus

% Written by Kelly Chang - June 21, 2016

%% Input Control and Timing Interpolation

if isfield(hrf, 'fit') % if fitted, use fitted hrf paramaters
    for i = 1:length(hrf.freeList)
        hrf.(hrf.freeList{i}) = hrf.fit.(hrf.freeList{i});
    end
end

%%% resample hrf to stimulus temporal resolution
if isfield(hrf, 'hrf') % pre-defined hrf 
    hemo = spline(hrf.t, hrf.hrf, min(hrf.t):scan.dt:max(hrf.t));
elseif ~isfield(hrf, 'hrf') % paramaterized hrf
    hemo = feval(hrf.funcName, hrf, min(hrf.t):scan.dt:max(hrf.t));
end

%% Convolve Model Response with HRF

tmp = scan.dt * convn(scan.modelResp, hemo(:));
convResp = eval(sprintf('tmp(1:size(scan.stimImg,1)%s);', repmat(',:',1,ndims(tmp)-1)));
convResp = reshape(convResp, size(scan.stimImg,1), []);