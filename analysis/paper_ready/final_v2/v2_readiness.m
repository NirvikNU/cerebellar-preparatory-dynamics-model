function result=v2_readiness(root)
    cfg=v2_paths(root); path=fullfile(cfg.dest,'readiness.mat'); assert(~isfile(path));
    result.lambda=[.1 .2 .5 1 2 5 10 100]; result.selectedLambda=10; result.eta=0;
    result.readiness=nan(10,8,8); result.gain=zeros(10,8); result.nativeError=0;
    curves=zeros(2501,8,8,10); rows=cell(80,1);
    for n=1:10
        [m,c,d]=v2_definition(cfg,n);
        s=load(fullfile(root,'results','stage_2','current','cache',sprintf('network_%02d.mat',n)),'net');
        noise=struct('targets',1:8,'initial',zeros(200,8),'process',zeros(200,8,2500),'seeds',[]);
        for j=1:8
            ctl=s.net.controller{j}; assert(ctl.lambda==result.lambda(j) && isequal(ctl.Q,c.Q));
            c.P=ctl.P; c.L=c.P/result.lambda(j); c.lambda=result.lambda(j); c.kappa0=0;
            p=paper_prepare(m,{d},c,[1 1],0,0,noise,m.dt,false,true);
            dx=reshape(p.nativeStates-repmat(m.xstar,1,1,2501),200,[]);
            eq=reshape(sum(dx.*(c.Q*dx),1),8,2501).'; eq=eq./eq(1,:); curves(:,:,j,n)=eq;
            for q=1:8
                last=find(eq(:,q)>.1,1,'last');
                if isempty(last), first=1; else, first=ceil(last/5)+1; end
                if first<=501, result.readiness(n,j,q)=first-1; end
            end
            for a=p.audit
                star=m.xstar; fs=-star+m.W*max(star,0)+m.h;
                next=a.x+m.dt/m.tau*(-a.x+m.W*max(a.x,0)+m.h-fs-c.L*(a.x-star));
                result.nativeError=max(result.nativeError,max(abs(next-a.next),[],'all'));
            end
            result.gain(n,j)=norm(c.L,'fro');
            rows{(n-1)*8+j}=table(n,c.lambda,result.gain(n,j),p.rateMax,p.stateMax,p.componentMax(5), ...
                'VariableNames',{'network','lambda','gainFrobenius','rateMax','stateMax','totalInputMax'});
        end
    end
    result.networkMedian=median(result.readiness,3); result.ensembleMedian=median(result.networkMedian,1);
    result.definition='First saved 1-ms sample with Q error/cue<=0.1 and every later native sample<=0.1 throughGO; never reselect lambda';
    assert(result.nativeError<1e-10); result.status='PASS'; result.noLambdaReselection=true;
    save(path,'result','curves','-v7.3'); writetable(vertcat(rows{:}),fullfile(cfg.dest,'readiness_bounds.csv'));
    paper_json(fullfile(cfg.dest,'readiness.json'),result);
end
