function noise = paper_noise(n,targets,trials,steps)
    % Same frozen per-trial order; preparation-only prefix, no new seeds.
    noise.initial=zeros(200,numel(targets));
    noise.targets=targets;
    noise.process=zeros(200,numel(targets),steps);
    noise.seeds=310000000+10000*n+100*targets+trials;
    for j=1:numel(targets)
        stream=RandStream('mt19937ar','Seed',noise.seeds(j));
        noise.initial(:,j)=randn(stream,200,1);
        noise.process(:,j,:)=reshape(randn(stream,200,steps),200,1,steps);
    end
end
