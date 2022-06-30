function [fname] = filename(filepath)

[~,name,ext] = fileparts(filepath);
if ischar(filepath)
    fname = char([name ext]); 
else
    fname = cellfun(@(x,y) [x y], name, ext, 'UniformOutput', false); 
end

