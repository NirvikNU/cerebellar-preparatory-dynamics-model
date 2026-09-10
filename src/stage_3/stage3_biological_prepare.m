function p = stage3_biological_prepare(m,d,c,flags)
    % Native evidence for a fixed pair/policy; flags are [b-on,FB-on].
    assert(m.dt==.0002 && m.tau==.15 && numel(flags)==2);
    steps=round(.5/m.dt); stride=round(.001/m.dt);
    x=repmat(m.spontaneous,1,8);
    p.nativeStates=zeros(m.n,8,steps+1);
    p.distanceStar=zeros(501,8); p.distanceBlock=zeros(501,8);
    p.prospectiveError=zeros(501,8); p.componentNorms=zeros(501,8,5);
    p.nativeRateMax=0; p.nativeStateNormMax=0; p.nativeComponentMax=zeros(1,5);
    p.flags=flags; p.timeAfterCueMs=(0:500).'; p.dt=m.dt;
    p.componentNames={'u0','b delivered','FB delivered','CB delivered','total'};
    for step=0:steps
        u0=-c.fB-c.kappa0*(x-d.xB); b=flags(1)*c.b;
        fb=-flags(2)*c.L*(x-m.xstar); total=u0+b+fb;
        parts={u0,b,fb,b+fb,total};
        norms=zeros(8,5);
        for j=1:5, norms(:,j)=vecnorm(parts{j}).'; end
        p.nativeRateMax=max(p.nativeRateMax,max(max(x,0),[],'all'));
        p.nativeStateNormMax=max(p.nativeStateNormMax,max(vecnorm(x)));
        p.nativeComponentMax=max(p.nativeComponentMax,max(norms,[],1));
        p.nativeStates(:,:,step+1)=x;
        if mod(step,stride)==0
            sample=1+step/stride; dx=x-m.xstar;
            p.distanceStar(sample,:)=vecnorm(dx);
            p.distanceBlock(sample,:)=vecnorm(x-d.xB);
            p.prospectiveError(sample,:)=sum(dx.*(c.Q*dx),1);
            p.componentNorms(sample,:,:)=reshape(norms,1,8,5);
        end
        if step<steps, x=x+m.dt/m.tau*(-x+m.W*max(x,0)+m.h+total); end
        assert(all(isfinite(x),'all'),'Stage3Bio:Nonfinite','Nonfinite preparation');
    end
    p.go=x;
    p.states=permute(p.nativeStates(:,:,1:stride:end),[3 1 2]);
    p.rates=max(p.states,0);
    cue=p.prospectiveError(1,:); p.degenerateCue=cue<=100*eps(max(1,max(cue)));
    p.normalizedProspective=p.prospectiveError./cue;
    p.normalizedProspective(:,p.degenerateCue)=NaN;
    p.relativeSettle=vecnorm(x-d.xB)./max(1,vecnorm(d.xB-m.spontaneous));
    % No interpolation or selection from first-crossing diagnostics.
    p.crossingMs=nan(8,4);
    for q=1:8
        curves=[p.normalizedProspective(:,q),p.distanceStar(:,q)/p.distanceStar(1,q)];
        for metric=1:2
            for level=1:2
                threshold=[.5 .1]; k=find(curves(:,metric)<=threshold(level),1);
                if ~isempty(k), p.crossingMs(q,(metric-1)*2+level)=k-1; end
            end
        end
    end
    p.readinessMs=[50 100 200];
    p.readinessEQ=p.normalizedProspective(p.readinessMs+1,:);
    p.readinessState=p.distanceStar(p.readinessMs+1,:)./p.distanceStar(1,:);
end
