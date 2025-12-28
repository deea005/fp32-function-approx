function theta = Rb_transform(p_best)
% Encode a piecewise Chebyshev chebfun into R^B.
% Layout:
%     theta(1) = K
%     theta(2:1+K) = m(1..K)                         % midpoints
%     theta(2+K:1+2*K) = inv_h(1..K)                 % 2/(b-a)
%     theta(2+2*K:1+3*K) = D(1..K)                   % degrees
%     theta(3*K+3:end) = all coeffs c_{k,0..D_k} concatenated

    % Number of pieces
    K = numel(p_best.funs);

    % Breakpoints x0..xK 
    ends = p_best.ends(:);   

    m = zeros(K,1);
    inv_h  = zeros(K,1);
    D = zeros(K,1);
    coeffs = cell(K,1);

    totalCoeffs = 0;

    for k = 1:K
        a = ends(k);
        b = ends(k+1);

        m(k) = 0.5*(a + b);
        inv_h(k) = 2.0/(b - a);   

    
        ck   = chebcoeffs(p_best.funs{k});  
        ck   = ck(:);                      
        D(k) = numel(ck) - 1;

        coeffs{k}   = ck;
        totalCoeffs = totalCoeffs + numel(ck);
    end

    B = 1 + 3*K + totalCoeffs;

    theta = zeros(B,1);
    idx = 1;

    theta(idx) = K;                idx = idx + 1;
    theta(idx:idx+K-1) = m;        idx = idx + K;
    theta(idx:idx+K-1) = inv_h;    idx = idx + K;
    theta(idx:idx+K-1) = D;        idx = idx + K;

    for k = 1:K
        ck  = coeffs{k};
        len = numel(ck);
        theta(idx:idx+len-1) = ck;
        idx = idx + len;
    end

    % Sanity check!
    if idx-1 ~= B
        error('Packing bug: expected length %d, but got %d instead!', B, idx-1);
    end

     theta = single(theta);
end
