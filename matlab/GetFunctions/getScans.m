function [tbl] = getScans(collated)
% [tbl] = getScans(collated)
%
% Returns a Mx2 table where M is the number of scans. The first columns
% reports the paradigm file(s) and the second column reports the .vtc
% file(s).
%
% Input:
%   collated       A structure containing all fitted pRF information as
%                  as given by [collated] = estpRF(scan, seeds, hrf, opt)
%
% Output:
%   tbl            A Mx2 table where M is the number of scans. The first
%                  column reports the .mat file(s) and the second
%                  column reports the bold file(s) (BrainVoyager or
%                  FreeSurfer)

% Written by Kelly Chang - July 13, 2016

%% Create Table

if length(collated.scan) < 1
    tbl = table({collated.scan.matFile}, {collated.scan.boldFile}, ...
        'VariableNames', {'MAT' 'BOLD'});
else
    tbl = struct2table(collated.scan);
    tbl = cell2table(tbl{:, {'matFile', 'boldFile'}});
    tbl.Properties.VariableNames = {'MAT' 'BOLD'};
end