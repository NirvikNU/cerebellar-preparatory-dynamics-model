function g = paper_geometry(rates,scale)
    % Rates [time,neuron,target]; trial averaging must happen before this call.
    normalized=rates./reshape(scale,1,[],1);
    normalized=normalized-mean(normalized,3);
    X=reshape(permute(normalized,[1 3 2]),[],numel(scale)); X=X-mean(X,1);
    [~,S,B]=svd(X,'econ'); sv=diag(S); ev=sv.^2/(size(X,1)-1);
    g.pr=sum(ev)^2/sum(ev.^2); g.cov=X.'*X/(size(X,1)-1);
    g.eigenvalues=ev; g.basis=B;
    g.rankThreshold=100*max(size(X))*eps(max(sv)); g.rank=sum(sv>g.rankThreshold);
    g.k=find(cumsum(ev)>.95*sum(ev),1); g.capture15=sum(ev(1:15))/sum(ev);
    g.k15Valid=g.rank>=15 && all(isfinite(ev));
    g.tracePR=trace(g.cov)^2/sum(g.cov.^2,'all');
    assert(abs(g.pr-g.tracePR)<1e-10);
end
