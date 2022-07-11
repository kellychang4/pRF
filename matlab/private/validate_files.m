function validate_files(fpaths)
    % Test for all files exists 
    for i = 1:length(fpaths)
        mustBeFile(fpaths{i});
    end
end