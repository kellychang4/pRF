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
% Outputs:
%   tbl            A Mx2 table where M is the number of scans. The first
%                  column reports the paradigm file(s) and the second 
%                  column reports the .vtc file(s)

% Written by Kelly Chang - July 13, 2016

%% Create Table

tbl = struct2table(collated.scan);
tbl = cell2table(tbl{:, {'paradigmFile', 'vtcFile'}});
tbl.Properties.VariableNames = {'Paradigm' 'VTC'};