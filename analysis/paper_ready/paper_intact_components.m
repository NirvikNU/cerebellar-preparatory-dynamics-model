function maxima = paper_intact_components(m,intact,definitions,c)
    % Same intact state trajectory for every geometry; recompute its decomposition.
    G=numel(definitions); maxima=zeros(G,5);
    for q=1:8
        x=reshape(intact.nativeStates(:,(q-1)*30+(1:30),:),200,[]);
        fb=-c.L*(x-m.xstar(:,q)); base=-c.kappa0*x;
        offsets=zeros(200,G); bs=offsets;
        for g=1:G
            xb=definitions{g}.xB(:,q); fB=-xb+m.W*max(xb,0)+m.h;
            offsets(:,g)=c.kappa0*xb-fB;
            bs(:,g)=fB-c.fStar(:,q)+c.kappa0*(m.xstar(:,q)-xb);
        end
        u0norm=sqrt(max(0,sum(base.^2,1)+2*offsets.'*base+sum(offsets.^2,1).'));
        cbnorm=sqrt(max(0,sum(fb.^2,1)+2*bs.'*fb+sum(bs.^2,1).'));
        maxima(:,1)=max(maxima(:,1),max(u0norm,[],2));
        maxima(:,2)=max(maxima(:,2),vecnorm(bs).');
        maxima(:,3)=max(maxima(:,3),max(vecnorm(fb)));
        maxima(:,4)=max(maxima(:,4),max(cbnorm,[],2));
        maxima(:,5)=intact.componentMax(5);
        % Direct column arithmetic audits squared-norm expansion independently.
        ix=[1 floor(size(x,2)/2) size(x,2)];
        for g=1:G
            assert(max(abs(vecnorm(base(:,ix)+offsets(:,g))-u0norm(g,ix)))<1e-9);
            assert(max(abs(vecnorm(fb(:,ix)+bs(:,g))-cbnorm(g,ix)))<1e-9);
        end
    end
end
