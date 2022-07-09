function global_retinotopy_defaults()

%%% declare global variable
global GLOBAL_PARAMETERS;

%%% prf model parameters
GLOBAL_PARAMETERS.prf.model = @model_gaussian2d;
GLOBAL_PARAMETERS.prf.params = {'x0', 'y0', 'sigma'};
GLOBAL_PARAMETERS.prf.funcof = {'x', 'y'};
GLOBAL_PARAMETERS.prf.css = false; 

%%% hrf model parameters
GLOBAL_PARAMETERS.hrf.fit = false;
GLOBAL_PARAMETERS.hrf.model = @hrf_boynton;
GLOBAL_PARAMETERS.hrf.params = {'n', 'tau', 'delta'};
GLOBAL_PARAMETERS.hrf.funcof = {'t'}; 
GLOBAL_PARAMETERS.hrf.tmax = 40;

%%% fit procedure parameters
GLOBAL_PARAMETERS.fit.func = @corr_pearson;
GLOBAL_PARAMETERS.fit.parallel = true;

%%% printing parameter
GLOBAL_PARAMETERS.print.quiet = false;
GLOBAL_PARAMETERS.print.nunits = 1000; 
