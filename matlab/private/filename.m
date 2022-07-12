function [fname] = filename(fpath)

[~,fname,ext] = extract_fileparts(fpath);
fname = [fname ext]; 