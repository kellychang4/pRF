function mustBeField(S, fld)
%mustBeField Validate that a field exists within the structure.
    
    if ~isfield(S, fld)
        eid = 'PRF:mustBeField';
        msg = 'Field must exist within the given structure.'; 
        throwAsCaller(MException(eid, msg));
    end

end