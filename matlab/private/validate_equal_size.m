function validate_equal_size(x, y)
 
    if ~isequal(size(x), size(y))
        eid = 'PRF:sizeNotEqual';
        msg = 'Size of first input must equal size of second input.';
        throwAsCaller(MException(eid, msg));
    end
    
end