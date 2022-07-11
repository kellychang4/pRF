function set_global_with_protocol_information(boldFile)

global GLOBAL_PARAMETERS; % declare global variable

[~,~,ext] = extract_fileparts(boldFile);

%%% prf parameters (based on anatomical file extension)
switch ext
    case {'.vmr', '.nii', '.nii.gz'}
        GLOBAL_PARAMETERS.prf.space = 'volume';
        GLOBAL_PARAMETERS.prf.unit = 'voxel';
    case {'.srf', '.gii'}
        GLOBAL_PARAMETERS.prf.space = 'surface';
        GLOBAL_PARAMETERS.prf.units = 'vertex';
end

return
%% Set Global Variables

%%% stimulus / protocol parameters
GLOBAL_PARAMETERS.stim.type = 'image'; % protocol
GLOBAL_PARAMETERS.stim.dt = NaN; % time step, seconds