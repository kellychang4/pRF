function mustBeInequality(values)
    
    for i = 1:length(values) % for each string
        value = values{i}; invalidFlags = false(3,1); 

        %%% validate if contents are charaters
        mustBeTextScalar(value);

        %%% remove all whitespace characters
        value = regexprep(value, '\s', ''); 

        %%% validate if string only contains allowed characters
        invalidFlags(1) = ~isempty(regexp(value, '[^\w<>=\.]', 'once'));

        %%% validate if string contains opposing inequalities
        invalidFlags(2) = contains(value, '<') & contains(value, '>');
           
        %%% validate if '=' is linked with inequality symbol
        if contains(value, '=') % if contains '=' in string
            checkStr = value(regexp(value, '=') - 1); % should be inequalities
            invalidFlags(3) = length(regexp(checkStr, '<|>')) ~= length(checkStr);
        end

        %%% validate any of the inequality conditions
        if any(invalidFlags)
            eid = 'PRF:invalidInequalityString'; 
            msg = 'Free parameter string must be a valid numeric or inequality format.'; 
            throwAsCaller(MException(eid, msg)); 
        end

    end

end