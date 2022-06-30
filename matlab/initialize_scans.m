function [scans] = initialize_scans(scanOpt)

[~,~,ext] = fileparts(scanOpt.boldFiles{1});
switch ext
    case {'.vtc', '.nii.gz', '.nii'} % volume fields
        scanFlds = {
            'matFile', 'funcOf', 'boldFile', 'boldSize', ...
            'nVols', 'dur', 'TR', 'dt', 't', 'voxIndex', 'voxID', ...
            'vtc', 'stimImg'
            };
    case {'.gii'} % surface fields
        scanFlds = {
            'matFile', 'funcOf', 'boldFile', 'boldSize', ...
            'nVols', 'dur', 'TR', 'dt', 't', 'vertex', 'vtc', ...
            'stimImg'
            };
end

for i = 1:length(scanFlds); scans.(scanFlds{i}) = NaN; end
scans = repmat(scans, 1, length(scanOpt.boldFiles));