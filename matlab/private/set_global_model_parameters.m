function set_global_model_parameters()

global_options(); % declare global options

global GLOBAL_PARAMETERS GLOBAL_OPTIONS;

%%% prf model
prfModel = format_model_string(GLOBAL_PARAMETERS.prf.model);
GLOBAL_PARAMETERS.prf = combine_structures(GLOBAL_PARAMETERS.prf, ...
    GLOBAL_OPTIONS.(prfModel));

%%% hrf model
hrfModel = format_model_string(GLOBAL_PARAMETERS.hrf.model);
GLOBAL_PARAMETERS.hrf = combine_structures(GLOBAL_PARAMETERS.hrf, ...
    GLOBAL_OPTIONS.(hrfModel));

%%% error model