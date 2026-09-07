function values = stage3_recovery_null(fullCov,refCov,den,K,draws,seed)
    % Same declared Gaussian identities and covariance factor; independent QR projector.
    [left,D,~]=svd(fullCov); root=left*diag(sqrt(max(diag(D),0)));
    random=RandStream('mt19937ar','Seed',seed); values=zeros(draws,1);
    for j=1:draws
        G=randn(random,size(fullCov,1),K); G=G./sqrt(sum(G.^2,1));
        [Q,R]=qr(root*G,0); assert(all(abs(diag(R))>0));
        values(j)=sum(sum(Q.*(refCov*Q)))/den;
    end
end
