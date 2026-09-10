function [P,Q] = stage3_bio_projector(C,K,draws,seed)
    % Frozen sampler; orth and QR provide independent representations.
    [U,S,~]=svd(C); bias=U*diag(sqrt(max(diag(S),0)));
    stream=RandStream('mt19937ar','Seed',seed); P=zeros(size(C)); Q=P;
    for draw=1:draws
        G=randn(stream,size(C,1),K); G=G./sqrt(sum(G.^2,1));
        weighted=bias*G; B=orth(weighted); [R,~]=qr(weighted,0);
        assert(size(B,2)==K); P=P+B*B.'; Q=Q+R*R.';
    end
    P=P/draws; Q=Q/draws;
    assert(max(abs(P-Q),[],'all')<1e-10);
end
