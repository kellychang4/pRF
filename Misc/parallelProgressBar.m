function parallelProgressBar(n, opt)
% parallelProgressBar(n, opt)
%
% Draws an ASCII progress bar. Designed to be implemented during parallel
% processing jobs (parfor) by saving a temporary binary file
% (parallelProgressBar.bin) with an iterative count.
%
% Inputs:
%   n               The total number of iterations perform by parfor.
%                   Negative values deletes 'parallelProgressBar.bin' and
%                   displays a completed progress bar.
%   opt             A structure containing fields that specify additional
%                   options:
%       title       Title of progress bar, string (default: 'Progress')
%       bit         The class specification of integers saved in the
%                   temporary 'parallelProgressBar.bin' binary file, string
%                   (default: 'uint32')
%       width       The character width of the progress bar (default: 50)
%
% Example:
% n = 100;
% parfor i = 1:n
%   parallelProgressBar(n); % read and writes in the .bin file
% end
% parallelProgressBar(-1); % deletes the .bin file, 100% progress bar

% Adapted primarily from 'parfor_progress.m' by Jeremy Scheff
% Link: http://www.mathworks.com/matlabcentral/fileexchange/32101-progress-monitor--progress-bar--that-works-with-parfor
% Modified by Kelly Chang for pRF fitting - June 22, 2016

%% Input Control

if ~exist('opt', 'var')
    opt = struct();
end

if ~isfield(opt, 'title')
    opt.title = 'Progress:';
end

if ~isfield(opt, 'bit')
    opt.bit = 'uint32';
end

if ~isfield(opt, 'width')
    opt.width = 50;
end

%% Parallel Progresss Counter

fileName = fullfile(tempdir, 'parallelProgressBar.bin');

if n < 0
    delete(fileName);
    disp(repmat(char(10),1,10));
    disp(['  ' opt.title]);
    disp(['   [' repmat('-',1,opt.width) '] 100.00%']);
else
    if ~exist(fileName, 'file')
        fid = fopen(fileName, 'w');
        fwrite(fid, 0, opt.bit);
        fclose(fid);
    end
    
    fid = fopen(fileName, 'r');
    count = fread(fid, Inf, opt.bit);
    fclose(fid);
    
    fid = fopen(fileName, 'a');
    fwrite(fid, length(count), opt.bit);
    fclose(fid);
    
    p = length(count)/n;
    barLen = round(opt.width*p);
    disp(repmat(char(10),1,10));
    disp(['  ' opt.title]);
    disp(['   [' repmat('-',1,barLen) repmat(' ',1,opt.width-barLen) '] ' ...
        sprintf('%5.2f%%', p*100)]);
end