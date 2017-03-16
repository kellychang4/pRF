function y = gaussian(mu,sigma,x)

y = exp(-((x-mu).^2)/(2*sigma^2));