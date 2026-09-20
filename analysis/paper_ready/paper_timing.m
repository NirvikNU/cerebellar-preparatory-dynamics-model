function result = paper_timing(root)
    % Bounded timing-only gate, no geometry/noise/movement/prediction selection.
    addpath(fullfile(root,'analysis','stage_3'));
    cfg=stage3_bio_paths(root);
    dest=fullfile(root,'results','paper_ready','timing');
    assert(isfile(fullfile(root,'artifacts','manifests','paper_ready','INPUTS_BEFORE.csv')));
    assert(~isfolder(dest),'Refuse timing overwrite.'); mkdir(dest);
    s=load(fullfile(cfg.resultsRoot,'biological_revision','controllers.mat'),'controllers'); cs=s.controllers;
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); reg=s.registry;
    lambda=[.1 .2 .5 1 2 5 10 100]; readiness=nan(10,8,8); state90=readiness;
    result.task='PAPER-MODELLING-PREPREDICTION-01'; result.lambda=lambda;
    result.baselineMaxDifference=zeros(10,1); result.nativeIncrementError=zeros(10,8);
    result.readinessDefinition='First post-cue saved1ms sample with EQ/cue<=.1 and every later native sample<=.1 throughGO';
    allCurves=zeros(501,8,8,10); allState=zeros(size(allCurves));
    bounds=cell(80,1); row=0; started=tic;
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(root,'results','stage_2','current','cache',sprintf('network_%02d.mat',n)),'net'); net=s.net;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        frozen=stage3_bio_load(cfg,n,1); d=reg.primary{n};
        for j=1:8
            c=cs{n}; ctl=net.controller{j};
            assert(ctl.lambda==lambda(j) && isequal(ctl.Q,c.Q));
            c.P=ctl.P; c.L=c.P/lambda(j); c.lambda=lambda(j);
            A=m.W-eye(m.n); care=norm(A.'*c.P+c.P*A-c.P*c.P/lambda(j)+c.Q,'fro')/norm(c.Q,'fro');
            assert(care<1e-7);
            poles=zeros(m.n,8);
            for q=1:8, poles(:,q)=eig((-eye(m.n)+m.W.*(m.xstar(:,q)>0).'-c.kappa0*eye(m.n)-c.L)/m.tau); end
            assert(max(real(poles),[],'all')<0 && max(abs(1+m.dt*poles),[],'all')<1);
            p=stage3_biological_prepare(m,d,c,[1 1]);
            if j==1
                result.baselineMaxDifference(n)=max(abs(p.nativeStates-frozen.nativeStates),[],'all');
                assert(result.baselineMaxDifference(n)<=1e-10);
            end
            assert(p.nativeRateMax<=ref.rateLimit && p.nativeStateNormMax<=ref.stateLimit);
            % Independently reconstruct the reduced field at all saved states.
            x=reshape(permute(p.states,[2 3 1]),m.n,[]);
            star=repmat(m.xstar,1,501); fs=repmat(c.fStar,1,501);
            predicted=x+m.dt/m.tau*(-x+m.W*max(x,0)+m.h-fs-(c.kappa0*eye(m.n)+c.L)*(x-star));
            nx=reshape(p.nativeStates(:,:,2:5:end),m.n,[]);
            result.nativeIncrementError(n,j)=max(abs(predicted(:,1:end-8)-nx),[],'all');
            assert(result.nativeIncrementError(n,j)<1e-10);
            dx=reshape(p.nativeStates-repmat(m.xstar,1,1,2501),m.n,[]);
            eq=reshape(sum(dx.*(c.Q*dx),1),8,2501).'; eq=eq./eq(1,:);
            for q=1:8
                last=find(eq(:,q)>.1,1,'last');
                if isempty(last), first=1; else, first=ceil(last/5)+1; end
                if first<=501, readiness(n,j,q)=first-1; end
                assert(abs(eq(1,q)-1)<1e-12);
                sn=p.distanceStar(:,q)/p.distanceStar(1,q);
                lastS=find(sn>.1,1,'last');
                if isempty(lastS), state90(n,j,q)=0; elseif lastS<501, state90(n,j,q)=lastS; end
            end
            allCurves(:,:,j,n)=p.normalizedProspective;
            allState(:,:,j,n)=p.distanceStar./p.distanceStar(1,:);
            row=row+1; bounds{row}=table(n,lambda(j),care,p.nativeRateMax,ref.rateLimit, ...
                p.nativeStateNormMax,ref.stateLimit,max(real(poles),[],'all'),max(abs(1+m.dt*poles),[],'all'), ...
                'VariableNames',{'network','lambda','careResidual','rateMax','rateLimit','stateMax','stateLimit','worstPole','eulerRadius'});
        end
        fprintf('Timing network%02d complete %.1fs\n',n,toc(started));
    end
    result.readiness=readiness; result.state90=state90;
    result.networkMedian=median(readiness,3); result.ensembleMedian=median(result.networkMedian,1);
    result.eligible=all(isfinite(result.networkMedian),1) & result.ensembleMedian>=50 & result.ensembleMedian<=100;
    result.selectedLambda=NaN;
    if any(result.eligible)
        eligible=find(result.eligible); [~,k]=min(abs(result.ensembleMedian(eligible)-75));
        result.selectedLambda=lambda(eligible(k)); result.status='TIMING_PASS';
    else
        result.status='STOP_NO_ELIGIBLE_LAMBDA';
    end
    result.elapsedSeconds=toc(started);
    save(fullfile(dest,'timing.mat'),'result','allCurves','allState');
    writetable(vertcat(bounds{:}),fullfile(dest,'bounds.csv'));
    paper_json(fullfile(dest,'timing.json'),result);
    disp(result.ensembleMedian); disp(result.status); disp(result.selectedLambda);
end
