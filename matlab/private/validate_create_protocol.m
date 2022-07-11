function validate_create_protocol(boldFiles, stimFiles, roiFile, varargin)

%% Check File Existence

error_files_exists(anatFile);
error_files_exists(roiFile); 
error_files_exists(boldFiles); 
error_files_exists(stimFiles); 
return
%% 

if ischar(scanInfo.boldFiles)
    scanInfo.boldFiles = {scanInfo.boldFiles};
end

if ischar(scanInfo.stimFiles)
    scanInfo.stimFiles = {scanInfo.stimFiles};
end

if length(scanInfo.boldFiles) ~= length(scanInfo.stimFiles)
    error([
        'File length mismatch.\n', ...
        'All bold files must have corresponding stimulus files.'
    ], '');
end
return

%% Not completed below

if isfield(scanInfo, 'paradigm') && isfield(scanInfo, 'stimImg')
    error('Cannot specify both ''scanInfo.paradigm.<var>'' and ''scanInfo.stimImg''');
end

if isfield(scanInfo, 'paradigm') && ~isstruct(scanInfo.paradigm)
    error('Must specify variable name(s) for ''scanInfo.paradigm.<var>''');
end

if isfield(scanInfo, 'paradigm') && ~all(ismember(paramNames.funcOf, fieldnames(scanInfo.paradigm)))
    errFlds = setdiff(paramNames.funcOf, fieldnames(scanInfo.paradigm));
    error('Must specify paradigm.<var> for variable(s): %s', strjoin(errFlds, ', '));
end

if isfield(scanInfo, 'paradigm') && any(structfun(@isempty, scanInfo.paradigm))
    errFlds = fieldnames(scanInfo.paradigm);
    error('Must specify ''paradigm.<var>'' variable name(s) for: %s', ...
        strjoin(errFlds(structfun(@isempty, scanInfo.paradigm)), ', '));
end

if isfield(scanInfo, 'stimImg') && isempty(scanInfo.stimImg)
    error('Must specify a variable name for ''scanInfo.stimImg''');
end

if isfield(scanInfo, 'stimImg') && ~isfield(scanInfo, 'order')
    scanInfo.order = ['nVols' paramNames.funcOf];
end
