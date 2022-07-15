function [convImg] = convolve_with_hrf(img, hrfParams, dt)
% [convImg] = convolve_with_hrf(img, hrfParams, dt)

%% Convolve Model Response with HRF

nt = size(img, 1); 
hrf = create_hrf(hrfParams, dt); 
convImg = dt .* conv2(img, hrf(:));
convImg = convImg(1:nt,:); 