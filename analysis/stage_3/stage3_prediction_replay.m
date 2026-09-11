function out = stage3_prediction_replay(m,d,c,flags,targets,s,noise,dt)
    % EM in physical time; this routine never writes accepted model evidence.
    if nargin<8, dt=m.dt; end
    assert(m.dt==.0002 && m.tau==.15 && m.samplingDt==.001);
    prepSteps=round(.5/dt); moveSteps=round(m.nInternalSteps*m.dt/dt);
    stride=round(m.samplingDt/dt); count=numel(targets);
    assert(size(noise.process,3)==prepSteps+moveSteps);
    x=repmat(m.spontaneous,1,count)+s*noise.initial;
    out.states=zeros(500+m.nSamples,m.n,count);
    out.torque=zeros(m.nSamples,2,count);
    out.nativeRateMax=0; out.nativeStateNormMax=0;
    out.prepRateMax=0; out.prepStateNormMax=0;
    out.seeds=noise.seeds; out.targets=targets; out.s=s; out.dt=dt;
    out.timeGOms=(-500:m.nSamples-1).';
    sample=0;
    for step=0:prepSteps+moveSteps-1
        rate=max(x,0);
        out.nativeRateMax=max(out.nativeRateMax,max(rate,[],'all'));
        out.nativeStateNormMax=max(out.nativeStateNormMax,max(vecnorm(x)));
        if step<=prepSteps
            out.prepRateMax=max(out.prepRateMax,max(rate,[],'all'));
            out.prepStateNormMax=max(out.prepStateNormMax,max(vecnorm(x)));
        end
        if mod(step,stride)==0
            sample=sample+1; out.states(sample,:,:)=permute(x,[3 1 2]);
            if step>=prepSteps
                out.torque(sample-500,:,:)=permute(m.C*rate,[3 1 2]);
            end
        end
        if step<prepSteps
            u0=-c.fB(:,targets)-c.kappa0*(x-d.xB(:,targets));
            b=flags(1)*c.b(:,targets);
            fb=-flags(2)*c.L*(x-m.xstar(:,targets));
            force=-x+m.W*rate+m.h+u0+b+fb;
        else
            if step==prepSteps, out.go=x; end
            force=-x+m.W*rate+m.h+published_movement_input((step-prepSteps)*dt,m);
        end
        x=x+(dt/m.tau)*force+s*sqrt(2*dt/m.tau)*noise.process(:,:,step+1);
        assert(all(isfinite(x),'all'),'Stage3Prediction:Nonfinite','Nonfinite stochastic state.');
    end
    out.finalState=x;
    out.nativeRateMax=max(out.nativeRateMax,max(max(x,0),[],'all'));
    out.nativeStateNormMax=max(out.nativeStateNormMax,max(vecnorm(x)));
    assert(sample==size(out.states,1));
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
