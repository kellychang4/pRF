function parallel_progress_bar(n, name, width, bit)
% parallelProgressBar(n, name, width, bit)
%
% Draws an ASCII progress bar. Designed to be implemented during parallel
% processing jobs (parfor) by saving a temporary binary file
% (parallelProgressBar.bin) with an iterative count.
%
% Inputs:
%   n               The total number of iterations perform by parfor.
%                   Negative values deletes 'parallelProgressBar.bin' and
%                   displays a completed progress bar.
%   name           	Name of progress bar, string (default: 'Progress')
%   width           The character width of the progress bar (default: 50)
%   bit             The class specification of integers saved in the
%                   temporary 'parallelProgressBar.bin' binary file, string
%                   (default: 'uint32')
%
% Example:
% n = 100;
% parfor i = 1:n
%   parallelProgressBar(n); % read and writes in the .bin file
% end
% parallelProgressBar(-1); % deletes the .bin file, 100% progress bar

% Adapted primarily from 'parfor_progress.m' by Jeremy Scheff
% Link: http://www.mathworks.com/matlabcentral/fileexchange/32101-progress-monitor--progress-bar--that-works-with-parfor
% Modified by Kelly Chang - June 22, 2016

%% Input Control

if ~exist('name', 'var')
    name = 'Progress:';
end

if ~exist('bit', 'var')
    bit = 'uint32';
end

if ~exist('width', 'var')
    width = 50;
end

%% Parallel Progresss Counter

fileName = fullfile(tempdir, 'parallel_progress_bar.bin');

if n < 0
    delete(fileName);
    disp(repmat(char(10),1,10));
    fprintf('  %s\n   [%s] 100.00%%\n', name, repmat('-',1,width));
else
    if ~exist(fileName, 'file')
        fid = fopen(fileName, 'w');
        fwrite(fid, 0, bit);
        fclose(fid);
    end
    
    fid = fopen(fileName, 'r');
    count = fread(fid, Inf, bit);
    fclose(fid);
    
    fid = fopen(fileName, 'a');
    fwrite(fid, length(count), bit);
    fclose(fid);
    
    p = length(count)/n;
    barLen = round(width*p);
    disp(repmat(char(10),1,10));
    fprintf('  %s\n   [%s%s] %5.2f%%\n', name, repmat('-',1,barLen), ...
        repmat(' ',1,width-barLen), p*100);
end