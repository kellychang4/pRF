function global_retinotopy_defaults()

%%% declare global variable
global GLOBAL_PARAMETERS;

%%% prf model parameters
GLOBAL_PARAMETERS.prf.model = 'Gaussian 2D';
GLOBAL_PARAMETERS.prf.free = {'x0', 'y0', 'sigma>0.01'};
GLOBAL_PARAMETERS.prf.css = false; 

%%% hrf model parameters
GLOBAL_PARAMETERS.hrf.fit = false;
GLOBAL_PARAMETERS.hrf.model = 'Boynton';
GLOBAL_PARAMETERS.hrf.params.n     = 3; 
GLOBAL_PARAMETERS.hrf.params.tau   = 1.2;
GLOBAL_PARAMETERS.hrf.params.delta = 2.25;

% GLOBAL_PARAMETERS.hrf.model = 'Two Gamma';
% GLOBAL_PARAMETERS.hrf.params.delta = 0;
% GLOBAL_PARAMETERS.hrf.params.c     = 6; 
% GLOBAL_PARAMETERS.hrf.params.a1    = 6; 
% GLOBAL_PARAMETERS.hrf.params.a2    = 16; 
% GLOBAL_PARAMETERS.hrf.params.b1    = 1; 
% GLOBAL_PARAMETERS.hrf.params.b2    = 1;

%%% fit procedure parameters
GLOBAL_PARAMETERS.fit.error = 'Pearson';
GLOBAL_PARAMETERS.fit.parallel = true;

%%% printing parameter
GLOBAL_PARAMETERS.print.quiet = false;
GLOBAL_PARAMETERS.print.nunits = 1000; 
