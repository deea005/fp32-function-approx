function y = Feval(theta, x)
% Evaluate the encoded piecewise Chebyshev approximation (fp32).
%
% theta is assumed to be single() already (from Rb_transform), 
% but just in case!

    theta = single(theta);
    x = single(x);

    K_single = theta(1);     
    K = int32(K_single);  

    idx = 2;
    m = theta(idx : idx+K-1);     
    idx = idx + K;
    inv_h  = theta(idx : idx+K-1);     
    idx = idx + K;
    D_single = theta(idx : idx+K-1);   
    idx = idx + K;

    % Concatenated Chebyshev coefficients 
    coeffs = theta(idx : end);

    piece = int32(1);   
    t_found = false;

    one_s   = single(1);
    two_s   = single(2);

    for k = int32(1):K
        t_k = (x - m(k)) * inv_h(k);  
        if abs(t_k) <= one_s
            piece   = k;
            t       = t_k;
            t_found = true;
            break;
        end
    end

    % If none matched (due to roundoff), fall back to nearest midpoint.
    if ~t_found
        % abs(x - m) is single, but min returns double index!
        [~, kmin] = min(abs(x - m));
        piece = int32(kmin);
        t = (x - m(piece)) * inv_h(piece);
    end

    offset = int32(0);
    for j = int32(1):piece-1
        Dj = int32(round(D_single(j)));
        offset = offset + (Dj + 1);
    end

    Dj_piece = int32(round(D_single(piece)));
    start_idx = offset + 1;
    deg       = Dj_piece;
    end_idx   = start_idx + deg;

    % Coeffs for this piece as single
    c = coeffs(start_idx:end_idx);   
    b_kp1 = single(0);
    b_kp2 = single(0);

    for k = deg:-1:1
        bk = two_s * t * b_kp1 - b_kp2 + c(k+1);
        b_kp2 = b_kp1;
        b_kp1 = bk;
    end

    y = t * b_kp1 - b_kp2 + c(1);  
end
