function g=paper95_geometry(rates,scale)
    % Same native preprocessing; only the Control-derived >=95% rule changes.
    g=paper_geometry(rates,scale);
    g.k=paper95_k(g.eigenvalues);
    assert(~isempty(g.k) && g.k<=g.rank,'Invalid Control spectrum');
    g.captureControl=sum(g.eigenvalues(1:g.k))/sum(g.eigenvalues);
    g.beforeControl=sum(g.eigenvalues(1:g.k-1))/sum(g.eigenvalues);
    assert(g.captureControl>=.95 && g.beforeControl<.95);
end
