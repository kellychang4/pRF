function update_global_parameters(protocols, seeds, options)

% declare global options
global_options(); 

global GLOBAL_PARAMETERS GLOBAL_OPTIONS;

%% Default Parameters

%%% prf model parameters
GLOBAL_PARAMETERS.prf.model = '';
GLOBAL_PARAMETERS.prf.free  = {};
GLOBAL_PARAMETERS.prf.css   = false;

%%% hrf model parameters
GLOBAL_PARAMETERS.hrf.model  = '';
GLOBAL_PARAMETERS.hrf.free   = {};
GLOBAL_PARAMETERS.hrf.niter  = 3;
GLOBAL_PARAMETERS.hrf.thr    = 0.45;
GLOBAL_PARAMETERS.hrf.pmin   = 0.15;
GLOBAL_PARAMETERS.hrf.pmax   = 0.25;

%%% fit procedure parameters
GLOBAL_PARAMETERS.fit.corr = 'Pearson'; 

%%% parallel processing parameters
GLOBAL_PARAMETERS.parallel.flag  = true;
GLOBAL_PARAMETERS.parallel.type  = 'threads';

%%% progress printing parameters
GLOBAL_PARAMETERS.print.quiet = false;
GLOBAL_PARAMETERS.print.n     = 1000; 

%%% overwrite with user specified options
overwrite_global_parameters(options);

%% Derived Parameters

%%% prf model parameters (based on anatomical file extension)
if endsWith(protocols(1).bold_file, '.gii')
    unit = 'vertex'; else; unit = 'voxel'; end
GLOBAL_PARAMETERS.prf.unit = unit;

%%% prf model parameters from global options
prfModel = format_model_string(GLOBAL_PARAMETERS.prf.model);
GLOBAL_PARAMETERS.prf = combine_structures(GLOBAL_PARAMETERS.prf, ...
    GLOBAL_OPTIONS.(prfModel));

%%% hrf model parameters
hrfModel = format_model_string(GLOBAL_PARAMETERS.hrf.model);
GLOBAL_PARAMETERS.hrf = combine_structures(GLOBAL_PARAMETERS.hrf, ...
    GLOBAL_OPTIONS.(hrfModel));

%%% fit procedure parameters
GLOBAL_PARAMETERS.fit.func = @(x,y) corr(x, y, 'type', ...
    GLOBAL_PARAMETERS.fit.corr);

%%% parallel processing parameters, if parallel available
if isempty(which('gcp')) % if no parallel toolbox
    fprintf(['[NOTE] Parallel Processing Toolbox does not exist on path.\n', ...
        'Turning off parallel processing options.\n']);
    GLOBAL_PARAMETERS.parallel.flag  = false;
    GLOBAL_PARAMETERS.parallel.type  = 'local';
    GLOBAL_PARAMETERS.parallel.size  = 0;
else
    n = maxNumCompThreads(); % maximum number of works on machine
    if ~isfield(options.parallel, 'size') || options.paralle.size > n
        fprintf(['[NOTE] Did not specify or requested number of ', ...
            'parallel threads exceeded machine''s availability.\n', ...
            'Assigning parallel pool size to %d.\n'], n);
        GLOBAL_PARAMETERS.parallel.size = maxNumCompThreads();
    end
    mustBeInteger(GLOBAL_PARAMETERS.parallel.size);
    mustBeInRange(GLOBAL_PARAMETERS.parallel.size, 0, n);
end

%%% progress printing parameters
digits = length(num2str(length(protocols(1).(unit)))) + 1;
GLOBAL_PARAMETERS.print.digits = digits;

%%% create seeds structure
GLOBAL_PARAMETERS.seeds = create_seeds(seeds);

%%% counts
GLOBAL_PARAMETERS.n.protocol = length(protocols);
GLOBAL_PARAMETERS.n.unit = length(protocols(1).(unit)); 
GLOBAL_PARAMETERS.n.seed = length(seeds);

%%% time steps
GLOBAL_PARAMETERS.dt.stim = [protocols.stim_dt];
GLOBAL_PARAMETERS.dt.bold = [protocols.bold_dt];

%%% time vectors 
GLOBAL_PARAMETERS.t.stim = {protocols.stim_t};
GLOBAL_PARAMETERS.t.bold = {protocols.bold_t};

%%% stimulus images dimensions
for i = 1:length(protocols) % for each protocol
    curr = protocols(i); % current protocol
    GLOBAL_PARAMETERS.t.hrf{i} = 0:curr.stim_dt:GLOBAL_PARAMETERS.hrf.tmax;
    GLOBAL_PARAMETERS.stim{i} = reshape(curr.stim, size(curr.stim, 1), []); 
    GLOBAL_PARAMETERS.funcof(i) = curr.stim_funcof;
end

%%% validate global parameters
validate_global_parameters();

%% Nested Functions

function overwrite_global_parameters(opt)
    mainFlds = fieldnames(opt); 
    for m = 1:length(mainFlds) % for each main fields
        flds = fieldnames(opt.(mainFlds{m}));
        for f = 1:length(flds) % for each subfield
            value = opt.(mainFlds{m}).(flds{f});
            GLOBAL_PARAMETERS.(currMainFld).(flds{f}) = value;
        end
    end    
end

function validate_global_parameters()
   
    %%% validate prf or hrf free parameters (only one at a time)
    if ~isempty(GLOBAL_PARAMETERS.prf.free) && ~isempty(GLOBAL_PARAMETERS.hrf.free)
        eid = 'PRF:tooManyFreeParameters';
        msg = 'Cannot estimate pRFs and HRFs at the same time. Only on can have free parameters.'; 
        throwAsCaller(MException(eid, msg));
    end

    %%% validate prf free parameters, must be function parameters
    if ~isempty(GLOBAL_PARAMETERS.prf.free)
        vars = extract_inequality_vars(GLOBAL_PARAMETERS.prf.free); 

        %%% 


        %%% validate prf free parameters are subset of prf function parameters
        if ~isempty(setdiff(vars, GLOBAL_PARAMETERS.prf.params))
            eid = 'PRF:prfFreeParameterSubset';
            msg = 'Requested pRF free parameters must from the pRF model function parameters.';
            throwAsCaller(MException(eid, msg));
        end

%         fprintf('NOTE: ''opt.CSS'' set as TRUE due to ''exp'' in ''opt.freeList''\n');
%         options.CSS = true;
    end
    

%     if options.CSS && ~ismember('exp', freeParams)
%         error('''opt.CSS'' is true without ''exp'' in ''opt.freeList''');
%     end
    
    % (!!!) move to derived parameter section, needs to be adjusted if true
%     if options.CSS % exponent factor
%         MODEL_PARAMETERS.params = [MODEL_PARAMETERS.params 'exp'];
%     end

    %%% validate hrf model parameters
    if ~isempty(GLOBAL_PARAMETERS.hrf.free) 
        vars = extract_inequality_vars(GLOBAL_PARAMETERS.hrf.free);
        
        %%% validate hrf free parameters are subset of hrf function parameters
        if ~isempty(setdiff(vars, GLOBAL_PARAMETERS.hrf.params))
            eid = 'PRF:hrfFreeParameterSubset';
            msg = 'Requested HRF free parameters must from the HRF model function parameters.';
            throwAsCaller(MException(eid, msg));
        end

    end

    %%% validate seed parameters


end

end

%% Helper Functions

function [str] = format_model_string(str)
    %%% delete spaces and transform to lower case
    str = lower(regexprep(str, ' ', '')); 
end

