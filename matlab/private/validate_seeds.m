function validate_seeds(seeds)

flds = fieldnames(seeds);
for f = 1:length(flds) % for each field

    %%% each field must be a vector
    mustBeVector(seeds.(flds{f}));

    %%% must have at least 1 unique value in seed field
    if length(unique(seeds.(flds{f}))) < 1
        eid = 'PRF:missingSeedValue';
        msg = 'A seed field must have at least one unique value.';
        throwAsCaller(MException(eid, msg));
    end
end