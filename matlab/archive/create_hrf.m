function [hrf] = create_hrf(opt)
% [hrf] = create_hrf(opt)
%
% METHOD 1: PARAMETERIZED HRF
% Creates a 'hrf' structure containing parameters to creates a
% hemodynamic response funcNametion based on a 'opt.funcName' funcNametion
%
% METHOD 2: PRE-DEFINED HRF
% Creates a 'hrf' structure based on a given pre-defined hemodynamic
% response funcNametion.
%
% Input:
% METHOD 1: PARAMETERIZED HRF
%   opt            A structure containing paramaters for creating the 'hrf'
%                  structure:
%       funcName   Name of the HRF function, string (default: 'hrf_boynton')
%       dt         Time vector step size, seconds (default: 2)
%       maxt       Ending time, seconds (Default: 30)
%       type       Specifies hrf type - ONLY used with hrf_boynton. There
%                  are canonical tau and delta's for 'vision' and 'audition'.
%                  Specifying no type forces parameters tau and delta to be
%                  manually defined, string
%    <parameter    Manually defined HRF function parameters values, numeric
%         names>
%
% METHOD 2: PRE-DEFINED HRF
%   opt            A structure containing the pre-defined hrf and time or
%                  time sampling information for creating the 'hrf'
%                  structure:
%       hrf        The pre-defined hemodynamic response funcNametion
%       t          Time vector for the pre-defined hrf (default:
%                  0:opt.dt:((length(opt.hrf)*opt.dt)-opt.dt) is 'opt.dt'
%                  is passed)
%       dt         Time sampling rate, seconds (default: calculated if
%                  'opt.t' is passed)
%
% Output:
% METHOD 1: PARAMETERIZED HRF
%   hrf            A structure containing hrf information with fields:
%       funcName       Name of the alternative HRF funcNametion
%       <params>   Parameters of the alternative HRF funcNametion as given
%                  by 'opt.funcName'
%       dt         Time vector step size, seconds
%       t          Time vector (0:opt.dt:opt.maxt)
%       freeList   List of free to fit parameters of the alternative HRF
%                  (defaults:
%                       - hrf_boynton: tau, delta
%                       - hrf_twogamna: delta, c, a1, a2)
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

if ~isfield(opt, 'funcName') && ~isfield(opt, 'hrf') 
    opt.funcName = 'hrf_boynton';
end

method = find(ismember({'funcName','hrf'}, fieldnames(opt)));
switch method
    case 1 % parameterized hrf
        %% Input Control  
        
        if ~isfield(opt, 'dt')
            error('''dt'' field must be specified');
        end
        
        if ~strcmp(opt.funcName, 'hrf_boynton') && isfield(opt, 'type')
            error('Cannot specify type ''%s'' with the ''%s'' function', opt.type, opt.funcName);
        end
        
        if strcmp(opt.funcName, 'hrf_boynton') && ~isfield(opt, 'n')
            opt.n = 3;
        end
        
        flds = fieldnames(opt);
        params = feval(opt.funcName);
        if isfield(opt, 'type') && any(ismember(params, setdiff(flds, 'n')))
            errFlds = params(ismember(params, setdiff(flds, 'n')));
            error('Cannot specify both canonical parameters (''%s'') and manual parameters (''%s'') for HRF', ...
                opt.type, strjoin(errFlds, ''', '''));
        end
        
        if any(~ismember(flds, [{'funcName', 'dt', 'type', 't', 'freeList'}, params]))
            errFlds = flds(~ismember(flds, [{'funcName', 'dt', 'type', 't', 'freeList'}, params]));
            error('Unrecognized parameter for %s: %s', opt.funcName, strjoin(errFlds, ', '));
        end
        
        if strcmp(opt.funcName, 'hrf_boynton') && ~all(ismember(params, flds)) && ~isfield(opt, 'type')
            errFlds = params(~ismember(params, fieldnames(opt)));
            error('All parameters for the %s must be specfied\nMissing: %s', opt.funcName, strjoin(errFlds, ', '));
        end
        
        if strcmp(opt.funcName, 'hrf_boynton') && ~isfield(opt, 'freeList')
            opt.freeList = {'tau', 'delta'};
        end
        
        if ~isfield(opt, 'freeList')
            opt.freeList = params;
        end
        
        if ~all(ismember(opt.freeList, params))
            errFlds = opt.freeList(~ismember(opt.freeList, params));
            error('Unrecognized parameter for %s freeList: %s', opt.funcName, strjoin(errFlds, ', '));
        end
        
        if ~isfield(opt, 'maxt')
            opt.maxt = 30;
        end
        
        %% Calcuate Timing
        
        hrf.funcName = opt.funcName;
        hrf.dt = opt.dt;
        hrf.t = 0:hrf.dt:opt.maxt;
        hrf.freeList = opt.freeList;
        
        %% Create 'hrf' Structure
        
        if strcmp(opt.funcName,'hrf_boynton') && isfield(opt, 'type')
            switch opt.type
                case {'vision', 'vis', 'v', 1} % predefined hrf for vision
                    opt.tau = 1.5;
                    opt.delta = 2.25;
                case {'audition', 'auditory', 'aud', 'a', 2} % predefined hrf for audition (see Talvage)
                    opt.tau = 1.5;
                    opt.delta = 1.8;
            end
            for i = 1:length(params)
                hrf.(params{i}) = opt.(params{i});
            end
        end
        
        if strcmp(opt.funcName, 'hrf_twogamna')
            if ~isfield(opt, 'delta'); hrf.delta = 0; else hrf.delta = opt.delta; end
            if ~isfield(opt, 'c'); hrf.c = 6; else hrf.c = opt.c; end
            if ~isfield(opt, 'a1'); hrf.a1 = 6; else hrf.a1 = opt.a1; end
            if ~isfield(opt, 'a2'); hrf.a2 = 16; else hrf.a2 = opt.a2; end
            if ~isfield(opt, 'b1'); hrf.b1 = 1; else hrf.b1 = opt.b1; end
            if ~isfield(opt, 'b2'); hrf.b2 = 1; else hrf.b2 = opt2.b2; end
        end
              
    case 2 % pre-defined hrf
        %% Input Control
        if ~isfield(opt,'dt') && ~isfield(opt,'t')
            error('Either ''opt.dt'' or ''opt.t'' must be specified');
        end
        
        flds = fieldnames(opt);
        if any(~ismember(flds, {'hrf', 'dt', 't'}))
            errFlds = flds(~ismember(flds, {'hrf', 'dt', 't'}));
            error('Unknown field for pre-defined HRF creation method: %s\n', strjoin(errFlds, ', '));
        end
        
        if isfield(opt, 'dt') && isfield(opt, 't') && unique(diff(opt.t)) ~= opt.dt
            error('Given ''dt'' does not match the time steps in ''t''');
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