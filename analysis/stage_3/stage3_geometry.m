function g = stage3_geometry(rates, scale)
    % Input [time,neuron,target]; columns remain individual neurons.
    normalized=rates./reshape(scale,1,[],1);
    normalized=normalized-mean(normalized,3);
    X=reshape(permute(normalized,[1 3 2]),[],numel(scale));
    X=X-mean(X,1);
    g.matrix=X; g.covariance=(X.'*X)/(size(X,1)-1);
    [~,S,g.basis]=svd(X,'econ');
    g.eigenvalues=diag(S).^2/(size(X,1)-1);
    g.pr=sum(g.eigenvalues)^2/sum(g.eigenvalues.^2);
    g.k=find(cumsum(g.eigenvalues)/sum(g.eigenvalues)>.95,1);
    g.capture=sum(g.eigenvalues(1:g.k))/sum(g.eigenvalues);
    g.gap=g.eigenvalues(g.k)-g.eigenvalues(g.k+1);
    direct=trace(g.covariance)^2/sum(g.covariance.^2,'all');
    assert(abs(g.pr-direct)<1e-10);
end
