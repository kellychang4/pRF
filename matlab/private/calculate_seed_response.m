function [seedResp] = calculate_seed_response(protocols, seeds)

opt = get_global_variables('prf.func', 'prf.funcof', 'prf.css'); 
hrfParams = get_global_variables('hrf.defaults'); 

seedResp = cell(length(protocols), 1); 
for i = 1:length(protocols) % for each scan
    %%% extract current protocol variables
    funcof = protocols(i).stim_funcof;
    stim = protocols(i).stim; 
    dt = protocols(i).stim_dt; 
    tStim = protocols(i).stim_t;
    tBold = protocols(i).bold_t;
    
    %%% generate prf models from prf parameter seeds
    seedMat = NaN(numel(funcof.(opt.prfFuncof{1})), length(seeds));
    for i2 = 1:length(seeds) % for each seed
        seedModel = opt.prfFunc(seeds(i2), funcof);
        seedMat(:,i2) = seedModel(:); 
    end
    
    %%% collapse scan stimulus image
    stimImg = reshape(stim, size(stim, 1), []);  
    
    %%% multiply stimulus with seed prfs
    modelResp = stimImg * seedMat; 
    
    %%% (optional) raise to compressive spatial summation exponent
    if opt.prfCss; modelResp = bsxfun(@power, modelResp, [seeds.exp]); end
        
    %%% convolve seed responses with hrf
    convResp = convolve_with_hrf(modelResp, hrfParams, dt); 
    
    %%% resample at bold tr sampling rate
    seedResp{i} = interp1(tStim, convResp, tBold);
end