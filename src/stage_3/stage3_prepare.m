function p = stage3_prepare(m, xB, kappa, nu, mode, dt, intactNative)
    % Same uC for four policies; mode [sustained-on feedback-on].
    if nargin<6, dt=m.dt; end
    if nargin<7, intactNative=[]; end
    nBatch=size(xB,2); count=nBatch/8; assert(count==floor(count));
    star=repmat(m.xstar,1,count); x=repmat(m.spontaneous,1,nBatch);
    fB=-xB+m.W*max(xB,0)+m.h;
    fStar=-star+m.W*max(star,0)+m.h;
    b=fB-fStar+kappa*(star-xB);
    steps=round(.5/dt); every=round(.001/dt);
    p.rates=zeros(501,m.n,nBatch); p.distance=zeros(501,count);
    p.statesNormMax=zeros(1,count); p.rateMax=zeros(1,count);
    p.inputMax=zeros(count,5); sample=0;
    p.intactInputMax=zeros(count,5);
    storeNative=count==1 && all(mode==1);
    if storeNative, p.nativeStates=zeros(m.n,8,steps+1); end
    for step=0:steps
        r=max(x,0); cortical=-fB-kappa*(x-xB); feedback=-nu*(x-star);
        cb=b+feedback; total=cortical+mode(1)*b+mode(2)*feedback;
        p.rateMax=max(p.rateMax,max(reshape(r,m.n*8,count),[],1));
        p.statesNormMax=max(p.statesNormMax,max(reshape(vecnorm(x),8,count),[],1));
        pieces={cortical,b,feedback,cb,total};
        for j=1:5
            p.inputMax(:,j)=max(p.inputMax(:,j),max(reshape(vecnorm(pieces{j}),8,count),[],1).');
        end
        if ~isempty(intactNative)
            xi=repmat(intactNative(:,:,step+1),1,count);
            ci=-fB-kappa*(xi-xB); fi=-nu*(xi-star); cbi=b+fi;
            paired={ci,b,fi,cbi,ci+cbi};
            for j=1:5
                p.intactInputMax(:,j)=max(p.intactInputMax(:,j),max(reshape(vecnorm(paired{j}),8,count),[],1).');
            end
        end
        if storeNative, p.nativeStates(:,:,step+1)=x; end
        if mod(step,every)==0
            sample=sample+1;
            p.rates(sample,:,:)=permute(r,[3 1 2]);
            p.distance(sample,:)=mean(reshape(vecnorm(x-star),8,count),1);
        end
        if step<steps
            x=x+(dt/m.tau)*(-x+m.W*r+m.h+total);
        end
    end
    p.go=x; p.b=b; p.corticalConstant=-fB+kappa*xB;
    p.settle=max(reshape(vecnorm(x-xB)./max(1,vecnorm(xB-m.spontaneous)),8,count),[],1);
    p.mode=mode; p.kappa=kappa; p.nu=nu; p.dt=dt;
end
