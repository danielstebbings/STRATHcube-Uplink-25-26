function [sigOut] = add_chirp(sigIn,t,fs, T, f0, f1, sir)
%ADD_CHIRP Adds chirp signal based on parameters to signal
%   Detailed explanation goes here

% cmplx int arith not supported in simulink.
sigIn = double(sigIn);
fs = double(fs);
t = double(t);
T = double(T);
f0 = double(f0);
f1 = double(f1);
sir = double(sir);


B  = f1 - f0;
k  = B/(T);
A  = 1/sir * (2^12 -1); % Input mag
chirpsig =  A*exp(1i * 2*pi * (f0.*t + 0.5*k.*t.^2));

sigOut = sigIn + chirpsig;
sigOut = complex(double(sigOut));
end