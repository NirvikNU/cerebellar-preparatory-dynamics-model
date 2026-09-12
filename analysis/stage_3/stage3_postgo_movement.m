function out = stage3_postgo_movement(m,go,postNoise,s)
    % Movement-only intervention; accepted drive, integration and arm unchanged.
    x=go; count=size(go,2); stride=round(m.samplingDt/m.dt);
    out.go=go; out.states=zeros(m.nSamples,m.n,count);
    out.torque=zeros(m.nSamples,2,count); sample=0;
    out.nativeRateMax=0; out.nativeStateNormMax=0;
    for step=0:m.nInternalSteps-1
        rate=max(x,0);
        out.nativeRateMax=max(out.nativeRateMax,max(rate,[],'all'));
        out.nativeStateNormMax=max(out.nativeStateNormMax,max(vecnorm(x)));
        if mod(step,stride)==0
            sample=sample+1; out.states(sample,:,:)=permute(x,[3 1 2]);
            out.torque(sample,:,:)=permute(m.C*rate,[3 1 2]);
        end
        force=-x+m.W*rate+m.h+published_movement_input(step*m.dt,m);
        x=x+(m.dt/m.tau)*force;
        if s~=0, x=x+s*sqrt(2*m.dt/m.tau)*postNoise(:,:,step+1); end
        assert(all(isfinite(x),'all'));
    end
    out.finalState=x;
    out.nativeRateMax=max(out.nativeRateMax,max(max(x,0),[],'all'));
    out.nativeStateNormMax=max(out.nativeStateNormMax,max(vecnorm(x)));
    assert(sample==m.nSamples);
    [out.theta,out.hand]=simulate_published_arm(m,out.torque);
    out.moMs=zeros(count,1); out.peakMs=zeros(count,1);
    out.peakSpeed=zeros(count,1); out.peakPosition=zeros(count,2);
    out.windowsOK=false(count,1);
    for j=1:count
        speed=hypot(out.hand(:,2,j),out.hand(:,4,j));
        [out.peakSpeed(j),peak]=max(speed);
        assert(out.peakSpeed(j)>0 && all(isfinite(speed)));
        mo=find(speed>=.2*out.peakSpeed(j),1);
        out.moMs(j)=mo-1; out.peakMs(j)=peak-1;
        out.peakPosition(j,:)=out.hand(peak,[1 3],j);
        out.windowsOK(j)=mo-1+100<=m.nSamples-1 && peak-1-150>=-500 ...
            && peak-1-50<=m.nSamples-1;
    end
end
