function validate_funcof(stimImg, funcOf)

nd = ndims(stimImg); 
flds = fieldnames(funcOf); 
if ~any(strcmp(flds, 't'))
    eid = 'PRF:missingTime'; 
    msg = 'Missing time vector for stimulus image in function of variable.';
    throwAsCaller(MException(eid, msg));
end

if nd ~= length(flds)
    eid = 'PRF:nDimensionMismatch'; 
    msg = 'Number of dimensions mismatch between stimulus image and function of variable'; 
    throwAsCaller(MException(eid, msg));
end

spaceFlds = setdiff(flds, 't'); spaceMismatchFlag = true; 
for i = 1:length(spaceFlds) % for each field (no time)
    spaceMismatchFlag = spaceMismatchFlag & ...
        all(size(stimImg,2:nd) == size(funcOf.(spaceFlds{i})));
end
if ~spaceMismatchFlag
    eid = 'PRF:dimensionSizeMismatch';
    msg = 'Dimension size mismatch between stimulus image and function of variables'; 
    throwAsCaller(MException(eid, msg));
end