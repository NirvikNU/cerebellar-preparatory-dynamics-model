function out = paper_move(m,go)
    % Deterministic frozen movement with native extrema and raw arm evidence.
    x=go; count=size(go,2); out.go=go; out.rateMax=0; out.stateMax=0;
    out.torque=zeros(m.nSamples,2,count); sample=0; stride=round(m.samplingDt/m.dt);
    out.audit=[];
    for step=0:m.nInternalSteps-1
        r=max(x,0); out.rateMax=max(out.rateMax,max(r,[],'all'));
        out.stateMax=max(out.stateMax,max(vecnorm(x)));
        if mod(step,stride)==0
            sample=sample+1; out.torque(sample,:,:)=permute(m.C*r,[3 1 2]);
        end
        drive=published_movement_input(step*m.dt,m);
        next=x+m.dt/m.tau*(-x+m.W*r+m.h+drive);
        if ismember(step,[0 floor(m.nInternalSteps/2) m.nInternalSteps-1])
            out.audit=[out.audit,struct('step',step,'x',x,'next',next,'drive',drive)];
        end
        assert(all(isfinite(next),'all')); x=next;
    end
    out.finalState=x; out.rateMax=max(out.rateMax,max(max(x,0),[],'all'));
    out.stateMax=max(out.stateMax,max(vecnorm(x))); assert(sample==m.nSamples);
    [out.theta,out.hand]=simulate_published_arm(m,out.torque);
    assert(all(isfinite(out.theta),'all') && all(isfinite(out.hand),'all'));
    speed=squeeze(hypot(out.hand(:,2,:),out.hand(:,4,:))); [peak,index]=max(speed,[],1);
    onset=nan(1,count); missing=false(1,count); multi=zeros(1,count);
    for j=1:count
        if peak(j)>0
            onset(j)=find(speed(:,j)>=.2*peak(j),1)-1;
            missing(j)=onset(j)+100>m.nSamples-1;
        else
            missing(j)=true;
        end
        z=find(speed(2:end-1,j)>speed(1:end-2,j) & speed(2:end-1,j)>=speed(3:end,j))+1;
        z=z(speed(z,j)>=.5*peak(j));
        if ~isempty(z)
            retained=z(1);
            for k=2:numel(z), if z(k)-retained(end)>=20, retained(end+1)=z(k); end, end %#ok<AGROW>
            multi(j)=numel(retained);
        end
    end
    out.speed=speed; out.peak=peak; out.peakMs=index-1; out.moMs=onset;
    out.nearZero=peak<=1e-8; out.boundaryPeak=index==1|index==size(speed,1);
    out.missingWindow=missing; out.multiPeakCount=multi;
    nt=8; trials=count/nt; assert(trials==round(trials));
    endpoint=squeeze(out.hand(end,[1 3],:)); centroids=zeros(2,8); scatter=zeros(1,8);
    for q=1:8
        ix=(q-1)*trials+(1:trials); centroids(:,q)=mean(endpoint(:,ix),2);
        scatter(q)=sqrt(mean(sum((endpoint(:,ix)-centroids(:,q)).^2,1)));
    end
    pairs=zeros(28,1); k=0;
    for q=1:7, for j=q+1:8, k=k+1; pairs(k)=norm(centroids(:,q)-centroids(:,j)); end, end
    out.endpointRmsByTarget=scatter; out.endpointCentroids=centroids;
    out.targetSeparationToScatter=median(pairs)/mean(scatter);
end
