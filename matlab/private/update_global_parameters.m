function update_global_parameters(protocols, seeds)

% declare global options
global_options(); 

global GLOBAL_PARAMETERS GLOBAL_OPTIONS;

%%% select prf model parameter
prfModel = format_model_string(GLOBAL_PARAMETERS.prf.model);
GLOBAL_PARAMETERS.prf = combine_structures(GLOBAL_PARAMETERS.prf, ...
    GLOBAL_OPTIONS.(prfModel));

%%% hrf model
hrfModel = format_model_string(GLOBAL_PARAMETERS.hrf.model);
GLOBAL_PARAMETERS.hrf = combine_structures(GLOBAL_PARAMETERS.hrf, ...
    GLOBAL_OPTIONS.(hrfModel));

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
for i = 1:length(protocols)
    curr = protocols(i); % current protocol
    GLOBAL_PARAMETERS.t.hrf{i} = 0:curr.stim_dt:GLOBAL_PARAMETERS.hrf.tmax;
    GLOBAL_PARAMETERS.stim{i} = reshape(curr.stim, size(curr.stim, 1), []); 
    GLOBAL_PARAMETERS.funcof(i) = curr.stim_funcof;
end

%%% seeds
GLOBAL_PARAMETERS.seeds = create_seeds(seeds);
