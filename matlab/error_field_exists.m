function error_field_exists(s, fld)

if ~isfield(s, fld) || isempty(s.(fld))
    error('Required to supply a value for field ''%s''.', fld); 
end