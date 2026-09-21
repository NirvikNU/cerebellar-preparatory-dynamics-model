function K=paper95_k(ev)
    assert(all(isfinite(ev)) && all(ev>=0) && sum(ev)>0);
    K=find(cumsum(ev)/sum(ev)>=.95,1,'first');
end
