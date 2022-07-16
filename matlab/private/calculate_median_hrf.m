function [fitParams] = calculate_median_hrf(fitParams)

hrfParams = cat(1, fitParams.hrf);

flds = fieldnames(hrfParams);
for i = 1:length(flds) % for each field
    mdn.(flds{i}) = median([hrfParams.(flds{i})]); 
end

for i = 1:length(fitParams)
    fitParams(i).hrf = mdn; 
end