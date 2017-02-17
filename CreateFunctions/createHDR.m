function [hdr] = createHDR(opt)
% [hdr] = createHDR(hdr)
%
% Creates a structure 'hdr' containing parameters to creates a
% hemodynamic response function based on a gamma function:
%
% h(t) = ((t-delta)/tau).^(n-1).*exp(-(t-delta)/tau)/(tau*factorial(n-1));
%
% Inputs:
%   opt            A structure containing paramaters for creating the 'hdr'
%                  structure:
%       type       Specifies hdr type. There are canonical tau and delta's
%                  for 'vision' and 'audition'. Specifying no type allows
%                  tau and delta to be manually defined.
%       tau        Time constant, only used if no type specified
%       delta      Delay (seconds), only used if no type specified
%       TR         Scan TR (seconds), time vector step size
%       n          Phase delay (Default: 3)
%       maxt       Ending time, seconds (Default: 30)
%
% Outputs:
%   hdr            A structure containing hdr information with fields:
%       n          Phase delay (opt.n)
%       dt         Time vector step size (opt.TR)
%       t          Time vector (0:opt.TR:opt.maxt)
%       tau        Time constant, either a canonical tau for vision or
%                  audition or manually specified
%       delta      Delay (seconds), either a canonical tau for vision or
%                  audition or manually specified

% Written by Kelly Chang - May 23, 2016

%% Input Control

if ~isfield(opt, 'type')
    opt.type = '';
    if ~all(ismember({'tau', 'delta'}, fieldnames(opt)))
        errFlds = setdiff({'tau', 'delta'}, fieldnames(opt));
        error(sprintf('Must be specified: %s', strjoin(errFlds, ', ')));
    end
end

if ~isfield(opt, 'TR')
    error('Must specify opt.TR');
end

if ~isfield(opt, 'n')
    opt.n = 3;
end

if ~isfield(opt, 'maxt')
    opt.maxt = 30;
end

%% Create 'hdr' Structure

hdr.n = opt.n;
hdr.dt = opt.TR;
hdr.t = 0:opt.TR:opt.maxt;
switch opt.type
    case {'vision', 'vis', 1} % predefined hdr for vision
        hdr.tau = 1.5;
        hdr.delta = 2.25;
    case {'audition', 'aud', 2} % predefined hdr for audition (see Talvage)
        hdr.tau = 1.5;
        hdr.delta = 1.8;
    otherwise
        hdr.tau = opt.tau;
        hdr.delta = opt.delta;
end