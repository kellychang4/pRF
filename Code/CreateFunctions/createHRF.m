function [hrf] = createHRF(opt)
% [hrf] = createHRF(opt)
%
% Creates a 'hrf' structure containing parameters to creates a
% hemodynamic response function based on a gamma function:
%
% h(t) = ((t-delta)/tau).^(n-1).*exp(-(t-delta)/tau)/(tau*factorial(n-1));
%
% Inputs:
%   opt            A structure containing paramaters for creating the 'hrf'
%                  structure:
%       type       Specifies hrf type. There are canonical tau and delta's
%                  for 'vision' and 'audition'. Specifying no type forces
%                  tau and delta to be manually defined.
%       tau        Time constant, only used if no type specified
%       delta      Delay (seconds), only used if no type specified
%       dt         Time vector step size, seconds (default: 2)
%       n          Phase delay (Default: 3)
%       maxt       Ending time, seconds (Default: 30)
%
% Outputs:
%   hrf            A structure containing hrf information with fields:
%       n          Phase delay (opt.n)
%       dt         Time vector step size, seconds
%       t          Time vector (0:opt.dt:opt.maxt)
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
        error('Must be specified: %s', strjoin(errFlds, ', '));
    end
end

if ~isfield(opt, 'dt')
    opt.dt = 2;
end

if ~isfield(opt, 'n')
    opt.n = 3;
end

if ~isfield(opt, 'maxt')
    opt.maxt = 30;
end

%% Create 'hrf' Structure

hrf.n = opt.n;
hrf.dt = opt.dt;
hrf.t = 0:hrf.dt:opt.maxt;
switch opt.type
    case {'vision', 'vis', 'v', 1} % predefined hrf for vision
        hrf.tau = 1.5;
        hrf.delta = 2.25;
    case {'audition', 'auditory', 'aud', 'a', 2} % predefined hrf for audition (see Talvage)
        hrf.tau = 1.5;
        hrf.delta = 1.8;
    otherwise
        hrf.tau = opt.tau;
        hrf.delta = opt.delta;
end