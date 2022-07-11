function validate_equal_size(x, y)
    % Test for equal size
    if ~isequal(size(x), size(y))
        eid = 'Size:notEqual';
        msg = 'Size of first input must equal size of second input.';
        throwAsCaller(MException(eid, msg));
    end
end