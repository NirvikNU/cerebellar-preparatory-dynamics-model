function raw=pf_visualization_replay(m,c,d,cfg,p,q,ids)
    % New visualization trials only; same frozen update order as paper_prepare.
    count=numel(ids); seeds=cfg.seedBase+cfg.seedConditionStride*p+cfg.seedTargetStride*q+ids;
    z=zeros(200,count); xi=zeros(200,count,2500);
    for j=1:count
        stream=RandStream('mt19937ar','Seed',seeds(j)); z(:,j)=randn(stream,200,1);
        xi(:,j,:)=reshape(randn(stream,200,2500),200,1,2500);
    end
    star=repmat(m.xstar(:,q),1,count); xb=repmat(d.xB(:,q),1,count);
    fB=-xb+m.W*max(xb,0)+m.h; fS=-star+m.W*max(star,0)+m.h; b=fB-fS;
    x=m.spontaneous+.1*z; initial=x; prepAudit=[]; flags=cfg.flags(p,:);
    for step=0:2499
        rate=max(x,0); u0=-fB; fb=-c.L*(x-star); total=u0+flags(1)*b+flags(2)*fb;
        increment=.1*sqrt(2*m.dt/m.tau)*xi(:,:,step+1);
        next=x+m.dt/m.tau*(-x+m.W*rate+m.h+total)+increment;
        if ismember(step,[0 1250 2499])
            prepAudit=[prepAudit struct('step',step,'x',x,'next',next,'increment',increment)]; %#ok<AGROW> Three fixed probes.
        end
        assert(all(isfinite(next),'all'),'Nonfinite preparation: stop without retuning.'); x=next;
    end
    clear xi
    go=x; torque=zeros(m.nSamples,2,count); sample=0; stride=round(m.samplingDt/m.dt); moveAudit=[];
    for step=0:m.nInternalSteps-1
        rate=max(x,0);
        if mod(step,stride)==0, sample=sample+1; torque(sample,:,:)=permute(m.C*rate,[3 1 2]); end
        drive=published_movement_input(step*m.dt,m); next=x+m.dt/m.tau*(-x+m.W*rate+m.h+drive);
        if ismember(step,[0 floor(m.nInternalSteps/2) m.nInternalSteps-1])
            moveAudit=[moveAudit struct('step',step,'x',x,'next',next,'drive',drive)]; %#ok<AGROW> Three fixed probes.
        end
        assert(all(isfinite(next),'all'),'Nonfinite movement: stop without retuning.'); x=next;
    end
    assert(sample==m.nSamples);
    [theta,hand]=simulate_published_arm(m,torque);
    assert(size(hand,1)==600 && all(isfinite(hand),'all') && all(isfinite(theta),'all'));
    speed=reshape(hypot(hand(:,2,:),hand(:,4,:)),600,count);
    moMs=nan(1,count); entryMs=nan(1,count); success=false(1,count); pathRMS=nan(1,count);
    for j=1:count
        peak=max(speed(:,j)); if peak>0, moMs(j)=find(speed(:,j)>=.2*peak,1)-1; end
        xy=hand(:,[1 3],j)-hand(1,[1 3],j); target=cfg.targetXY(q,:);
        stop=find(sum((xy-target).^2,2)<=cfg.targetRadius^2,1);
        if ~isempty(stop)
            success(j)=true; entryMs(j)=stop-1;
            % Preserve raw evidence before the independent audit stops on an invalid interval.
            if isfinite(moMs(j)) && moMs(j)<entryMs(j)
                path=xy(moMs(j)+1:stop,:); a=max(0,min(1,path*target.'/sum(target.^2)));
                pathRMS(j)=sqrt(mean(sum((path-a.*target).^2,2)));
            end
        end
    end
    raw=struct('visualizationOnly',true,'network',8,'conditionIndex',p,'policy',cfg.policy(p), ...
        'target',q,'attemptIDs',ids,'seeds',seeds,'initial',initial,'go',go,'finalState',x, ...
        'prepAudit',prepAudit,'moveAudit',moveAudit,'torque',torque,'theta',theta,'hand',hand, ...
        'speed',speed,'moMs',moMs,'entryMs',entryMs,'success',success,'pathRMS',pathRMS, ...
        'noise',[.1 .1],'eta',0,'lambda',10,'alpha',.5,'betaNormalized',1.25,'dt',m.dt,'savedDt',m.samplingDt);
end
