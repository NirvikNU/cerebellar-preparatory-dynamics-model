function report = stage3_biological_audit(root)
    % Independent saved-evidence audit: no trajectory integration or selection.
    if nargin<1, root=fileparts(fileparts(fileparts(mfilename('fullpath')))); end
    addpath(fullfile(root,'config'));
    cfg=stage_3_config(root); out=fullfile(cfg.resultsRoot,'biological_revision');
    reportPath=fullfile(out,'independent_audit.json'); assert(~isfile(reportPath));
    s=load(fullfile(out,'primary_gate.mat'),'audit'); gate=s.audit;
    s=load(fullfile(out,'controllers.mat'),'controllers'); controllers=s.controllers;
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); registry=s.registry;
    report=struct('status','PASS','checks',0,'maxAbsoluteError',0, ...
        'scientificStatus',gate.status,'newMovementRollouts',0,'newNullDraws',0);
    geometryRows=cell(10,1);
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        c=controllers{n}; d=registry.primary{n};
        eq=[m.xstar d.xB]; worst=-Inf;
        for q=1:16
            J=(-eye(200)+m.W*diag(double(eq(:,q)>0)))/m.tau;
            worst=max(worst,max(real(eig(J))));
        end
        compare(max(0,m.tau*(worst+1/m.tau)),c.kappa0,1e-10);
        compare(c.Q,200*((m.Qnative+m.Qnative.')/2)/trace(m.Qnative),1e-10);
        compare(c.P/.1,c.L,1e-12);
        % Direct target covariance checks; unchanged selected geometry only.
        centered=max(d.xB,0)-mean(max(d.xB,0),2);
        normed=centered./ref.scale;
        rawStar=max(m.xstar,0)-mean(max(m.xstar,0),2);
        rawRatio=sum(centered.^2,'all')/sum(rawStar.^2,'all');
        normalizedRatio=sum(normed.^2,'all')/sum((rawStar./ref.scale).^2,'all');
        compare(normalizedRatio,d.alpha^2+d.betaNormalized^2,1e-10);
        assert(rawRatio>=.25 && rawRatio<=2 && normalizedRatio>=.25 && normalizedRatio<=2);
        assert(all(d.xB>=0,'all'));
        geometryRows{n}=table(n,rawRatio,normalizedRatio,min(d.xB,[],'all'), ...
            'VariableNames',{'network','rawVarianceRatio','normalizedVarianceRatio','minimumBlockRate'});
    end
    writetable(vertcat(geometryRows{:}),fullfile(out,'frozen_geometry_audit.csv'));
    rows=cell(gate.completedNetworks*16,1); row=0;
    for n=1:gate.completedNetworks
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,'biological_revision',sprintf('primary_%02d.mat',n)),'primary'); a=s.primary;
        d=a.definition; c=a.controller;
        assert(isequal(d,registry.primary{n}));
        compare(c.L,controllers{n}.L,0); compare(c.Q,controllers{n}.Q,0);
        for policy=1:2
            if policy==1, p=a.intact; equilibrium=m.xstar; gain=c.kappa0*eye(200)+c.L;
            else, p=a.block; equilibrium=d.xB; gain=c.kappa0*eye(200); end
            X=reshape(p.nativeStates(:,:,1:end-1),200,[]);
            next=reshape(p.nativeStates(:,:,2:end),200,[]);
            e=repmat(equilibrium,1,2500);
            fe=-e+m.W*max(e,0)+m.h;
            reduced=-X+m.W*max(X,0)+m.h-fe-gain*(X-e);
            compare(next-X,m.dt/m.tau*reduced,1e-11);
            compare(p.states,permute(p.nativeStates(:,:,1:5:end),[3 1 2]),0);
            compare(p.go,p.nativeStates(:,:,end),0);
            compare(p.nativeStates(:,:,1),repmat(m.spontaneous,1,8),0);
            allX=reshape(p.nativeStates,200,[]); b=repmat(c.b,1,2501);
            star=repmat(m.xstar,1,2501); block=repmat(d.xB,1,2501);
            fBlock=-block+m.W*max(block,0)+m.h;
            u0=-fBlock-c.kappa0*(allX-block); fb=-c.L*(allX-star);
            if policy==2, b(:)=0; fb(:)=0; end
            parts={u0,b,fb,b+fb,u0+b+fb};
            extrema=zeros(1,5);
            for j=1:5
                norms=sqrt(sum(parts{j}.^2,1)); extrema(j)=max(norms);
                norms=reshape(norms,8,2501);
                compare(p.componentNorms(:,:,j),norms(:,1:5:end).',1e-11);
            end
            compare(p.nativeComponentMax,extrema,1e-11);
            compare(p.nativeRateMax,max(max(allX,0),[],'all'),0);
            compare(p.nativeStateNormMax,max(sqrt(sum(allX.^2,1))),1e-11);
            for q=1:8
                x=squeeze(p.states(:,:,q)).'; dx=x-m.xstar(:,q);
                err=sqrt(sum(dx.^2,1)).'; eb=sqrt(sum((x-d.xB(:,q)).^2,1)).';
                eqValue=zeros(501,1);
                for t=1:501, eqValue(t)=dx(:,t).'*c.Q*dx(:,t); end
                compare(err,p.distanceStar(:,q),1e-11);
                compare(eb,p.distanceBlock(:,q),1e-11);
                compare(eqValue,p.prospectiveError(:,q),1e-10);
                compare(eqValue/eqValue(1),p.normalizedProspective(:,q),1e-10);
                relative=eb(end)/max(1,norm(d.xB(:,q)-m.spontaneous));
                compare(relative,p.relativeSettle(q),1e-12);
                cross=nan(1,4); curves=[eqValue/eqValue(1),err/err(1)];
                for metric=1:2
                    thresholds=[.5 .1];
                    for lev=1:2
                        hit=find(curves(:,metric)<=thresholds(lev),1);
                        if ~isempty(hit), cross((metric-1)*2+lev)=hit-1; end
                    end
                end
                assert(isequal(isnan(cross),isnan(p.crossingMs(q,:))));
                compare(cross(isfinite(cross)),p.crossingMs(q,isfinite(cross)),0);
                row=row+1;
                rows{row}=table(n,policy,q,relative,err(end),eb(end),eqValue(end), ...
                    eqValue(end)/eqValue(1),cross(1),cross(2),cross(3),cross(4), ...
                    p.readinessEQ(1,q),p.readinessEQ(2,q),p.readinessEQ(3,q), ...
                    p.readinessState(1,q),p.readinessState(2,q),p.readinessState(3,q), ...
                    'VariableNames',{'network','policy','target','blockRelativeSettle','goDistanceStar', ...
                    'goDistanceBlock','goEQ','goNormalizedEQ','eq50ms','eq90ms','state50ms','state90ms', ...
                    'normalizedEQat50','normalizedEQat100','normalizedEQat200', ...
                    'relativeStateAt50','relativeStateAt100','relativeStateAt200'});
            end
        end
        compare(max(1,a.intact.nativeComponentMax(5)),a.inputReference,0);
        compare(5*a.inputReference,a.inputLimit,0);
        assert(max(a.block.relativeSettle)>cfg.settleRelativeTolerance);
        s=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',n)),'preparations');
        if isfield(s,'preparations')
            report.predecessorBlockSettle=s.preparations{1,5}.settle;
        end
    end
    writetable(vertcat(rows{1:row}),fullfile(out,'target_readiness.csv'));
    report.completedNetworks=gate.completedNetworks;
    report.notRun='Remaining networks, partial removals, population/null, movement, map, figures: scientific stop';
    fid=fopen(reportPath,'w'); assert(fid>=0); closer=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',jsonencode(report,PrettyPrint=true));

    function compare(actual,expected,tolerance)
        assert(isequal(size(actual),size(expected)));
        delta=max(abs(actual-expected),[],'all');
        if isempty(delta), delta=0; end
        assert(isfinite(delta) && delta<=tolerance,'Stage3Bio:Audit','Saved-evidence mismatch %.12g',delta);
        report.checks=report.checks+1; report.maxAbsoluteError=max(report.maxAbsoluteError,delta);
    end
end
