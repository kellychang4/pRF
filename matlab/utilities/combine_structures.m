function [S] = combine_structures(s1, s2)
% [S] = combine_structures(s1, s2)

%%% original fieldnames from structures 1 and 2
flds1 = fieldnames(s1); flds2 = fieldnames(s2);

%%% extract overlapping fieldnames between both structures
[sameFlds,indx1,indx2] = intersect(flds1, flds2);

%%% create output flds names in case of fieldname overlaps
outFlds1 = flds1; outFlds2 = flds2;
outFlds1(indx1) = strcat(sameFlds, '_1'); 
outFlds2(indx2) = strcat(sameFlds, '_2'); 

%%% assign fields from structure 1
for i = 1:length(flds1) % for each field
    S.(outFlds1{i}) = s1.(flds1{i});
end
 
%%% assign fields from structure 2
for i = 1:length(flds2) % for each field
    S.(outFlds2{i}) = s2.(flds2{i});
end
