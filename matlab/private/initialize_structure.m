function [s] = initialize_structure(n, flds)

for i = 1:length(flds); s.(flds{i}) = NaN; end
s = repmat(s, 1, n); 