function y = gammaHRF(n,tau,delta,t)

t = t - delta;
y = (t/tau).^(n-1) .* exp(-t/tau)/(tau*factorial(n-1));
y(t < 0) = 0;