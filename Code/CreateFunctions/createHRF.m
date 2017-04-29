function [hrf] = createHRF(opt)
% [hrf] = createHRF(opt)
%
% METHOD 1: PARAMETERIZED HRF
% Creates a 'hrf' structure containing parameters to creates a
% hemodynamic response function based on a gamma function:
%
% h(t) = ((t-delta)/tau).^(n-1).*exp(-(t-delta)/tau)/(tau*factorial(n-1))
%
% METHOD 2: PRE-DEFINED HRF
% Creates a 'hrf' structure based off a given pre-defined hemodynamic
% response function.
%
% Input:
% METHOD 1: PARAMETERIZED HRF
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
% METHOD 2: PRE-DEFINED HRF
%   opt            A structure containing the pre-defined hrf and time or
%                  time sampling information for creating the 'hrf'
%                  structure:
%       hrf        The pre-defined hemodynamic response function
%       t          Time vector for the pre-defined hrf (default:
%                  0:opt.dt:((length(opt.hrf)*opt.dt)-opt.dt) is 'opt.dt'
%                  is passed)
%       dt         Time sampling rate, seconds (default: calculated if
%                  'opt.t' is passed)
%
% Output:
% METHOD 1: PARAMETERIZED HRF
%   hrf            A structure containing hrf information with fields:
%       n          Phase delay (opt.n)
%       dt         Time vector step size, seconds
%       t          Time vector (0:opt.dt:opt.maxt)
%       tau        Time constant, either a canonical tau for vision or
%                  audition or manually specified
%       delta      Delay (seconds), either a canonical tau for vision or
%                  audition or manually specified
%
% METHOD 2: PRE-DEFINED HRF
%   hrf            A structure containing hrf information with fields:
%       hrf        The pre-defined hrf
%       t          Time vector of the hrf if not present before
%       dt         Time sampling rate if not present before, seconds


% Written by Kelly Chang - May 23, 2016
% Edited for pre-defined hrf method by Kelly Chang - April 28, 2017

%% Method Control

if isfield(opt,'tau') && isfield(opt,'delta')
    opt.type = 'manual';
end

if ~isfield(opt,'type') && ~isfield(opt,'hrf')
    error('Missing either field ''type'' (Method 1) or ''hrf'' (Method 2)');
end

method = find(ismember({'type', 'hrf'}, fieldnames(opt)));
switch method
    case 1 % parameterized hrf
        %% Input Control
        
        if ~isfield(opt, 'dt');
            error('''dt'' field must be specified');
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
    case 2 % pre-defined hrf
        %% Input Control 
        if ~isfield(opt, 'dt') && isfield(opt, 't')
            opt.dt = opt.t(2) - opt.t(1);
        end
        
        if ~isfield(opt, 't') && isfield(opt, 'dt');
            opt.t = 0:opt.dt:((length(opt.hrf)*opt.dt)-opt.dt);
        end
        
        %% Create 'hrf' Structure
        hrf = orderfields(opt, {'hrf', 't', 'dt'});
end