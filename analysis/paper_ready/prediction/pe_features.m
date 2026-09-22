function f = pe_features(prep,movement,mo,scale)
    % Time x neuron x trial. Boundaries exactly match validated Stage3 helper.
    count=size(prep,3); neurons=size(prep,2);
    f.aligned=zeros(11,neurons,count,2); f.scale=scale;
    f.targets=repelem((1:8).',30); f.trials=repmat((1:30).',8,1);
    f.moMs=mo(:); f.dimensionOrder='time, neuron, target-major trial, epoch';
    times={(-500:0).',(0:size(movement,1)-1).'};
    for j=1:count
        data={max(prep(:,:,j),0),max(movement(:,:,j),0)};
        centers={-100:10:0,mo(j)+(0:10:100)};
        for e=1:2
            t=times{e}; delta=centers{e}(:)-t.';
            w=exp(-.5*(delta/30).^2); w(abs(delta)>150)=0;
            if e==2, w(:,t<mo(j))=0; end
            assert(max(centers{e})<=t(end) && min(centers{e})>=t(1));
            w=w./sum(w,2); f.aligned(:,:,j,e)=(w*data{e})./scale(:).';
        end
    end
    f.invariant=mean(f.aligned,3); f.aligned=f.aligned-f.invariant;
    f.X=cell(1,2);
    for e=1:2
        f.X{e}=reshape(permute(mean(f.aligned(:,:,:,e),1),[3 2 1]),count,neurons);
    end
end
