function receipt=landscape_production(root)
    c=landscape_paths(root); pre=jsondecode(fileread(fullfile(c.land,'preflight.json'))); assert(strcmp(pre.status,'PASS'));
    assert(~isfile(fullfile(c.land,'production.json')));
    receipt=struct('status','running','networks',0,'perturbedMovements',0); started=tic;
    target=load(fullfile(c.gate1.targetRoot,'stage1_gate1_targets.mat'),'target');
    desired=target.target.initialHand([1 3])+target.target.endpointDisplacement;
    for n=1:10
        s=load(fullfile(c.gate1.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(c.cache,sprintf('baseline_%02d.mat',n))); base=s.base; scale=s.scale;
        path=fullfile(c.cache,sprintf('landscape_%02d.mat',n)); assert(~isfile(path));
        result=landscape_search(m,base,scale,s.plane,n,c); save(path,'result','-v7.3');
        [V,L]=eig((m.Qnative+m.Qnative.')/2,'vector'); [lambda,order]=sort(L,'descend'); V=V(:,order);
        for j=1:m.n
            [~,index]=max(abs(V(:,j))); if V(index,j)<0, V(:,j)=-V(:,j); end
        end
        stream=RandStream('mt19937ar','Seed',2026091600+n); random=randn(stream,m.n,10); random=random./vecnorm(random);
        directions=[V(:,1:5) V(:,end-4:end) random]; classes=[ones(1,5) 2*ones(1,5) 3*ones(1,10)];
        targetIds=repelem(1:8,40); directionIds=repmat(repelem(1:20,2),1,8); signs=repmat([-1 1],1,160);
        metric=zeros(320,6,7); metric(:,1,1)=NaN;
        for j=1:320
            q=targetIds(j); metric(j,1,5)=1000*norm(base.hand(end,[1 3],q)-desired(q,:));
        end
        for a=2:6
            path=fullfile(c.cache,sprintf('perturb_n%02d_a%d.mat',n,a)); assert(~isfile(path));
            delta=c.fractions(a)*scale*directions(:,directionIds).*signs;
            out=landscape_trace(m,m.xstar(:,targetIds)+delta,base,targetIds);
            values=landscape_metrics(m,out,base,targetIds,desired); metric(:,a,:)=reshape(values,320,1,7);
            save(path,'out','values','targetIds','directionIds','signs','-v7.3');
            receipt.perturbedMovements=receipt.perturbedMovements+320;
        end
        path=fullfile(c.land,sprintf('network_%02d.mat',n)); assert(~isfile(path));
        save(path,'metric','directions','classes','lambda','targetIds','directionIds','signs','scale');
        receipt.networks=n; fprintf('Landscape/sensitivity network %02d/10 complete: %d perturbations (%.1fs)\n',n,receipt.perturbedMovements,toc(started));
    end
    receipt.status='PASS'; receipt.elapsedSeconds=toc(started);
    landscape_json(fullfile(c.land,'production.json'),receipt); landscape_json(fullfile(c.manifest,'PRODUCTION.json'),receipt);
end
