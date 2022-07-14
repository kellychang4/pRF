function global_options()

%%% declare global variable
global GLOBAL_OPTIONS;

%%% prf model parameters
GLOBAL_OPTIONS.gaussian1d.model = @model_gaussian1d;
GLOBAL_OPTIONS.gaussian1d.params = {'x0', 'sigma'};
GLOBAL_OPTIONS.gaussian1d.funcof = {'x'};

GLOBAL_OPTIONS.gaussian2d.model = @model_gaussian2d;
GLOBAL_OPTIONS.gaussian2d.params = {'x0', 'y0', 'sigma'};
GLOBAL_OPTIONS.gaussian2d.funcof = {'x', 'y'};

%%% hrf model parameters
GLOBAL_OPTIONS.boynton.model = @hrf_boynton;
GLOBAL_OPTIONS.boynton.params = {'n', 'tau', 'delta'};
GLOBAL_OPTIONS.boynton.funcof = {'t'};
GLOBAL_OPTIONS.boynton.defaults.n     = 3;
GLOBAL_OPTIONS.boynton.defaults.tau   = 1.2;
GLOBAL_OPTIONS.boynton.defaults.delta = 2.25;
GLOBAL_OPTIONS.boynton.tmax = 40;

GLOBAL_OPTIONS.twogamma.model = @hrf_boynton;
GLOBAL_OPTIONS.twogamma.params = {'delta', 'c', 'a1', 'a2', 'b1', 'b2'};
GLOBAL_OPTIONS.twogamma.funcof = {'t'};
GLOBAL_OPTIONS.twogamma.defaults.delta = 0;
GLOBAL_OPTIONS.twogamma.defaults.c     = 6;
GLOBAL_OPTIONS.twogamma.defaults.a1    = 6;
GLOBAL_OPTIONS.twogamma.defaults.a2    = 16;
GLOBAL_OPTIONS.twogamma.defaults.b1    = 1;
GLOBAL_OPTIONS.twogamma.defaults.b2    = 1;
GLOBAL_OPTIONS.twogamma.tmax = 40;