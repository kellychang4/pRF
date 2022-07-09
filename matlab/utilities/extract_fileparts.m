function [fpath,name,ext] = extract_fileparts(fileName)
% [filePath,name,ext] = EXTRACT_FILEPARTS(fileName)
% 
% Extracts the given file name's path, base name, and extension including
% compression extensions (e.g., '.gz', '.zip').
%
%
% Argument:
%   fileName            String, file name.
%                       Example: '/path/to/filename.nii.gz'
%
%
% Outputs:
%   fpath               File paths, string.
%                       Example: '/path/to'
% 
%   name                File base name, string.
%                       Example: 'filename'
% 
%   ext                 File extension, includes compression extensions,
%                       string.
%                       Example: '.nii.gz'


% Written by Kelly Chang - February 10, 2022

%% Extract File Parts

charFlag = ischar(fileName); 
[fpath,name,ext] = fileparts(fileName);

if charFlag; fpath = {fpath}; name = {name}; ext = {ext}; end

for i = 1:length(ext) % for each extension
    %%% if compressed file, extract base name again
    if any(strcmp(ext{i}, {'.gz', '.zip'}))
        [~,name{i},baseExt] = fileparts(name{i});
        ext{i} = [baseExt, ext{i}];
    end
end

if charFlag; fpath = char(fpath); name = char(name); ext = char(ext); end