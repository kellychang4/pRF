function validate_bold_ext(fpaths)

    for i = 1:length(fpaths)
        [~,~,ext] = extract_fileparts(fpaths{i}); 
        
        if strcmp(ext, {'.vtc', '.nii', '.nii.gz', '.gii'})
            eid = 'PRF:cannotReadFileExtension';
            msg = 'Unrecognized file extension.';
            throwAsCaller(MException(eid, msg));
        end
    end
    
end