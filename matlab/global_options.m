function global_options()

%%% declare global variable
global GLOBAL_OPTIONS;

%% pRF Model Parameters 

%%% gaussian 1d parameters
GLOBAL_OPTIONS.gaussian1d.func = @model_gaussian1d;
GLOBAL_OPTIONS.gaussian1d.params = {'x0', 'sigma'};
GLOBAL_OPTIONS.gaussian1d.funcof = {'x'};

%%% gaussian 2d parameters
GLOBAL_OPTIONS.gaussian2d.func = @model_gaussian2d;
GLOBAL_OPTIONS.gaussian2d.params = {'x0', 'y0', 'sigma'};
GLOBAL_OPTIONS.gaussian2d.funcof = {'x', 'y'};

%% HRF Model Parameters

%%% boynton hrf parameters
GLOBAL_OPTIONS.boynton.func = @hrf_boynton;
GLOBAL_OPTIONS.boynton.params = {'n', 'tau', 'delta'};
GLOBAL_OPTIONS.boynton.funcof = {'t'};
GLOBAL_OPTIONS.boynton.defaults.n     = 3;
GLOBAL_OPTIONS.boynton.defaults.tau   = 1.2;
GLOBAL_OPTIONS.boynton.defaults.delta = 2.25;
GLOBAL_OPTIONS.boynton.tmax = 40;

%%% spm two gamma parameters
GLOBAL_OPTIONS.twogamma.func = @hrf_twogamma;
GLOBAL_OPTIONS.twogamma.params = {'delta', 'c', 'a1', 'a2', 'b1', 'b2'};
GLOBAL_OPTIONS.twogamma.funcof = {'t'};
GLOBAL_OPTIONS.twogamma.defaults.delta = 0;
GLOBAL_OPTIONS.twogamma.defaults.c     = 6;
GLOBAL_OPTIONS.twogamma.defaults.a1    = 6;
GLOBAL_OPTIONS.twogamma.defaults.a2    = 16;
GLOBAL_OPTIONS.twogamma.defaults.b1    = 1;
GLOBAL_OPTIONS.twogamma.defaults.b2    = 1;
GLOBAL_OPTIONS.twogamma.tmax = 40;

%% Gobal Parameter Validation Functions

%%% prf model parameters
GLOBAL_OPTIONS.validate.prf.model   = @validate_prf_model;
GLOBAL_OPTIONS.validate.prf.free    = 'cell'; 
GLOBAL_OPTIONS.validate.prf.css     = 'logical'; 
GLOBAL_OPTIONS.validate.prf.space   = 'char'; 
GLOBAL_OPTIONS.validate.prf.unit    = 'char'; 
GLOBAL_OPTIONS.validate.prf.func    = 'function_handle'; 
GLOBAL_OPTIONS.validate.prf.params  = 'cell'; 
GLOBAL_OPTIONS.validate.prf.funcof  = 

%%% hrf model parameters
GLOBAL_OPTIONS.validate.hrf.model   = 'char'; 
GLOBAL_OPTIONS.validate.hrf.free    = 'cell'; 
GLOBAL_OPTIONS.validate.hrf.thr     = 'double'; 
GLOBAL_OPTIONS.validate.hrf.pmin    = 'double'; 
GLOBAL_OPTIONS.validate.hrf.pmax    = 'double'; 
GLOBAL_OPTIONS.validate.hrf.func    = 'function_handle'; 
GLOBAL_OPTIONS.validate.hrf.params  = 'cell'; 
GLOBAL_OPTIONS.validate.hrf.funcof  = 'cell'; 

end

%% Helper Functions

function validate_prf_model(value)
    
end

