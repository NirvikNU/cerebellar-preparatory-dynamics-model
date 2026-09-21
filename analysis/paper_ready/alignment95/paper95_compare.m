function [observed,expected,den,K,capture]=paper95_compare(control,comparison,P)
    K=control.k; assert(size(comparison.basis,2)>=K && comparison.rank>=K);
    assert(abs(trace(P)-K)<1e-8,'Null projector dimensionality mismatch');
    den=sum(control.eigenvalues(1:K)); B=comparison.basis(:,1:K);
    observed=trace(B.'*control.cov*B)/den;
    expected=trace(control.cov*P)/den;
    capture=sum(comparison.eigenvalues(1:K))/sum(comparison.eigenvalues);
end
