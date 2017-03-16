function graphChange(src,pos)

f = src.Parent.Parent; % get to figure handle
fUserData = f.UserData; % grab figure arguments
set(f, 'UserData', round(pos.IntersectionPoint)) % place positions
feval(fUserData{1}, fUserData{2}{:}); % call figure