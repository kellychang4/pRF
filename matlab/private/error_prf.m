function [err] = error_prf(params, args)
% [err] = error_prf(params, args)

err = 0; % initialize error term
for i = 1:length(args.bold) % for each bold time series        

    %%% create prf model of unit
    prfModel = args.func.prf(params, args.funcof(i));
    
    %%% multiply stimulus with prfs model
    modelResp = args.stim{i} * prfModel(:); 
    
    %%% (optional) raise to compressive spatial summation exponent
    if args.css; modelResp = modelResp .^ params.exp; end
        
    %%% convolve seed responses with hrf
    hrf = args.func.hrf(args.hrf, 0:args.stim_dt(i):args.tmax);
    convResp = args.stim_dt(i) .* convolve_with_hrf(modelResp, hrf); 
    
    %%% resample at bold tr sampling rate
    predResp = interp1(args.stim_t{i}, convResp, args.bold_t{i});
    
    %%% calculate correlation between bold and predicted response
    tmp = args.func.corr(args.bold{i}, predResp);
    err = err + tmp;

end

%%% mean (negative) cross correlation across all scans
err = -err ./ length(args.bold); 