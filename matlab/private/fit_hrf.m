function [fitParams] = fit_hrf(initParams)
% [fitParams] = fit_hrf(initParams)
%
% Returns a structure containing the best fitting parameters after an
% iterative HRF and pRF fitting.
%
% The HRF fitting process only takes the voxels that have passed the
% specified correlation threshold 'opt.hrfThr' and/or are apart of the top
% fitting percentage 'opt.topHRF'.
%
% While holding the pRF parameters constant, the HRF free parameters are
% fitted. Then the estimated HRF parameters are held constant, the pRF
% parameters are fitted again. This process repeats for the specified
% 'opt.estHRF' iterations.
%
% Inputs:
%   fitParams       A structure of parameter values of HRF and pRF that are
%                   to be fitted as fields
%
% Output:
%   fittedParams    A structure with the best fitting parameters from
%                   fitting the HRF and pRF model.

% Written by Kelly Chang - February 2, 2017
% Edited by Kelly Chang - July 15, 2022

%% Fit HRF

fitParams = initParams;
[parallelFlag, freeList] = get_global_variables('fit.parallel', 'hrf.free');
globalArgs = get_global_variables('prf.func', 'stim', 'funcof', ...
    'prf.css', 'dt.stim', 'hrf.func', 'hrf.tmax', 't.stim', 't.bold');

switch parallelFlag
    case 0
        fprintf('crying\n'); 
    case 1
       
        parfor i = 1:length(initParams) % for each unit
            fprintf('Vertex %4d of %d\n', i, length(initParams)); 
            
            %%% separate hrf parameters and other information
            params = initParams(i).hrf; % hrf parameters
            args = combine_structures(globalArgs, ...
                rmfield(initParams(i), 'hrf'));  
            
            %%% call 'fitcon' on unit
            [outParams,err] = fitcon(@error_hrf, params, freeList, args);
            
            %%% save fitted parameter outputs
            fitParams(i).hrf = outParams;
            fitParams(i).corr = -err; 
        end
end