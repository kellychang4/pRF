function [s] = combine_structures(s1, s2)

flds = fieldnames(s1); 
for i = 1:length(flds)
    s.(flds{i}) = s1.(flds{i});
end

flds = fieldnames(s2); 
for i = 1:length(flds)
    s.(flds{i}) = s2.(flds{i});
end
