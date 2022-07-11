function validate_gifti_tr(boldFiles, TR)

    [~,~,ext] = cellfun(@extract_fileparts, boldFiles, 'UniformOutput', false);
    if any(strcmp(ext, '.gii')) && isnan(TR)
        eid = 'PRF:missingBoldTR';
        msg = 'TR must be provided for GIfTI data.';
        throwAsCaller(MException(eid, msg));
    end

end