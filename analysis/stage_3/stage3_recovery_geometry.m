function g = stage3_recovery_geometry(rates,scale)
    % Independent explicit neuron/target/time observations and eigen geometry.
    [nt,nn,nq]=size(rates); X=zeros(nt*nq,nn);
    for neuron=1:nn
        for time=1:nt
            meanTarget=sum(rates(time,neuron,:),'all')/nq;
            for target=1:nq
                X(time+(target-1)*nt,neuron)=(rates(time,neuron,target)-meanTarget)/scale(neuron);
            end
        end
    end
    X=X-sum(X,1)/size(X,1); C=X.'*X/(size(X,1)-1);
    [basis,D]=eig((C+C.')/2); [ev,order]=sort(diag(D),'descend');
    g=struct('matrix',X,'covariance',C,'basis',basis(:,order),'eigenvalues',ev, ...
        'pr',trace(C)^2/trace(C*C),'k',find(cumsum(ev)>.95*sum(ev),1));
end
