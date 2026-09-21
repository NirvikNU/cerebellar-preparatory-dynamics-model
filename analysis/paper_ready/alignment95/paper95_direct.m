function g=paper95_direct(rates,scale)
    % Independent neuron-column construction and covariance eigensystem.
    X=zeros(size(rates,1)*size(rates,3),numel(scale));
    for neuron=1:numel(scale)
        a=squeeze(rates(:,neuron,:))/scale(neuron);
        a=a-sum(a,2)/size(a,2); X(:,neuron)=a(:);
    end
    X=X-sum(X,1)/size(X,1); C=X.'*X/(size(X,1)-1);
    [B,D]=eig((C+C.')/2); [ev,ix]=sort(max(diag(D),0),'descend'); B=B(:,ix);
    cumulative=0; K=0;
    while cumulative/sum(ev)<.95, K=K+1; cumulative=cumulative+ev(K); end
    g=struct('cov',C,'eigenvalues',ev,'basis',B,'k',K,'pr',trace(C)^2/trace(C*C),'X',X);
end
