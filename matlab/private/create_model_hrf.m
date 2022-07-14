function [hemo] = create_model_hrf(protocols)

HRF = get_global_variables('hrf');

hemo = cell(length(protocols), 1); 
for i = 1:length(protocols) % for each protocol
    t = 0:protocols(i).stim_dt:HRF.tmax;
    hemo{i} = HRF.model(hrfParams, t);
end