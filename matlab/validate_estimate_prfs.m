function validate_estimate_prfs()

%% Variables and Input Control

if ~opt.CSS && ismember('exp', freeName)
    fprintf('NOTE: ''opt.CSS'' set as TRUE due to ''exp'' in ''opt.freeList''\n');
    opt.CSS = true;
end

if opt.CSS && ~ismember('exp', freeName)
    error('''opt.CSS'' is true without ''exp'' in ''opt.freeList''');
end

if opt.CSS % exponent factor
    scanExp = [seeds.exp];
    paramNames.params = [paramNames.params 'exp'];
end

%% Error Checking

% if free parameter without seeds
if any(ismember(freeName, fieldnames(seeds)) == 0)
    errFlds = setdiff(freeName, fieldnames(seeds));
    error('No seeds for opt.freeList parameter(s): %s', ...
        strjoin(errFlds, ', '));
end

% if model cannot estimate all given free parameters
if any(ismember(freeName, paramNames.params) == 0)
    errFlds = setdiff(freeName, paramNames.params);
    error('%s() does not have given opt.freeList parameter(s): %s', ...
        opt.model, strjoin(errFlds, ', '));
end

% if estimated hrf but pre-defined hrf provided
if ~isnan(opt.estHRF) && isfield(hrf, 'hrf')
    error('Cannot estimate HRF with pre-defined (non-paramaterized) HRF');
end

% if cost parameter is not all within the free parameters, excluding hrf
% parameters
if ~isempty(fieldnames(opt.cost)) && isfield(hrf,'funcName') && ...
        ~all(ismember(setdiff(fieldnames(opt.cost), feval(hrf.funcName)), freeName))
    errFlds = setdiff(setdiff(fieldnames(opt.cost), feval(hrf.funcName)), freeName);
    error('Cost parameter(s) not found in the free parameters: %s', ...
        strjoin(errFlds, ', '))
end