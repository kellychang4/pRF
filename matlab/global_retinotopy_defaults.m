function global_retinotopy_defaults()

%%% declare global variable
global GLOBAL_PARAMETERS;

%%% prf model parameters
GLOBAL_PARAMETERS.prf_model = @model_gaussian2d;
GLOBAL_PARAMETERS.prf_params = {'x0', 'y0', 'sigma'};
GLOBAL_PARAMETERS.prf_funcof = {'x', 'y'};
GLOBAL_PARAMETERS.css = false; 

%%% fit procedure parameters
GLOBAL_PARAMETERS.corr_func = @corr_pearson;
GLOBAL_PARAMETERS.parallel = true;
GLOBAL_PARAMETERS.quiet = false;


        opt.roi = '';
        opt.estHRF = NaN;
%         opt.topHRF = 0.1;
%         opt.hrfThr = 0.25;
        opt.cost = struct();