function fields2vars(s)

flds = fieldnames(s);
for i = 1:length(flds)
    assignin('caller', flds{i}, s.(flds{i}));
    fprintf('  Created variable ''%s''.\n', flds{i});
end
