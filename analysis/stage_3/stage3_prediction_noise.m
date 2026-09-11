function noise = stage3_prediction_noise(m,network,targets,trials)
    % RNG dimension order is neuron x native-step for each unique trial.
    count=numel(targets); steps=round(.5/m.dt)+m.nInternalSteps;
    noise.initial=zeros(m.n,count); noise.process=zeros(m.n,count,steps);
    noise.seeds=zeros(1,count);
    for j=1:count
        seed=310000000+10000*network+100*targets(j)+trials(j);
        stream=RandStream('mt19937ar','Seed',seed);
        noise.seeds(j)=seed;
        noise.initial(:,j)=randn(stream,m.n,1);
        noise.process(:,j,:)=reshape(randn(stream,m.n,steps),m.n,1,steps);
    end
end
