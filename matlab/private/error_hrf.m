function [err] = error_hrf(params, args)
% [err] = error_hrf(params, args)

err = 0; % initialize error term
for i = 1:length(args.bold) % for each bold time series        
    %%% create prf model of unit
    prfModel = args.prfFunc(args.prf, args.funcof(i));
    
    %%% multiply stimulus with prfs model
    modelResp = args.stim{i} * prfModel(:); 
    
    %%% (optional) raise to compressive spatial summation exponent
    if args.prfCss; modelResp = modelResp .^ args.prf.exp; end
        
    %%% convolve seed responses with hrf
    hrf = args.hrfFunc(params, 0:args.dtStim(i):args.hrfTmax); 
    convResp = args.dtStim(i) .* convolve_with_hrf(modelResp, hrf); 
    
    %%% resample at bold tr sampling rate
    predResp = interp1(args.tStim{i}, convResp, args.tBold{i});
    
    %%% calculate correlation between bold and predicted response
    tmp = corr(args.bold{i}, predResp);
    err = err + tmp;
end

%%% mean (negative) cross correlation across all scans
err = -err ./ length(args.bold); 