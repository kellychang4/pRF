function update_global_variables(scans, seeds, hrf, opt)

global GLOBAL_PARAMETERS; % declare global variable

%%% fitting parameters
GLOBAL_PARAMETERS.prf_free_params = {'test'}; %extract_parameter_names(opt.freeList);

%%% data space (volumetric, surface)
GLOBAL_PARAMETERS.anat_space = 'volume'; % 'surface';
GLOBAL_PARAMETERS.unit = 'voxel'; % ,'vertex';
GLOBAL_PARAMETERS.n_units = 100; % length(scans(1).(unit));
GLOBAL_PARAMETERS.output_flds = {'hello', 'world'}; % [UNIT, 'didFit', 'corr', 'bestSeed'];

%%% hrf parameters
switch hrf.funcName
    case {'Boynton'}
        GLOBAL_PARAMETERS.hrf_model = @hrf_boynton;
        GLOBAL_PARAMETERS.hrf_free_params = {'tau', 'delta'};
    case {'Two Gamma'}
        GLOBAL_PARAMETERS.hrf_model = @hrf_two_gamma;
        GLOBAL_PARAMETERS.hrf_free_params = {};
end

%%% organizational parameters



