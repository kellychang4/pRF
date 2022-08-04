function validate_protocols(protocols)

for i = 1:length(protocols) % for each protocol
    curr = protocols(i); % current protocol
    
    if isfield(curr, 'voxel'); v = curr.voxel; else; v = curr.vertex; end
    
    %%% validate the number of vertices 
    if ~isequal(length(v), size(curr.bold, 2))
        eid = 'PRF:unitCountNotEqual';
        msg = 'Number of units should be the same across indices and bold time courses.';
        throwAsCaller(MException(eid, msg));
    end
    
    %%% validte the number of stimulus dimensions
    sz = size(stim, 2:ndims(curr.stim));
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