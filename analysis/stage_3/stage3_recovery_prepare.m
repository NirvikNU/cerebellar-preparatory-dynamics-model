function p = stage3_recovery_prepare(m,xB,kappa,nu,mode,dt)
    % Frozen stage3_prepare arithmetic for one authorized case; retain states.
    assert(isequal(size(xB),[m.n 8]));
    star=m.xstar; x=repmat(m.spontaneous,1,8);
    fB=-xB+m.W*max(xB,0)+m.h; fStar=-star+m.W*max(star,0)+m.h;
    b=fB-fStar+kappa*(star-xB);
    steps=round(.5/dt); every=round(.001/dt);
    p.rates=zeros(501,m.n,8); p.distance=zeros(501,1);
    p.nativeStates=zeros(m.n,8,steps+1); p.statesNormMax=0;
    p.rateMax=0; p.inputMax=zeros(1,5); sample=0;
    for step=0:steps
        r=max(x,0); cortical=-fB-kappa*(x-xB); feedback=-nu*(x-star);
        cb=b+feedback; total=cortical+mode(1)*b+mode(2)*feedback;
        p.rateMax=max(p.rateMax,max(r,[],'all'));
        p.statesNormMax=max(p.statesNormMax,max(vecnorm(x)));
        pieces={cortical,b,feedback,cb,total};
        for j=1:5, p.inputMax(j)=max(p.inputMax(j),max(vecnorm(pieces{j}))); end
        p.nativeStates(:,:,step+1)=x;
        if mod(step,every)==0
            sample=sample+1; p.rates(sample,:,:)=permute(r,[3 1 2]);
            p.distance(sample)=mean(vecnorm(x-star));
        end
        if step<steps, x=x+(dt/m.tau)*(-x+m.W*r+m.h+total); end
    end
    p.go=x; p.b=b; p.corticalConstant=-fB+kappa*xB;
    p.settle=max(vecnorm(x-xB)./max(1,vecnorm(xB-m.spontaneous)));
    p.mode=mode; p.kappa=kappa; p.nu=nu; p.dt=dt;
end
