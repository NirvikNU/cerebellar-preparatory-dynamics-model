function result=landscape_search(m,base,scale,plane,n,c)
    stream=RandStream('mt19937ar','Seed',2026091500+n); d=randn(stream,m.n,3); d=d./vecnorm(d);
    movement=reshape(permute(base.states([101 301 501],:,:),[2 1 3]),m.n,[]);
    seeds=[m.spontaneous m.xstar movement m.spontaneous+.01*scale*d m.spontaneous-.01*scale*d];
    roots=repmat({zeros(m.n,0)},1,numel(c.alpha)); attempts=cell(4,numel(c.alpha)); passCounts=zeros(4,numel(c.alpha));
    for pass=1:4
        order=1:numel(c.alpha); if mod(pass,2)==0, order=fliplr(order); end
        previous=zeros(m.n,0);
        for i=order
            [roots{i},attempts{pass,i}]=landscape_roots(m,c.alpha(i),[seeds previous roots{i}],roots{i});
            previous=roots{i}; passCounts(pass,i)=size(roots{i},2);
        end
    end
    result=struct('alpha',c.alpha,'roots',{roots},'attempts',{attempts},'passCounts',passCounts,'seeds',seeds);
    result.poles=cell(size(roots)); result.residuals=cell(size(roots)); result.kinks=cell(size(roots));
    for i=1:numel(roots)
        [result.poles{i},result.residuals{i},result.kinks{i}]=root_properties(m,c.alpha(i),roots{i});
    end
    links=zeros(0,6);
    for i=1:numel(roots)-1
        for j=1:size(roots{i},2)
            [next,a]=landscape_root(m,c.alpha(i+1),roots{i}(:,j));
            if isempty(roots{i+1}), match=[]; err=Inf; else, [err,match]=min(vecnorm(roots{i+1}-next)); end
            found=a.converged && err<=1e-7*max(1,norm(next));
            backOK=false; sameMask=false;
            if found
                [back,z]=landscape_root(m,c.alpha(i),roots{i+1}(:,match));
                backOK=z.converged && norm(back-roots{i}(:,j))<=1e-7*max(1,norm(back));
                sameMask=isequal(roots{i}(:,j)>0,roots{i+1}(:,match)>0);
            else
                match=0;
            end
            links(end+1,:)=[i j match found backOK sameMask]; %#ok<AGROW>
        end
    end
    result.links=links; time=(0:m.nSamples-1)'*m.samplingDt;
    result.time=time; result.drive=published_movement_input(time,m);
    result.exactRoots=cell(m.nSamples,1); result.exactPoles=cell(m.nSamples,1);
    result.distance=nan(m.nSamples,8); result.speed=zeros(m.nSamples,8);
    for t=1:m.nSamples
        a=result.drive(t); lo=max(1,min(numel(c.alpha)-1,floor(a/.1)+1));
        [r,~]=landscape_roots(m,a,[roots{lo} roots{lo+1}]);
        [p,~,kinks]=root_properties(m,a,r); stable=p< -1e-7 & ~kinks;
        result.exactRoots{t}=r; result.exactPoles{t}=p;
        x=squeeze(base.states(t,:,:));
        for q=1:8
            if any(stable), result.distance(t,q)=min(vecnorm(r(:,stable)-x(:,q))); end
        end
        result.speed(t,:)=vecnorm(-x+m.W*max(x,0)+m.h+a)/m.tau;
    end
    result.normalizedDistance=result.distance/scale;
    result.near=result.normalizedDistance<=.01;
    if n==1
        peakTime=log(m.movTauDecay/m.movTauRise)*m.movTauDecay*m.movTauRise/(m.movTauDecay-m.movTauRise);
        snapTimes=[0 peakTime .4]; snapAlpha=published_movement_input(snapTimes,m);
        projected=(squeeze(base.states(:,:,3)).'-m.spontaneous).'*plane;
        result.plane=plane; result.snapshotTimes=snapTimes; result.snapshotAlpha=snapAlpha;
        result.projectedTrajectory=projected; result.launchProjection=(m.xstar(:,3)-m.spontaneous).'*plane;
        result.snapshotRoots=cell(1,3); allXY=[0 0;result.launchProjection;projected];
        for s=1:3
            lo=max(1,min(50,floor(snapAlpha(s)/.1)+1));
            [r,~]=landscape_roots(m,snapAlpha(s),[roots{lo} roots{lo+1}]);
            result.snapshotRoots{s}=r; allXY=[allXY;(r-m.spontaneous).'*plane]; %#ok<AGROW>
        end
        low=min(allXY); high=max(allXY); span=high-low; assert(all(span>1e-10));
        [xx,yy]=meshgrid(linspace(low(1)-.15*span(1),high(1)+.15*span(1),31), ...
            linspace(low(2)-.15*span(2),high(2)+.15*span(2),31));
        result.xx=xx; result.yy=yy; result.flow=zeros(31,31,2,3);
        points=m.spontaneous+plane*[xx(:).';yy(:).'];
        for s=1:3
            f=(-points+m.W*max(points,0)+m.h+snapAlpha(s))/m.tau;
            result.flow(:,:,:,s)=reshape((plane.'*f).',31,31,2);
        end
    end
end

function [poles,residuals,kinks]=root_properties(m,a,roots)
    poles=zeros(1,size(roots,2)); residuals=poles; kinks=false(size(poles));
    for j=1:size(roots,2)
        x=roots(:,j); residuals(j)=norm(-x+m.W*max(x,0)+m.h+a,Inf);
        assert(residuals(j)<=1e-10);
        poles(j)=max(real(eig((-eye(m.n)+m.W.*(x>0).')/m.tau)));
        kinks(j)=any(abs(x)<=1e-8);
    end
end
