function out = paper_prepare(m,definitions,c,flags,si,st,noise,dt,keepStates,keepNative)
    % Batched native preparation; candidates share exactly the same trial draws.
    if nargin<10, keepNative=false; end
    if nargin<9, keepStates=false; end
    if nargin<8, dt=m.dt; end
    steps=round(.5/dt); stride=round(.001/dt); G=numel(definitions);
    targets=noise.targets; targetIDs=unique(targets,'stable'); nt=numel(targetIDs);
    count=numel(targets); trials=count/nt; assert(trials==round(trials));
    assert(isequal(targets,repelem(targetIDs,trials)));
    star=repmat(m.xstar(:,targets),1,G);
    xb=cellfun(@(d)d.xB(:,targets),definitions,'UniformOutput',false); xb=cat(2,xb{:});
    fB=-xb+m.W*max(xb,0)+m.h;
    fS=-star+m.W*max(star,0)+m.h;
    b=fB-fS+c.kappa0*(star-xb);
    x=repmat(m.spontaneous+si*noise.initial,1,G);
    template=struct('meanRates',zeros(501,200,nt),'lateRates',zeros(11,200,count), ...
        'distanceStar',zeros(501,nt),'distanceBlock',zeros(501,nt),'eq',zeros(501,nt), ...
        'rateMax',0,'stateMax',0,'componentMax',zeros(1,5),'counterfactualMax',zeros(1,5), ...
        'initial',[],'go',[],'flags',flags,'sInit',si,'sTemporal',st, ...
        'seeds',noise.seeds,'dt',dt,'audit',[],'states',[],'nativeStates',[]);
    out=repmat(template,1,G);
    for g=1:G
        out(g).initial=x(:,(g-1)*count+(1:count));
        if keepStates, out(g).states=zeros(501,200,count); end
        if keepNative, out(g).nativeStates=zeros(200,count,steps+1); end
    end
    for step=0:steps
        rate=max(x,0); u0=-fB-c.kappa0*(x-xb); fb=-c.L*(x-star);
        total=u0+flags(1)*b+flags(2)*fb;
        parts={u0,flags(1)*b,flags(2)*fb,flags(1)*b+flags(2)*fb,total};
        counter={u0,b,fb,b+fb,u0+b+fb};
        for g=1:G
            ix=(g-1)*count+(1:count);
            if keepNative, out(g).nativeStates(:,:,step+1)=x(:,ix); end
            out(g).rateMax=max(out(g).rateMax,max(rate(:,ix),[],'all'));
            out(g).stateMax=max(out(g).stateMax,max(vecnorm(x(:,ix))));
            for j=1:5
                out(g).componentMax(j)=max(out(g).componentMax(j),max(vecnorm(parts{j}(:,ix))));
                out(g).counterfactualMax(j)=max(out(g).counterfactualMax(j),max(vecnorm(counter{j}(:,ix))));
            end
            if mod(step,stride)==0
                sample=step/stride+1;
                out(g).meanRates(sample,:,:)=permute(squeeze(mean(reshape(rate(:,ix),200,trials,nt),2)),[3 1 2]);
                dx=x(:,ix)-star(:,ix); db=x(:,ix)-xb(:,ix);
                out(g).distanceStar(sample,:)=mean(reshape(vecnorm(dx),trials,nt),1);
                out(g).distanceBlock(sample,:)=mean(reshape(vecnorm(db),trials,nt),1);
                out(g).eq(sample,:)=mean(reshape(sum(dx.*(c.Q*dx),1),trials,nt),1);
                if sample>=401 && mod(sample-401,10)==0
                    out(g).lateRates(1+(sample-401)/10,:,:)=permute(rate(:,ix),[3 1 2]);
                end
                if keepStates, out(g).states(sample,:,:)=permute(x(:,ix),[3 1 2]); end
            end
        end
        if step==steps, break; end
        increment=st*sqrt(2*dt/m.tau)*repmat(noise.process(:,:,step+1),1,G);
        next=x+dt/m.tau*(-x+m.W*rate+m.h+total)+increment;
        if ismember(step,[0 round(steps/2) steps-1])
            for g=1:G
                ix=(g-1)*count+(1:count);
                a=struct('step',step,'x',x(:,ix),'next',next(:,ix),'noiseIncrement',increment(:,ix));
                out(g).audit=[out(g).audit,a];
            end
        end
        assert(all(isfinite(next),'all'),'Paper:Nonfinite','Nonfinite preparation, do not retune.');
        x=next;
    end
    for g=1:G, out(g).go=x(:,(g-1)*count+(1:count)); end
end
