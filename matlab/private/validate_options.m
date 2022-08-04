function validate_options(options)
    
    %%% validate prf model options
    mustBeMember(options.prf.model, {'Gaussian 1D', 'Gaussian 2D'});

    %%% validate prf model free parameters
    mustBeText(options.prf.free); 

    %%% validate hrf model options
    mustBeMember(options.hrf.model, {'Boynton', 'Two Gamma'});

    %%% validate hrf model free parameters
    mustBeText(options.hrf.free);

    %%% validate hrf iteration integer and range (1 - 5)
    mustBeInteger(options.hrf.nfit); 
    mustBeInRange(options.hrf.nfit, 1, 5); 

    %%% validate hrf threshold range (0 - 1.0)
    mustBeInRange(options.hrf.thr, 0, 1);

    %%% validate hrf fitting proportion range (1% - 100%)
    mustBeInRange(options.hrf.pmin, 0.01, options.hrf.pmax, 'exclude-upper'); 
    mustBeInRange(options.hrf.pmax, options.hrf.pmin, 1, 'exclude-lower'); 

end