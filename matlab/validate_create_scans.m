function validate_create_scans(scanOpt, opt)

if ~isfield(scanOpt, 'boldFiles') || isempty(scanOpt.boldFiles)
    error('No bold files selected.');
end

if ischar(scanOpt.boldFiles)
    scanOpt.boldFiles = {scanOpt.boldFiles};
end

if ~isfield(scanOpt, 'roiFiles') && isempty(scanOpt.roiFiles)
    error('No stimulus files selected');
end

if ischar(scanOpt.roiFiles)
    scanOpt.roiFiles = {scanOpt.roiFiles};
end

if length(scanOpt.boldFiles) ~= length(scanOpt.stimFiles)
    error('All bold files must have corresponding stimulus files.');
end

if ~isfield(scanOpt, 'roiFiles')
    scanOpt.roiFiles = {''};
end

if ischar(scanOpt.roiFiles)
    scanOpt.roiFiles = {scanOpt.roiFiles};
end

if isempty(opt.roi) && ~all(cellfun(@isempty, scanOpt.roiFiles))
    error('No ''opt.roi'' when ''scanOpt.roiFiles'' is specified');
end

if ~isempty(opt.roi) && all(cellfun(@isempty, scanOpt.roiFiles))
    error('No ''scanOpt.roiFiles'' when ''opt.roi'' is specified');
end

if isfield(scanOpt, 'paradigm') && isfield(scanOpt, 'stimImg')
    error('Cannot specify both ''scanOpt.paradigm.<var>'' and ''scanOpt.stimImg''');
end

if isfield(scanOpt, 'paradigm') && ~isstruct(scanOpt.paradigm)
    error('Must specify variable name(s) for ''scanOpt.paradigm.<var>''');
end

if isfield(scanOpt, 'paradigm') && ~all(ismember(paramNames.funcOf, fieldnames(scanOpt.paradigm)))
    errFlds = setdiff(paramNames.funcOf, fieldnames(scanOpt.paradigm));
    error('Must specify paradigm.<var> for variable(s): %s', strjoin(errFlds, ', '));
end

if isfield(scanOpt, 'paradigm') && any(structfun(@isempty, scanOpt.paradigm))
    errFlds = fieldnames(scanOpt.paradigm);
    error('Must specify ''paradigm.<var>'' variable name(s) for: %s', ...
        strjoin(errFlds(structfun(@isempty, scanOpt.paradigm)), ', '));
end

if isfield(scanOpt, 'stimImg') && isempty(scanOpt.stimImg)
    error('Must specify a variable name for ''scanOpt.stimImg''');
end

if isfield(scanOpt, 'stimImg') && ~isfield(scanOpt, 'order')
    scanOpt.order = ['nVols' paramNames.funcOf];
end
