function validate_options_prf(options)
    
    %%% validate prf model options
    mustBeField(options, 'prf'); mustBeField(options.prf, 'model');
    mustBeMember(options.prf.model, {'Gaussian 1D', 'Gaussian 2D'});
    
    %%% validate prf model free parameters
    mustBeField(options.prf, 'free'); mustBeA(options.prf.free, 'cell'); 
    mustBeInequality(options.prf.free); 

    %%% validate hrf model options
    if isfield(options, 'hrf')
        mustBeField(options.hrf, 'model');
        mustBeMember(options.hrf.model, {'Boynton', 'Two Gamma'});
    end

    %%% (optional) validate fitting procedure parameters 
    if isfield(options, 'fit')
        %%% validate fitting correlation types
        mustBeField(options.fit, 'name');
        mustBeMember(options.fit.name, {'Pearson', 'Spearman', 'Kendall'});
    end

    %%% (optional) validate parallel processing parameters 
    if isfield(options, 'parallel')
        mustBeField(options.parallel, 'flag'); 
        mustBeNumericOrLogical(options.parallel.flag);

        %%% validate parallel processing types
        if isfield(options.parallel, 'type')
            mustBeMember(options.parallel.type, ...
                {'local', 'threads', 'cluster'});
        end

        %%% validate parallel processing method
        if isfield(options.parallel, 'method')
            mustBeMember(options.parallel.method, {'parfor', 'parfeval'});
        end

        %%% validate parallel processing pool size
        if isfield(options.parallel, 'size')
            mustBePositive(options.parallel.size);
            mustBeInteger(options.parallel.size);
        end

        %%% validiate parallel processing chunk size
        if isfield(options.parallel, 'chunk')
            mustBePositive(options.parallel.chunk);
            mustBeInteger(options.parallel.chunk);
        end
    end
    
    %%% (optional) validate progress printing parameters
    if isfield(options, 'print')
        mustBeField(options.print, 'quiet');
        mustBeNumericOrLogical(options.print.quiet);
    end

    %%% (optional) validate printing increment if printing
    if ~options.print.quiet
        %%% validate progress printing iteration marker
        mustBeField(options.print, 'inc'); mustBeInteger(options.print.inc);
        mustBeNonNan(options.print.inc); mustBePositive(options.print.inc);
    end

end