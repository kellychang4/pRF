function [hrf] = createHRF(opt)
% [hrf] = createHRF(opt)
%
% METHOD 1: PARAMETERIZED HRF
% Creates a 'hrf' structure containing parameters to creates a
% hemodynamic response function based on a 'opt.func' function
%
% METHOD 3: PRE-DEFINED HRF
% Creates a 'hrf' structure based off a given pre-defined hemodynamic
% response function.
%
% Input:
% METHOD 1: PARAMETERIZED HRF
%   opt            A structure containing paramaters for creating the 'hrf'
%                  structure:
%       func       Name of the HRF function, string (default: 'BoyntonHRF')
%       dt         Time vector step size, seconds (default: 2)
%       maxt       Ending time, seconds (Default: 30)
%       type       Specifies hrf type - ONLY in use with BoyntonHRF. There
%                  are canonical tau and delta's for 'vision' and 'audition'.
%                  Specifying no type forces parameters tau and delta to be
%                  manually defined
%       tau        Time constant, only used if no type specified
%       delta      Delay (seconds), only used if no type specified
%       n          Phase delay (Default: 3)
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
%       func       Name of the alternative HRF function
%       <params>   Parameters of the alternative HRF function as given by
%                  'opt.func'
%       dt         Time vector step size, seconds
%       t          Time vector (0:opt.dt:opt.maxt)
%       freeList   List of free to fit parameters of the alternative HRF
%                  (default: 'func.params')
%
% METHOD 2: PRE-DEFINED HRF
%   hrf            A structure containing hrf information with fields:
%       hrf        The pre-defined hrf
%       t          Time vector of the hrf if not present before
%       dt         Time sampling rate if not present before, seconds
%
% Note:
% - Only parameterized HRFs can be estimated

% Written by Kelly Chang - May 23, 2016
% Edited for pre-defined hrf method by Kelly Chang - April 28, 2017

%% Input and Method Control

if ~exist('opt', 'var')
    opt = struct();
end

if ~isfield(opt,'hrf') && ~isfield(opt,'func')
    opt.func = 'BoyntonHRF';
end

method = find(ismember({'func','hrf'}, fieldnames(opt)));
switch method
    case 1 % parameterized hrf
        %% Input Control
        
        if ~isfield(opt, 'dt');
            error('''dt'' field must be specified');
        end
        
        if ~isfield(opt, 'maxt')
            opt.maxt = 30;
        end
        
        if ~strcmp(opt.func, 'BoyntonHRF') && isfield(opt, 'type')
            error('Cannot specify ''%s'' type with ''%s'' function', opt.type, opt.func);
        end
        
        paramNames = feval(opt.func);
        if isfield(opt, 'type') && any(ismember(paramNames.params, fieldnames(opt)))
            error('Cannot specify canonical parameters (''%s'') and manual parameters for HRF', opt.type);
        end
        
        if strcmp(opt.func, 'BoyntonHRF') && ~isfield(opt, 'n')
            opt.n = 3;
        end
        
        if ~all(ismember(paramNames.params, fieldnames(opt))) && ~isfield(opt, 'type')
            errFlds = paramNames.params(~ismember(paramNames.params, fieldnames(opt)));
            error('All parameters of %s must be specfied\nMissing: %s', opt.func, strjoin(errFlds, ', '));
        end
               
        if strcmp(opt.func, 'BoyntonHRF') && ~isfield(opt,'freeList')
            opt.freeList = {'tau', 'delta'};
        end
        
        if ~isfield(opt, 'freeList')
            opt.freeList = paramNames.params;
        end
        
        %% Calcuate Timing
        
        hrf.func = opt.func;
        hrf.dt = opt.dt;
        hrf.t = 0:hrf.dt:opt.maxt;
        
        %% Create 'hrf' Structure
        
        if strcmp(opt.func,'BoyntonHRF') && isfield(opt, 'type')
            switch opt.type
                case {'vision', 'vis', 'v', 1} % predefined hrf for vision
                    opt.tau = 1.5;
                    opt.delta = 2.25;
                case {'audition', 'auditory', 'aud', 'a', 2} % predefined hrf for audition (see Talvage)
                    opt.tau = 1.5;
                    opt.delta = 1.8;
            end
        end
        
        for i = 1:length(paramNames.params)
            hrf.(paramNames.params{i}) = opt.(paramNames.params{i});
        end
        hrf.freeList = opt.freeList;
        
    case 2 % pre-defined hrf
        %% Input Control
        if ~isfield(opt,'dt') && ~isfield(opt,'t')
            error('Either ''opt.dt'' or ''opt.t'' must be specified');
        end
        
        if ~isfield(opt, 'dt') && isfield(opt, 't')
            opt.dt = opt.t(2) - opt.t(1);
        end
        
        if ~isfield(opt, 't') && isfield(opt, 'dt')
            opt.t = 0:opt.dt:((length(opt.hrf)*opt.dt)-opt.dt);
        end
        
        %% Create 'hrf' Structure
        hrf = orderfields(opt, {'hrf', 'dt', 't'});
end