function [hrf] = create_hrf(hrfParams, dt)

opt = get_global_variables('hrf.tmax', 'hrf.func'); 
hrf = opt.hrfFunc(hrfParams, 0:dt:opt.hrfTmax); 