function features = stage3_prediction_features(out,scale)
    % Native saved layout: time x neuron x trial; never reshape across neurons.
    rates=max(out.states,0); count=size(rates,3); neurons=size(rates,2);
    assert(numel(scale)==neurons && all(isfinite(scale) & scale>0));
    features.aligned=zeros(11,neurons,count,3);
    features.dimensionOrder='aligned time, neuron, trial, epoch';
    features.epochNames={'Prep GO -100:10:0','Early MO 0:10:100','Prepeak -150:10:-50'};
    time=out.timeGOms(:); assert(all(diff(time)==1));
    for j=1:count
        centers={-100:10:0,out.moMs(j)+(0:10:100),out.peakMs(j)+(-150:10:-50)};
        lower=[time(1),out.moMs(j),time(1)]; upper=[0,time(end),out.peakMs(j)-50];
        for epoch=1:3
            delta=centers{epoch}(:)-time.';
            weights=exp(-.5*(delta/30).^2);
            weights(abs(delta)>150 | time.'<lower(epoch) | time.'>upper(epoch))=0;
            assert(all(sum(weights,2)>0) && min(centers{epoch})>=time(1) && max(centers{epoch})<=time(end));
            weights=weights./sum(weights,2);
            features.aligned(:,:,j,epoch)=(weights*rates(:,:,j))./scale(:).';
        end
    end
    features.invariant=mean(features.aligned,3);
    features.aligned=features.aligned-features.invariant;
    features.X=cell(1,3);
    for epoch=1:3
        features.X{epoch}=reshape(permute(mean(features.aligned(:,:,:,epoch),1),[3 2 1]),count,neurons);
    end
    features.scale=scale; features.targets=out.targets(:); features.trials=out.trials(:);
    features.peakPosition=out.peakPosition; features.peakSpeed=out.peakSpeed;
    features.moMs=out.moMs; features.peakMs=out.peakMs;
end
