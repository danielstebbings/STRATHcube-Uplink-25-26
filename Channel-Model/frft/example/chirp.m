%[text] Complex LFM Chirp
%[text] Detailed explanation of this function.
function y = chirp(t,f0, k)
arguments (Input)
    t
    f0
    k
end

arguments (Output)
    y
end

y = exp(1i * 2*pi* (f0*t + 1/2 * k * t.^2));

end

%[appendix]{"version":"1.0"}
%---
