function validate_estimate_hrf()

if ~opt.CSS && ismember('exp', freeParams)
    fprintf('NOTE: ''opt.CSS'' set as TRUE due to ''exp'' in ''opt.freeList''\n');
    opt.CSS = true;
end

if opt.CSS && ~ismember('exp', freeParams)
    error('''opt.CSS'' is true without ''exp'' in ''opt.freeList''');
end

if opt.CSS % exponent factor
    MODEL_PARAMETERS.params = [MODEL_PARAMETERS.params 'exp'];
end

% if free parameter without seeds
if any(ismember(freeParams, fieldnames(seeds)) == 0)
    errFlds = setdiff(freeParams, fieldnames(seeds));
    error('No seeds for opt.freeList parameter(s): %s', ...
        strjoin(errFlds, ', '));
end

% if model cannot estimate all given free parameters
if any(ismember(freeParams, MODEL_PARAMETERS.params) == 0)
    errFlds = setdiff(freeParams, MODEL_PARAMETERS.params);
    error('%s() does not have given opt.freeList parameter(s): %s', ...
        opt.model, strjoin(errFlds, ', '));
end
