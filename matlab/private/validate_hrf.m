function validate_hrf(hrf)

    %%% validate hrf model options
    mustBeField(hrf, 'model'); mustBeMember(hrf.model, {'Boynton', 'Two Gamma'});
    
    %%% validate hrf parameters by model function
    mustBeField(hrf, 'params'); flds = fieldnames(hrf.params); 
    switch hrf.model
        case 'Boynton'
            mustBeMember(flds, {'n', 'tau', 'delta'});
        case 'Two Gamma'
            mustBeMember(flds, {'delta', 'c', 'a1', 'a2', 'b1', 'b2'});
    end

    %%% validate hrf parameter value
    for i = 1:length(flds) % for each parameter
        value = hrf.params.(flds{i});
        mustBeNumeric(value); mustBeFinite(value); mustBeReal(value); 
    end

end