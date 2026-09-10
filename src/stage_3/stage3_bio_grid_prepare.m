function p = stage3_bio_grid_prepare(m,xB,c,intactNative)
    % Batched finite block trajectories; frozen kappa0 and prospective gain.
    count=size(xB,2)/8; assert(count==floor(count));
    star=repmat(m.xstar,1,count); x=repmat(m.spontaneous,1,8*count);
    fB=-xB+m.W*max(xB,0)+m.h; fStar=-star+m.W*max(star,0)+m.h;
    b=fB-fStar+c.kappa0*(star-xB);
    p.lateRates=zeros(11,200,8*count); p.distance=zeros(501,count);
    p.rateMax=zeros(1,count); p.stateMax=zeros(1,count); p.inputMax=zeros(count,5);
    p.nativeRateMax=zeros(2501,count); p.nativeStateMax=zeros(2501,count);
    p.nativeInputMax=zeros(2501,count,5);
    for step=0:2500
        rates=max(x,0); ci=-fB-c.kappa0*(x-xB); fb=-c.L*(x-star);
        xi=repmat(intactNative(:,:,step+1),1,count);
        ici=-fB-c.kappa0*(xi-xB); ifb=-c.L*(xi-star);
        pieces={ci,b,fb,b+fb,ci+b+fb}; paired={ici,b,ifb,b+ifb,ici+b+ifb};
        rate=max(reshape(rates,200*8,count),[],1);
        state=max(reshape(vecnorm(x),8,count),[],1);
        p.nativeRateMax(step+1,:)=rate; p.nativeStateMax(step+1,:)=state;
        p.rateMax=max(p.rateMax,rate); p.stateMax=max(p.stateMax,state);
        for j=1:5
            a=max(reshape(vecnorm(pieces{j}),8,count),[],1);
            ib=max(reshape(vecnorm(paired{j}),8,count),[],1);
            imax=max(a,ib); p.nativeInputMax(step+1,:,j)=imax;
            p.inputMax(:,j)=max(p.inputMax(:,j),imax.');
        end
        if mod(step,5)==0
            p.distance(1+step/5,:)=mean(reshape(vecnorm(x-star),8,count),1);
        end
        if step>=2000 && mod(step,50)==0
            p.lateRates(1+(step-2000)/50,:,:)=permute(rates,[3 1 2]);
        end
        if step<2500, x=x+m.dt/m.tau*(-x+m.W*rates+m.h+ci); end
        assert(all(isfinite(x),'all'));
    end
    p.go=x;
    p.relativeBlock=max(reshape(vecnorm(x-xB)./max(1,vecnorm(xB-m.spontaneous)),8,count),[],1);
end
