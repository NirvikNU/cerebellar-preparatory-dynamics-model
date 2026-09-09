function result = stage3_gain_time(cfg)
    % Frozen grid; reuse existing trajectories; no movement or selection call.
    target=fullfile(cfg.resultsRoot,'gain_time');
    cache=fullfile(cfg.cacheRoot,'gain_time');
    assert(~isfolder(target) && ~isfolder(cache),'GainTime:Overwrite','Refuse repeat/overwrite.');
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); reg=s.registry;
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); original=s.result;
    assert(reg.primaryGridIndex==5 && numel(reg.primary)==10);
    result=struct('task','STAGE3-DIAGNOSTIC-GAIN-TIME-01','status','RUNNING', ...
        'nu',0:.5:6,'endpointGO',-400:10:0,'sustained',[1 0], ...
        'dimensionOrder','network,gain,policy,endpoint', ...
        'absoluteTolerance',1e-9,'relativeTolerance',1e-10, ...
        'checks',{{}},'newProtocols',0,'reusedProtocols',0,'nulls',{{}});
    shape=[10 13 2 41]; names={'stateError','pr','observed','expected','deficit','K','referenceK','policyK','referenceCapture','policyCapture'};
    for j=1:numel(names), result.(names{j})=zeros(shape); end
    mkdir(target); mkdir(cache); started=tic;
    try
        for n=1:10
            s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
            s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
            d=reg.primary{n}; assert(d.member==n && d.direction==1 && d.gridIndex==5);
            assert(d.alpha==.1 && d.betaNormalized==1 && d.nu==3 && d.kappa==ref.kappa);
            compare(sprintf('n%d scale identity',n),d.scale,ref.scale);
            refs=cell(41,1);
            for t=1:41
                ix=501+result.endpointGO(t)+(-100:10:0);
                refs{t}=stage3_geometry(ref.prep.rates(ix,:,:),ref.scale);
            end
            projectors=cell(88,1); independentProjectors=cell(88,1);
            % Endpoint reference policies are checked before new integration.
            for family=1:2
                for gainIndex=1:13
                    nu=result.nu(gainIndex); sustained=result.sustained(family);
                    id=sprintf('n%02d_b%d_nu%02d',n,sustained,gainIndex);
                    if sustained==1 && nu==3
                        p=ref.prep; source='frozen intact reference';
                        states=permute(p.nativeStates(:,:,1:5:end),[3 1 2]);
                    elseif (sustained==1 && nu==0) || (sustained==0 && nu==3)
                        policy=3; if sustained==0, policy=2; end
                        s=load(fullfile(cfg.cacheRoot,'evidence_recovery',sprintf('policy_n%02d_p%d.mat',n,policy)),'raw');
                        p=s.raw.prep; source='validated partial-removal recovery';
                        compare([id ' frozen xB'],s.raw.identity.definition.xB,d.xB);
                        states=permute(p.nativeStates(:,:,1:5:end),[3 1 2]);
                    else
                        p=stage3_gain_time_prepare(m,d,nu,sustained);
                        states=p.states; source='new fixed-grid preparation';
                        result.newProtocols=result.newProtocols+1;
                        save(fullfile(cache,[id '.mat']),'p','source','-v7.3');
                    end
                    if ~strcmp(source,'new fixed-grid preparation'), result.reusedProtocols=result.reusedProtocols+1; end
                    compare([id ' states/rates'],max(states,0),p.rates);
                    distance=mean(sqrt(sum((states-reshape(m.xstar,1,200,8)).^2,2)),3);
                    compare([id ' full-200D distance'],distance(:),p.distance(:));
                    for t=1:41
                        ix=501+result.endpointGO(t)+(-100:10:0); ig=refs{t};
                        g=stage3_geometry(p.rates(ix,:,:),ref.scale);
                        g2=stage3_recovery_geometry(p.rates(ix,:,:),ref.scale);
                        compare([id ' covariance'],g.covariance,g2.covariance);
                        compare([id ' independent PR'],g.pr,g2.pr);
                        compare([id ' minimum K'],g.k,g2.k);
                        K=max(ig.k,g.k); den=sum(ig.eigenvalues(1:K));
                        obs=trace(g.basis(:,1:K).'*ig.covariance*g.basis(:,1:K))/den;
                        direct=sum((ig.matrix*g.basis(:,1:K)).^2,'all')/((size(ig.matrix,1)-1)*den);
                        compare([id ' projected alignment'],obs,direct);
                        if isempty(projectors{K})
                            [projectors{K},independentProjectors{K}]=null_projector(ref.fullCov,K,cfg.nullDraws,cfg.nullSeedBase+n);
                            compare(sprintf('n%d K%d independent QR null',n,K),projectors{K},independentProjectors{K});
                        end
                        expected=trace(ig.covariance*projectors{K})/den;
                        compare([id ' QR expected'],expected,trace(ig.covariance*independentProjectors{K})/den);
                        row=501+result.endpointGO(t);
                        vals=[distance(row),g.pr,obs,expected,expected-obs,K,ig.k,g.k, ...
                            sum(ig.eigenvalues(1:K))/sum(ig.eigenvalues),sum(g.eigenvalues(1:K))/sum(g.eigenvalues)];
                        for j=1:numel(names), result.(names{j})(n,gainIndex,family,t)=vals(j); end
                    end
                    if nu==0 || nu==3
                        policy=1;
                        if sustained==1 && nu==0, policy=3; end
                        if sustained==0 && nu==3, policy=2; end
                        if sustained==0 && nu==0, policy=4; end
                        old=original.primary{n}.policies{policy};
                        compare([id ' preserved GO'],p.go,old.go);
                        for name={'stateError','pr','observed','expected','K'}
                            key=name{1}; compare([id ' preserved ' key],result.(key)(n,gainIndex,family,end),old.(key));
                        end
                        if policy==4
                            compare([id ' original block late rates'],p.rates(401:10:501,:,:),original.primary{n}.block.lateRates);
                            compare([id ' original block distance'],p.distance(:),original.primary{n}.block.distance(:));
                        end
                    end
                    assert(toc(started)<7200,'GainTime:Budget','Bounded two-hour diagnostic budget exceeded.');
                end
            end
            nullEvidence=struct('projectors',{projectors},'qrProjectors',{independentProjectors}, ...
                'seed',cfg.nullSeedBase+n,'draws',cfg.nullDraws,'fullCov',ref.fullCov);
            save(fullfile(cache,sprintf('null_n%02d.mat',n)),'nullEvidence','-v7.3');
            result.nulls{n}=struct('network',n,'K',find(~cellfun(@isempty,projectors)).', ...
                'seed',cfg.nullSeedBase+n,'draws',cfg.nullDraws);
            fprintf('Gain-time network %02d complete; preserved cells match. %.1fs\n',n,toc(started));
        end
        assert(result.newProtocols==230 && result.reusedProtocols==30);
        result.status='PASS'; result.elapsedSeconds=toc(started);
        for j=1:numel(names), result.median.(names{j})=squeeze(median(result.(names{j}),1)); end
        checks=result.checks; result.checkCount=numel(checks);
        result.maxCheckError=max(cellfun(@(c)c.error,checks));
        result=rmfield(result,'checks');
        save(fullfile(target,'gain_time.mat'),'result','-v7');
        stage3_write_json(fullfile(target,'summary.json'),result);
        stage3_write_json(fullfile(cfg.manifestRoot,'GAIN_TIME_AUDIT.json'),struct('status','PASS','checks',{checks},'elapsedSeconds',toc(started)));
    catch err
        result.status='STOP'; result.error=err.message;
        save(fullfile(target,'partial_stop.mat'),'result','-v7.3');
        stage3_write_json(fullfile(cfg.manifestRoot,'GAIN_TIME_STOP.json'),struct('error',err.message,'checks',{result.checks}));
        rethrow(err);
    end
    function compare(id,a,b)
        assert(isequal(size(a),size(b)),'GainTime:Shape','%s shape mismatch',id);
        delta=max(abs(a-b),[],'all'); tol=1e-9+1e-10*max(abs(b),[],'all');
        result.checks{end+1}=struct('id',id,'error',delta,'tolerance',tol);
        assert(all(isfinite(a),'all') && delta<=tol,'GainTime:Mismatch','%s: %.17g > %.17g',id,delta,tol);
    end
end

function [P,Q] = null_projector(C,K,draws,seed)
    [U,S,~]=svd(C); bias=U*diag(sqrt(max(diag(S),0)));
    stream=RandStream('mt19937ar','Seed',seed); P=zeros(size(C)); Q=P;
    for draw=1:draws
        G=randn(stream,size(C,1),K); G=G./sqrt(sum(G.^2,1));
        weighted=bias*G; B=orth(weighted); [R,~]=qr(weighted,0);
        assert(size(B,2)==K); P=P+B*B.'; Q=Q+R*R.';
    end
    P=P/draws; Q=Q/draws;
end
