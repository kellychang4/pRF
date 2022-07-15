function [convImg] = convolve_with_hrf(img, hrf)
% [convImg] = convolve_with_hrf(img, hrfParams, dt)

%% Convolve Model Response with HRF
 
convImg = conv2(img, hrf(:));
convImg = convImg(1:size(img, 1), :); 