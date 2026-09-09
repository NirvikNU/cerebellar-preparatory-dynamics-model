function p = stage3_gain_time_prepare(m,d,nu,sustained)
    % Identical explicit Stage-3 Euler dynamics; retain 1-ms full states.
    assert(m.dt==.0002 && m.samplingDt==.001 && m.tau==.15);
    assert(ismember(nu,0:.5:6) && ismember(sustained,[0 1]));
    x=repmat(m.spontaneous,1,8); star=m.xstar;
    fB=-d.xB+m.W*max(d.xB,0)+m.h;
    fStar=-star+m.W*max(star,0)+m.h;
    b=fB-fStar+d.kappa*(star-d.xB);
    assert(max(abs(b-d.b),[],'all')<1e-10);
    p.states=zeros(501,200,8); p.rates=p.states; p.distance=zeros(501,1);
    for step=0:2500
        r=max(x,0); cortical=-fB-d.kappa*(x-d.xB);
        feedback=-nu*(x-star); total=cortical+sustained*b+feedback;
        if mod(step,5)==0
            row=step/5+1; p.states(row,:,:)=permute(x,[3 1 2]);
            p.rates(row,:,:)=permute(r,[3 1 2]);
            p.distance(row)=mean(vecnorm(x-star));
        end
        if step<2500, x=x+(m.dt/m.tau)*(-x+m.W*r+m.h+total); end
    end
    p.go=x; p.nu=nu; p.sustained=sustained; p.kappa=d.kappa;
    p.initialState=repmat(m.spontaneous,1,8);
    p.definition=d; p.dt=m.dt; p.savedDt=m.samplingDt;
    assert(all(isfinite(p.states),'all'));
end
