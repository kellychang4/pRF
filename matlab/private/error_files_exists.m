function error_files_exists(fname)

if iscell(fname) || ischar(fname)
    if ischar(fname); fname = {fname}; end
    
    for i = 1:length(fname) % for each file
        
        %%% file name needs to be a character string
        if ~ischar(fname{i}) 
            error('File name must be a character string.');
        end
        
        %%% file name must exist 
        if ~isfile(fname{i})
            error('Unable to read file ''%s''. No such file exists.', fname{i});
        end
    end
    
else
    %%% if input is NOT a cell or string
    error('File name(s) must be a string or cell array of strings.'); 
end
