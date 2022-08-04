function update_global_parameters(protocols, seeds, opt)

% declare global options
global_options(); 

global GLOBAL_PARAMETERS GLOBAL_OPTIONS;

%% Default Parameters

%%% prf model parameters
GLOBAL_PARAMETERS.prf.model = '';
GLOBAL_PARAMETERS.prf.free  = {};
GLOBAL_PARAMETERS.prf.css   = false;

%%% hrf model parameters
GLOBAL_PARAMETERS.hrf.model = '';
GLOBAL_PARAMETERS.hrf.free  = {};
GLOBAL_PARAMETERS.hrf.nfit  = 3;
GLOBAL_PARAMETERS.hrf.thr   = 0.45;
GLOBAL_PARAMETERS.hrf.pmin  = 0.15;
GLOBAL_PARAMETERS.hrf.pmax  = 0.25;

%%% fit procedure parameters
GLOBAL_PARAMETERS.fit.corr = 'Pearson'; 

%%% parallel parameters
GLOBAL_PARAMETERS.parallel.flag   = true;
GLOBAL_PARAMETERS.parallel.type   = 'threads';
GLOBAL_PARAMETERS.parallel.size   = 8;

%%% printing parameters
GLOBAL_PARAMETERS.print.quiet = false;
GLOBAL_PARAMETERS.print.n     = 1000; 

%%% overwrite with user specified options
overwrite_global_parameters(opt);

%% Derived Parameters

%%% prf model parameters (based on anatomical file extension)
if endsWith(protocols(1).bold_file, '.gii')
    GLOBAL_PARAMETERS.prf.unit  = 'vertex';
else
    GLOBAL_PARAMETERS.prf.unit  = 'voxel';    
end

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

%%% create seeds structure
GLOBAL_PARAMETERS.seeds = create_seeds(seeds);

%%% general information
unitName = GLOBAL_PARAMETERS.prf.unit;
GLOBAL_PARAMETERS.n.protocol = length(protocols);
GLOBAL_PARAMETERS.n.unit = length(protocols(1).(unitName)); 
GLOBAL_PARAMETERS.n.seed = length(seeds);

%%% time steps
GLOBAL_PARAMETERS.dt.stim = [protocols.stim_dt];
GLOBAL_PARAMETERS.dt.bold = [protocols.bold_dt];

%%% time vectors 
GLOBAL_PARAMETERS.t.stim = {protocols.stim_t};
GLOBAL_PARAMETERS.t.bold = {protocols.bold_t};

%%% stimulus images and function of dimensions
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
    mainFlds = fieldnames(GLOBAL_PARAMETERS); 
    for m = 1:length(mainFlds) % for each main field
        flds = fieldnames(GLOBAL_PARAMETERS.(mainFlds{m}));
        for f = 1:length(flds) % for each subfield
            value = GLOBAL_PARAMETERS.(mainFlds{m}).(flds{f});
            vfunc = GLOBAL_OPTIONS.validate.(mainFlds{m}).(flds{f});
            vfunc(value); % validate the value
        end
    end
end

end

%% Helper Functions

function [str] = format_model_string(str)
    %%% delete spaces and transform to lower case
    str = lower(regexprep(str, ' ', '')); 
end