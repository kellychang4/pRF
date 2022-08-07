function [seedResp] = calculate_seed_response(protocols)

%%% global parameters
[n,prf,seeds,hrf] = get_global_parameters('n', 'prf', 'seeds', 'hrf');

%%% calculate seed response
seedResp = cell(n.protocol, 1);
for i = 1:n.protocol % for each protocol
    %%% extract current protocol variables
    protocol = protocols(i); 
    funcof = protocol.stim_funcof;
    stim   = protocol.stim; 
    dt     = protocol.stim_dt; 
    tStim  = protocol.stim_t;
    tBold  = protocol.bold_t;
    
    %%% generate prf models from prf parameter seeds
    seedMat = NaN(numel(funcof.(prf.funcof{1})), n.seed);
    for i2 = 1:length(seeds) % for each seed
        seedModel = prf.func(seeds(i2), funcof);
        seedMat(:,i2) = seedModel(:); 
    end
    
    %%% collapse scan stimulus image
    stimImg = reshape(stim, size(stim, 1), []);  
    
    %%% multiply stimulus with seed prfs
    modelResp = stimImg * seedMat; 
    
    %%% (optional) raise to compressive spatial summation exponent
    if prf.css; modelResp = bsxfun(@power, modelResp, [seeds.exp]); end
        
    %%% convolve seed responses with hrf
    hemo = hrf.func(hrf.defaults, 0:dt:hrf.tmax);
    convResp = convolve_with_hrf(modelResp, hemo); 
    
    %%% resample at bold tr sampling rate
    seedResp{i} = interp1(tStim, convResp, tBold);
end