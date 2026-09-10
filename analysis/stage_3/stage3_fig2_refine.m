function result = stage3_fig2_refine(cfg,action)
    % Only baseline verification and saved-preparation geometry extension.
    target=fullfile(cfg.resultsRoot,'gain_time','refined');
    cache=fullfile(cfg.cacheRoot,'gain_time','refined');
    if strcmp(action,'baseline')
        assert(~isfolder(cache),'Refine:Overwrite','Baseline evidence already exists.');
        mkdir(cache); evidence=cell(10,1);
        for n=1:10
            s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
            assert(m.dt==.0002 && m.samplingDt==.001 && m.tau==.15);
            x=m.spontaneous; identity=m.h-(x-m.W*max(x,0));
            assert(max(abs(identity))<=1e-9+1e-10*max(abs(m.h)));
            native=zeros(200,1001); native(:,1)=x;
            for step=1:1000
                x=x+(m.dt/m.tau)*(-x+m.W*max(x,0)+m.h);
                native(:,step+1)=x;
            end
            err=max(abs(x-m.spontaneous));
            assert(err<=1e-9+1e-10*max(abs(m.spontaneous)), ...
                'Refine:Baseline','Frozen baseline does not reproduce cue state.');
            baseline=struct('network',n,'nativeStates',native,'states',native(:,1:5:end).', ...
                'timeGO',-700:-500,'dt',m.dt,'savedDt',m.samplingDt, ...
                'controllerInput',0,'cueError',err,'identityError',max(abs(identity)));
            s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref');
            initial=permute(s.ref.prep.nativeStates(:,:,1),[3 1 2]);
            assert(max(abs(initial-reshape(m.spontaneous,1,200,1)),[],'all')<1e-9);
            baseline.referenceInitialError=max(abs(initial-reshape(x,1,200,1)),[],'all');
            save(fullfile(cache,sprintf('baseline_n%02d.mat',n)),'baseline','-v7');
            evidence{n}=rmfield(baseline,{'nativeStates','states'});
        end
        result=struct('status','PASS','networks',{evidence});
        stage3_write_json(fullfile(cfg.manifestRoot,'FIG2_REFINE_BASELINE.json'),result);
        disp(result); return;
    end
    assert(strcmp(action,'compute'));
    assert(~isfolder(target),'Refine:Overwrite','Expanded analysis already exists.');
    assert(isfile(fullfile(cfg.manifestRoot,'FIG2_REFINE_BASELINE.json')));
    s=load(fullfile(cfg.resultsRoot,'gain_time','gain_time.mat'),'result'); old=s.result;
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); original=s.result;
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); registry=s.registry;
    result=struct('task','STAGE3-DIAGNOSTIC-FIG2-REFINE-01','status','RUNNING', ...
        'nu',old.nu,'sustained',old.sustained,'endpointGO',-600:10:0, ...
        'dimensionOrder','network,gain,policy,endpoint','absoluteTolerance',1e-9, ...
        'relativeTolerance',1e-10,'reusedPreparations',0,'newPreparations',0, ...
        'baselineSegments',10,'newNullK',{{}});
    names={'stateError','pr','observed','expected','deficit','K','referenceK','policyK','referenceCapture','policyCapture'};
    for j=1:numel(names), result.(names{j})=nan(10,13,2,61); end
    checks={}; started=tic;
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        s=load(fullfile(cache,sprintf('baseline_n%02d.mat',n)),'baseline'); baseline=s.baseline;
        s=load(fullfile(cfg.cacheRoot,'gain_time',sprintf('null_n%02d.mat',n)),'nullEvidence'); nulls=s.nullEvidence;
        compare('frozen null covariance',nulls.fullCov,ref.fullCov);
        assert(nulls.seed==cfg.nullSeedBase+n && nulls.draws==cfg.nullDraws);
        d=registry.primary{n}; compare('frozen SD',d.scale,ref.scale);
        preStates=repmat(baseline.states(1:200,:),1,1,8);
        preRates=max(preStates,0); refRates=cat(1,preRates,ref.prep.rates);
        igs=cell(61,1);
        for t=12:61
            ix=701+result.endpointGO(t)+(-100:10:0);
            igs{t}=stage3_geometry(refRates(ix,:,:),ref.scale);
        end
        for family=1:2
            for gidx=1:13
                nu=result.nu(gidx); b=result.sustained(family);
                id=sprintf('n%02d_b%d_nu%02d',n,b,gidx);
                if b==1 && nu==3
                    p=ref.prep; states=permute(p.nativeStates(:,:,1:5:end),[3 1 2]);
                elseif (b==1 && nu==0) || (b==0 && nu==3)
                    policy=3; if b==0, policy=2; end
                    s=load(fullfile(cfg.cacheRoot,'evidence_recovery',sprintf('policy_n%02d_p%d.mat',n,policy)),'raw');
                    p=s.raw.prep; states=permute(p.nativeStates(:,:,1:5:end),[3 1 2]);
                    compare([id ' xB'],s.raw.identity.definition.xB,d.xB);
                else
                    s=load(fullfile(cfg.cacheRoot,'gain_time',[id '.mat']),'p'); p=s.p; states=p.states;
                    compare([id ' xB'],p.definition.xB,d.xB);
                end
                compare([id ' frozen cue'],squeeze(states(1,:,:)),repmat(m.spontaneous,1,8));
                compare([id ' baseline/cue'],squeeze(states(1,:,:)),repmat(baseline.states(end,:).',1,8));
                compare([id ' rates'],max(states,0),p.rates);
                fullStates=cat(1,preStates,states); rates=cat(1,preRates,p.rates);
                distance=mean(sqrt(sum((fullStates-reshape(m.xstar,1,200,8)).^2,2)),3);
                compare([id ' prior distance'],distance(201:end),p.distance(:));
                for t=1:61
                    row=701+result.endpointGO(t); ix=row+(-100:10:0);
                    result.stateError(n,gidx,family,t)=distance(row);
                    if t<=11
                        % All targets identical: true covariance is zero, PR/AI undefined.
                        window=rates(ix,:,:);
                        assert(all(window==window(:,:,1),'all'));
                        continue;
                    end
                    ig=igs{t}; g=stage3_geometry(rates(ix,:,:),ref.scale);
                    independent=stage3_recovery_geometry(rates(ix,:,:),ref.scale);
                    compare([id ' covariance'],g.covariance,independent.covariance);
                    compare([id ' independent PR'],g.pr,independent.pr);
                    compare([id ' minimum K'],g.k,independent.k);
                    K=max(ig.k,g.k); den=sum(ig.eigenvalues(1:K));
                    obs=trace(g.basis(:,1:K).'*ig.covariance*g.basis(:,1:K))/den;
                    direct=sum((ig.matrix*g.basis(:,1:K)).^2,'all')/((size(ig.matrix,1)-1)*den);
                    compare([id ' projection'],obs,direct);
                    if isempty(nulls.projectors{K})
                        [nulls.projectors{K},nulls.qrProjectors{K}]=projector(ref.fullCov,K,cfg.nullDraws,cfg.nullSeedBase+n);
                        compare([id ' null QR'],nulls.projectors{K},nulls.qrProjectors{K});
                        result.newNullK{end+1}=struct('network',n,'K',K);
                    end
                    expected=trace(ig.covariance*nulls.projectors{K})/den;
                    compare([id ' expected QR'],expected,trace(ig.covariance*nulls.qrProjectors{K})/den);
                    vals=[distance(row),g.pr,obs,expected,expected-obs,K,ig.k,g.k, ...
                        sum(ig.eigenvalues(1:K))/sum(ig.eigenvalues),sum(g.eigenvalues(1:K))/sum(g.eigenvalues)];
                    for j=1:numel(names)
                        key=names{j}; result.(key)(n,gidx,family,t)=vals(j);
                        if t>=21
                            compare([id ' old interval ' key],vals(j),old.(key)(n,gidx,family,t-20));
                            % Preserve old reported arrays bit-for-bit after independent verification.
                            result.(key)(n,gidx,family,t)=old.(key)(n,gidx,family,t-20);
                        end
                    end
                end
                if nu==0 || nu==3
                    policy=1;
                    if b==1 && nu==0, policy=3; end
                    if b==0 && nu==3, policy=2; end
                    if b==0 && nu==0, policy=4; end
                    anchor=original.primary{n}.policies{policy}; compare([id ' original GO'],p.go,anchor.go);
                    for key={'stateError','pr','observed','expected','K'}
                        compare([id ' original anchor ' key{1}],result.(key{1})(n,gidx,family,end),anchor.(key{1}));
                    end
                end
                result.reusedPreparations=result.reusedPreparations+1;
                assert(toc(started)<7200,'Refine:Budget','Two-hour bound exceeded.');
            end
        end
        if any(cellfun(@(v)v.network==n,result.newNullK))
            save(fullfile(cache,sprintf('null_n%02d.mat',n)),'nulls','-v7');
        end
        fprintf('Refinement network %02d complete, no preparation replay; %.1fs\n',n,toc(started));
    end
    assert(result.reusedPreparations==260);
    for j=1:numel(names)
        key=names{j}; assert(isequal(result.(key)(:,:,:,21:end),old.(key)));
        result.median.(key)=squeeze(median(result.(key),1));
    end
    result.maskReason='PR/alignment undefined for endpoints <= -500: target-independent baseline has zero target-centered covariance.';
    result.status='PASS'; result.elapsedSeconds=toc(started);
    result.checkCount=numel(checks); result.maxCheckError=max(cellfun(@(c)c.error,checks));
    result.Krange=[min(result.K,[],'all','omitnan'),max(result.K,[],'all','omitnan')];
    mkdir(target); save(fullfile(target,'gain_time.mat'),'result','-v7');
    stage3_write_json(fullfile(target,'summary.json'),result);
    stage3_write_json(fullfile(cfg.manifestRoot,'FIG2_REFINE_AUDIT.json'),struct('status','PASS','checks',{checks}));
    disp(rmfield(result,[names {'median'}]));

    function compare(id,a,b)
        assert(isequal(size(a),size(b)),'Refine:Shape','%s',id);
        err=max(abs(a-b),[],'all'); tol=1e-9+1e-10*max(abs(b),[],'all');
        checks{end+1}=struct('id',id,'error',err,'tolerance',tol);
        assert(all(isfinite(a),'all') && err<=tol,'Refine:Mismatch','%s: %.17g > %.17g',id,err,tol);
    end
end

function [P,Q]=projector(C,K,draws,seed)
    [U,S,~]=svd(C); bias=U*diag(sqrt(max(diag(S),0)));
    stream=RandStream('mt19937ar','Seed',seed); P=zeros(size(C)); Q=P;
    for draw=1:draws
        G=randn(stream,size(C,1),K); G=G./sqrt(sum(G.^2,1));
        weighted=bias*G; B=orth(weighted); [R,~]=qr(weighted,0);
        assert(size(B,2)==K); P=P+B*B.'; Q=Q+R*R.';
    end
    P=P/draws; Q=Q/draws;
end
