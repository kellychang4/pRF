function validate_options(options)
    
    %%% validate prf model options
    mustBeField(options, 'prf'); mustBeField(options.prf, 'model');
    mustBeMember(options.prf.model, {'Gaussian 1D', 'Gaussian 2D'});
    
    %%% validate prf model free parameters
    mustBeField(options.prf, 'free'); mustBeText(options.prf.free);
    
    %%% validate hrf model options
    mustBeField(options, 'hrf'); mustBeField(options.hrf, 'model');
    mustBeMember(options.hrf.model, {'Boynton', 'Two Gamma'});
    
    %%% validate hrf model free parameters
    mustBeField(options.hrf, 'free'); mustBeText(options.hrf.free);
    
    %%% validate hrf iteration integer and range (1 - 5)
    mustBeField(options.hrf, 'niter'); mustBeInteger(options.hrf.niter);
    mustBeInRange(options.hrf.niter, 1, 5);
    
    %%% validate hrf threshold range (0 - 1.0)
    mustBeField(options.hrf, 'thr'); mustBeInRange(options.hrf.thr, 0, 1);
    
    %%% validate hrf fitting proportion range (1% - 100%)
    mustBeField(options.hrf, 'pmin'); mustBeField(options.hrf, 'pmax');
    mustBeInRange(options.hrf.pmin, 0.01, options.hrf.pmax, 'exclude-upper');
    mustBeInRange(options.hrf.pmax, options.hrf.pmin, 1, 'exclude-lower');
    
    %%% validate fitting procedure parameters
    mustBeField(options, 'fit');
    
    %%% validate fitting correlation types
    mustBeField(options.fit, 'corr');
    mustBeMember(options.fit.corr, {'Pearson', 'Spearman', 'Kendall'});
    
    %%% validate parallel processing parameters
    mustBeField(options, 'parallel'); mustBeField(options.parallel, 'flag');
    mustBeNumericOrLogical(options.parallel.flag);
    
    %%% validate parallel processing types
    mustBeField(options.parallel, 'type');
    mustBeMember(options.parallel.type, {'local', 'threads', 'cluster'});
    
    %%% validate parallel processing pool size
    if isfield(options.parallel, 'size')
        mustBePositive(options.parallel.size);
        mustBeInteger(options.parallel.size);
    end
    
    %%% validate progress printing parameters
    mustBeField(options, 'print'); mustBeField(options.print, 'quiet');
    mustBeNumericOrLogical(options.print.quiet);

    %%% validate progress printing iteration marker
    mustBeField(options.print, 'n'); mustBeInteger(options.print.n);
    mustBeNonNan(options.print.n); mustBePositive(options.print.n); 

end