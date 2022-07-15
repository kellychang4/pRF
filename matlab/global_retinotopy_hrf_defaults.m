function global_retinotopy_hrf_defaults()

%%% declare global variable
global GLOBAL_PARAMETERS;

%%% prf model parameters
GLOBAL_PARAMETERS.prf.fit = false;
GLOBAL_PARAMETERS.prf.model = 'Gaussian 2D';
GLOBAL_PARAMETERS.prf.css = false; 

%%% hrf model parameters
GLOBAL_PARAMETERS.hrf.fit = true;
GLOBAL_PARAMETERS.hrf.model = 'Two Gamma';
GLOBAL_PARAMETERS.hrf.free = {'delta', 'c', 'a1', 'a2', 'b1', 'b2'};
GLOBAL_PARAMETERS.hrf.thr  = 0.45; 
GLOBAL_PARAMETERS.hrf.nmax = 2000; 

%%% fit procedure parameters
GLOBAL_PARAMETERS.fit.error = 'Pearson';
GLOBAL_PARAMETERS.fit.parallel = true;

%%% printing parameter
GLOBAL_PARAMETERS.print.quiet = false;
GLOBAL_PARAMETERS.print.nunits = 1000; 