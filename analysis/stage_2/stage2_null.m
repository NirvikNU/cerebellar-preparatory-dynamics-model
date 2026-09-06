function values = stage2_null(fullCov, refCov, denominator, k, draws, seed)
    % Independently implemented covariance-biased Elsayed subspace sampler.
    [U,S,~] = svd(fullCov);
    bias = U*diag(sqrt(max(diag(S),0)));
    stream = RandStream('mt19937ar','Seed',seed);
    values = zeros(draws,1);
    for draw = 1:draws
        G = randn(stream,size(fullCov,1),k);
        G = G./sqrt(sum(G.^2,1));
        basis = orth(bias*G);
        assert(size(basis,2)==k,'Rank-deficient random subspace.');
        values(draw) = trace(basis.'*refCov*basis)/denominator;
    end
    assert(all(isfinite(values)) && min(values)>-1e-10 && max(values)<1+1e-8);
end
