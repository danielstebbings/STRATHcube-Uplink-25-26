%[text] Locates the largest peak in the frft domain
%[text] Iteratively steps through frft domain and searches for max absolute value, reduces 
function [p_best, best_val] = find_frft_peak(x, n_iterations, p_bounds, verbose)
arguments (Input)
    x
    n_iterations
    p_bounds
    verbose
end

arguments (Output)
    p_best
    best_val
end


p_step     = 10^(floor(log10(p_bounds(2)-p_bounds(1)))-1);
p_best     = 0;
p_current  = p_bounds(2);
best_val   = 0;

for n = 1:n_iterations
    if p_current > p_bounds(1)
        frft_current = frft(x,p_current);
        curmax = max(abs(frft_current));

        if curmax > best_val
            best_val = curmax;
            p_best = p_current;
        end
        p_current = p_current - p_step;

    else
        p_bounds(1) = p_best - p_step;
        p_bounds(2) = p_best + p_step;
        p_current = p_bounds(2);
        p_step = p_step*0.1;
    end

    
    % DEBUG
    if (verbose)
     fprintf("%.0f> p_cur: %.8f | p_best: %.8f | best_val: %.4f | p_step: %.4f \n",n,p_current, p_best, best_val, p_step);
    end
    % 

end

end

%[appendix]{"version":"1.0"}
%---
