function out=landscape_trace(m,initial,reference,targetIds)
    count=size(initial,2); x=initial; stride=round(m.samplingDt/m.dt);
    out.initial=initial; out.states=zeros(m.nSamples,m.n,count);
    out.torque=zeros(m.nSamples,2,count);
    paired=nargin>2;
    if paired
        amplitude=vecnorm(initial-reference.initial(:,targetIds));
        assert(all(amplitude>0));
        out.maxAmplification=ones(1,count); out.maxAmplificationTime=zeros(1,count);
        out.nativeNorm=zeros(m.nInternalSteps+1,count); out.nativeNorm(1,:)=amplitude;
    else
        out.native=zeros(m.n,m.nInternalSteps+1,count);
    end
    sample=0;
    for step=0:m.nInternalSteps-1
        if ~paired, out.native(:,step+1,:)=reshape(x,m.n,1,count); end
        if mod(step,stride)==0
            sample=sample+1; out.states(sample,:,:)=permute(x,[3 1 2]);
            out.torque(sample,:,:)=permute(m.C*max(x,0),[3 1 2]);
        end
        x=x+(m.dt/m.tau)*(-x+m.W*max(x,0)+m.h+published_movement_input(step*m.dt,m));
        assert(all(isfinite(x),'all'));
        if paired
            out.nativeNorm(step+2,:)=vecnorm(x-reshape(reference.native(:,step+2,targetIds),m.n,count));
            gain=out.nativeNorm(step+2,:)./amplitude;
            larger=gain>out.maxAmplification;
            out.maxAmplification(larger)=gain(larger); out.maxAmplificationTime(larger)=(step+1)*m.dt;
        end
    end
    if ~paired, out.native(:,end,:)=reshape(x,m.n,1,count); end
    out.finalState=x;
    assert(sample==m.nSamples);
    [out.theta,out.hand]=simulate_published_arm(m,out.torque);
    assert(all(isfinite(out.hand),'all'));
end
