function p_best = Fapprox(dom, f, eps)
% Choose between global and piecewise Chebyshev by cost B.
%   dom : [a b]
%   f   : @(x) ...
%   eps : chebfuneps tolerance
%

    p = chebfunpref();
    p.chebfuneps = eps;
    chebfunpref.setDefaults(p);

    %% Global Chebyshev (splitting OFF)
    p_off = chebfun(f, dom, 'splitting', 'off', p);
    D_off = length(p_off) - 1;
    K_off = 1;

  
    B_off = 1 + 3*K_off + (D_off + 1);
    p_best = p_off;
    best_B = B_off;

    %% Piecewise Chebyshev (splitting ON)
    p_on = chebfun(f, dom, 'splitting', 'on', p);

    % Degrees per piece
    Dks = cellfun(@(g) length(g) - 1, p_on.funs);
    K   = numel(Dks);

    % B_on = 1 + 3K + sum(D_k+1)
    B_on = 1 + 3*K + sum(Dks + 1);

    % Choose cheaper representation
    if B_on < best_B
        p_best = p_on;
        best_B = B_on; %#ok<NASGU> % To inspect B if needed!
    end
end
