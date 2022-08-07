function validate_protocols(protocols)

id = NaN(size(protocols(1).bold, 2), length(protocols)); 

for i = 1:length(protocols) % for each protocol
    curr = protocols(i); % current protocol
    
    %%% extract units either voxels or vertices
    unit = 'voxel'; if isfield(curr, 'vertex'); unit = 'vertex'; end
    v = curr.(unit); id(:,i) = v(:); % current units

    %%% validate roi indices, must be the same for all protocols
    if i > 1 && ~isequal(id(:,i), id(:,i-1))
        eid = 'PRF:dissimilarRoiIndices';
        msg = sprintf('%s across protocols must have the same indices.', capitalize(unit)); 
        throwAsCaller(MException(eid, msg)); 
    end

    %%% validate the number of vertices 
    if ~isequal(length(v), size(curr.bold, 2))
        eid = 'PRF:unitCountNotEqual';
        msg = 'Number of units should be the same across indices and bold time courses.';
        throwAsCaller(MException(eid, msg));
    end
    
    %%% validte the number of stimulus dimensions
    sz = size(curr.stim, 2:ndims(curr.stim));
    funcof = curr.stim_funcof; flds = fieldnames(funcof); 
    for f = 1:length(flds) % for each stimulus dimension
        if ~isequal(size(funcof.(flds{f})), sz)
            eid = 'PRF:unitCountNotEqual';
            msg = 'The stimulus coordinate dimensions should be the same as the stimulus.';
            throwAsCaller(MException(eid, msg));
        end
    end
    
end

end