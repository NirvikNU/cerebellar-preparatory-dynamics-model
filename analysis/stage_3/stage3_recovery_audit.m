function audit = stage3_recovery_audit(cfg)
    % Independent cache-only audit. No integration, selection or original writes.
    receipt=jsondecode(fileread(fullfile(cfg.manifestRoot,'RECOVERY_COMPARISONS.json')));
    assert(strcmp(receipt.status,'PASS') && numel(receipt.completedCases)==45);
    destination=fullfile(cfg.manifestRoot,'RECOVERY_INDEPENDENT_AUDIT.json'); assert(~isfile(destination));
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); r=s.result;
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); registry=s.registry;
    map=readtable(fullfile(cfg.resultsRoot,'feasibility_map.csv'));
    audit=struct('status','IN PROGRESS','checks',{{}},'limitations',{{}},'independentN',10);
    try
        logicalFields={'analytical','rateRealizable','modulationOK','endpointBoundsOK','tested','physical','finitePhenotype','feasible'};
        for j=1:numel(logicalFields)
            flag=map.(logicalFields{j}); assert(all(isfinite(flag) & (flag==0 | flag==1)));
        end
        assert(height(map)==1080 && size(unique(map{:,{'network','direction','gridIndex'}},'rows'),1)==1080);
        compare('all masks intersection',map.feasible,double(map.analytical & map.physical & map.finitePhenotype));
        compare('screen exactly determines tested',map.tested,double(map.rateRealizable & map.modulationOK & map.endpointBoundsOK));
        assert(all(~map.physical(~logical(map.tested))) && all(isnan(map.prBlock(~logical(map.tested)))));
        sentinel=reshape(1:11*200*8,11,200,8); flattened=reshape(permute(sentinel,[1 3 2]),[],200);
        for n=1:200
            for q=1:8, compare('sentinel',flattened((q-1)*11+(1:11),n),sentinel(:,n,q)); end
        end
        % The sentinel is exact; compress its repetitive check receipt.
        audit.checks=audit.checks(1:2); audit.indexing='[time,neuron,target] -> [time*target,neuron]; every sentinel column preserves one neuron.';
        primaryPR=zeros(10,2); primaryAI=zeros(10,2); primaryError=zeros(10,2);
        policyRows=zeros(40,13); sampledRows=zeros(30,11); sensitivityRows=zeros(4,12);
        policyRow=0; sampleRow=0;
        for member=1:10
            s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',member)),'model'); m=s.model;
            s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',member)),'ref'); ref=s.ref;
            grid=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',member)));
            full=zeros(102,m.n,8);
            for target=1:8
                hand=ref.hand(:,:,target); speed=sqrt(hand(:,2).^2+hand(:,4).^2);
                onset=find(speed>=.2*max(speed),1)-1; compare('reference onset',onset,ref.moMs(target));
                joined=[ref.prep.rates(1:500,:,target);ref.movement.rates(:,:,target)];
                full(:,:,target)=[ref.prep.rates(1:10:501,:,target);joined(501+onset+cfg.fullMO,:)];
            end
            observations=zeros(816,m.n);
            for target=1:8, observations((target-1)*102+(1:102),:)=full(:,:,target); end
            mu=sum(observations,1)/816; sd=sqrt(sum((observations-mu).^2,1)/815).';
            compare('per-neuron reference SD',sd,ref.scale);
            fg=stage3_recovery_geometry(full,sd); ig=stage3_recovery_geometry(ref.prep.rates(401:10:501,:,:),sd);
            compare('reference full covariance',fg.covariance,ref.fullCov); geometryCheck('intact',ig,ref.geometry);
            f=@(x)-x+m.W*max(x,0)+m.h;
            gain=ref.kappa; wn=norm(m.W,2); step=cfg.dt/m.tau;
            assert(abs(1-step*(1+gain))+step*wn<1 && abs(1-step*(1+gain+ref.nu))+step*wn<1);
            compare('reference release',max(vecnorm(ref.prep.go-m.xstar)./max(1,vecnorm(m.xstar))),ref.releaseRelative);
            compare('reference hand fidelity',max(abs(ref.hand-ref.comparatorHand),[],'all'),ref.handErrorMax);
            assert(ref.releaseRelative<=cfg.intactReleaseRelativeTolerance && ref.handErrorMax<=cfg.intactHandToleranceM);
            Y=(max(m.xstar,0)-mean(max(m.xstar,0),2))./sd;
            compare('settled identity',Y,ref.U*diag(sqrt(ref.ell))*ref.Z);
            assert(ref.d==sum(svd(Y)>ref.rankThreshold)); compare('target coordinate covariance',cov(ref.Z.'),eye(ref.d));
            nv=stage3_recovery_null(ref.fullCov,ref.U*diag(ref.ell)*ref.U.',ref.T,ref.d,cfg.nullDraws,cfg.nullSeedBase+member);
            compare('settled null 10000 QR projectors',nv,ref.settledNull);
            compare('settled null lower margin',max(0,mean(nv)-cfg.nullHoeffdingRadius-cfg.alignmentMargin),ref.etaLower);
            compare('sufficient rho boundary',max([0,(.05*ref.T-min(ref.ell))/(1-.05*ref.d),max(ref.ell)*(1/ref.etaLower-1)]),ref.rhoBound);
            available=find(~cellfun(@isempty,grid.nulls));
            for K=available(:).'
                denominator=sum(ref.geometry.eigenvalues(1:K));
                nv=stage3_recovery_null(ref.fullCov,ref.geometry.covariance,denominator,K,cfg.nullDraws,cfg.nullSeedBase+member);
                compare('finite null 10000 QR projectors',nv,grid.nulls{K});
            end
            for direction=1:3
                for j=1:36
                    row=map(map.network==member & map.direction==direction & map.gridIndex==j,:); assert(height(row)==1);
                    d=grid.definitions{direction,j}; p=grid.preparations{direction,j};
                    assert(d.member==member && d.direction==direction && d.gridIndex==j);
                    assert(d.alpha==cfg.alpha(ceil(j/6)) && d.betaNormalized==cfg.betaNormalized(mod(j-1,6)+1));
                    compare('map parameters',row{:,{'alpha','betaNormalized','beta'}},[d.alpha,d.betaNormalized,d.beta]);
                    compare('orthogonal direction',d.U.'*d.V,zeros(ref.d)); compare('direction norm',d.V.'*d.V,eye(ref.d));
                    y=(d.alpha*d.U*diag(sqrt(d.ell))+d.beta*d.V)*d.Z;
                    rate=ref.meanRate+sd.*y; rho=(d.beta/d.alpha)^2;
                    C=y*y.'/7; pr=trace(C)^2/trace(C*C);
                    compare('settled PR',pr,row.analyticPRBlock);
                    [Q,~]=qr((d.alpha*d.U*diag(sqrt(d.ell))+d.beta*d.V),0);
                    ai=sum((Y.'*Q).^2,'all')/(7*ref.T); compare('settled alignment',ai,row.analyticAI);
                    ratio=sum(y.^2,'all')/(7*ref.T); rawRatio=sum((rate-ref.meanRate).^2,'all')/(7*ref.rawTrace);
                    compare('variance ratios',[ratio rawRatio],row{:,{'normalizedVarianceRatio','rawVarianceRatio'}});
                    compare('rate and state endpoints',[min(rate,[],'all') max(rate,[],'all') max(vecnorm(d.xB))],row{:,{'minimumRate','endpointRateMax','endpointStateMax'}});
                    compare('rate flag',all(rate>=0,'all'),logical(row.rateRealizable));
                    compare('modulation flag',min([ratio rawRatio])>=.25 && max([ratio rawRatio])<=2,logical(row.modulationOK));
                    compare('analytic flag',rho>ref.rhoBound,logical(row.analytical));
                    endpointMax=zeros(1,5);
                    for point={repmat(m.spontaneous,1,8),d.xB,m.xstar}
                        x=point{1}; ci=-f(d.xB)-d.kappa*(x-d.xB); fb=-d.nu*(x-m.xstar);
                        components={ci,d.b,fb,d.b+fb,ci+d.b+fb};
                        for component=1:5, endpointMax(component)=max(endpointMax(component),max(vecnorm(components{component}))); end
                    end
                    compare('endpoint inputs',max(endpointMax),row.endpointInputMax);
                    endpointOK=max(rate,[],'all')<=ref.rateLimit && max(vecnorm(d.xB))<=ref.stateLimit && max(endpointMax)<=ref.inputLimit;
                    compare('endpoint bound flag',endpointOK,logical(row.endpointBoundsOK));
                    x=.3*m.spontaneous+.7*m.xstar; ci=d.corticalConstant-d.kappa*x; cb=d.b-d.nu*(x-m.xstar);
                    compare('policy identity',f(x)+ci+cb,f(x)-f(m.xstar)-(d.kappa+d.nu)*(x-m.xstar));
                    compare('block equilibrium',f(d.xB)+d.corticalConstant-d.kappa*d.xB,zeros(size(d.xB)));
                    compare('intact equilibrium',f(m.xstar)+d.corticalConstant-d.kappa*m.xstar+d.b,zeros(size(d.xB)));
                    if isempty(p), assert(~row.tested); continue; end
                    g=stage3_recovery_geometry(p.lateRates,sd); geometryCheck('grid finite',g,p.geometry);
                    K=max(ig.k,g.k); den=sum(ig.eigenvalues(1:K));
                    projected=sum((ig.matrix*g.basis(:,1:K)).^2,'all')/((size(ig.matrix,1)-1)*den);
                    traced=trace(g.basis(:,1:K).'*ig.covariance*g.basis(:,1:K))/den;
                    compare('projection versus trace',projected,traced); compare('map measured alignment',projected,row.observed);
                    compare('map measured PR',g.pr,row.prBlock); compare('map common K',K,row.commonK);
                    compare('map captures',[sum(ig.eigenvalues(1:K))/sum(ig.eigenvalues),sum(g.eigenvalues(1:K))/sum(g.eigenvalues)],row{:,{'intactCapture','blockCapture'}});
                    null=grid.nulls{K}; compare('map null mean',mean(null),row.expected);
                    compare('map MC SE',std(null)/sqrt(numel(null)),row.nullSE);
                    compare('map MC halves',mean(null(1:5000))-mean(null(5001:end)),row.nullHalfDifference);
                    margin=mean(null)-cfg.nullHoeffdingRadius-cfg.alignmentMargin-projected;
                    compare('map margin',margin,row.alignmentMargin);
                    physical=p.rateMax<=ref.rateLimit && p.stateMax<=ref.stateLimit && max(p.inputMax)<=ref.inputLimit && p.settle<=cfg.settleRelativeTolerance && row.localMaxReal<0 && row.localEulerRadius<1;
                    compare('physical mask',physical,logical(row.physical));
                    compare('finite mask',g.pr>ig.pr+cfg.prMargin && margin>0,logical(row.finitePhenotype));
                    compare('saved native extrema',p.inputMax,row{:,{'corticalMax','sustainedMax','feedbackMax','cbMax','totalMax'}});
                    compare('terminal settling',max(vecnorm(p.go-d.xB)./max(1,vecnorm(d.xB-m.spontaneous))),row.settle);
                end
            end
            primary=r.primary{member}; d=registry.primary{member};
            assert(isequaln(d,grid.definitions{d.direction,d.gridIndex}));
            pr=stage3_recovery_geometry(primary.block.lateRates,sd);
            primaryPR(member,:)=[ig.pr,pr.pr];
            primaryAI(member,:)=[primary.mapRow.observed,primary.mapRow.expected];
            ei=errors(primary.intactHand,ref.comparatorHand,ref.comparatorMoMs);
            eb=errors(primary.blockHand,ref.comparatorHand,ref.comparatorMoMs);
            compare('primary intact errors',ei,primary.errorIntact); compare('primary block errors',eb,primary.errorBlock);
            primaryError(member,:)=[mean(ei),mean(eb)];
            for policy=1:4
                saved=primary.policies{policy};
                if policy==1
                    pg=ig; go=ref.prep.go;
                elseif policy==4
                    pg=pr; go=primary.block.go;
                else
                    s=load(fullfile(cfg.cacheRoot,'evidence_recovery',sprintf('policy_n%02d_p%d.mat',member,policy)),'raw');
                    pg=stage3_recovery_geometry(s.raw.prep.rates(401:10:501,:,:),sd); go=s.raw.prep.go;
                    nativeCheck(s.raw.prep,d,m);
                end
                K=max(ig.k,pg.k); den=sum(ig.eigenvalues(1:K));
                observed=sum((ig.matrix*pg.basis(:,1:K)).^2,'all')/((size(ig.matrix,1)-1)*den);
                compare('policy PR independent',pg.pr,saved.pr); compare('policy projection independent',observed,saved.observed);
                compare('policy GO independent',go,saved.go);
                policyRow=policyRow+1;
                policyRows(policyRow,:)=[member policy mean(vecnorm(go-m.xstar)) pg.pr observed saved.expected K saved.inputMax saved.expected-observed];
            end
            for j=1:numel(r.additional)
                a=r.additional{j}; if a.network~=member, continue; end
                d=registry.additional{j}; assert(d.member==a.network && d.direction==a.direction && d.gridIndex==a.gridIndex);
                assert(isequaln(d,grid.definitions{d.direction,d.gridIndex}));
                duplicate=d.direction==1 && d.gridIndex==registry.primaryGridIndex;
                if duplicate, hand=primary.blockHand;
                else
                    s=load(fullfile(cfg.cacheRoot,'evidence_recovery',sprintf('movement_n%02d_d%d_g%02d.mat',member,d.direction,d.gridIndex)),'raw'); hand=s.raw.hand;
                    compare('movement release identity',s.raw.initialState,grid.preparations{d.direction,d.gridIndex}.go);
                    compare('movement first saved rate',squeeze(s.raw.movement.rates(1,:,:)),max(s.raw.initialState,0));
                end
                err=errors(hand,ref.comparatorHand,ref.comparatorMoMs); compare('additional RMS',err,a.targetErrorsMM);
                endpoint=hypot(squeeze(hand(end,1,:)-ref.comparatorHand(end,1,:)),squeeze(hand(end,3,:)-ref.comparatorHand(end,3,:))).'*1000;
                compare('additional endpoint',endpoint,a.endpointErrorMM);
                row=map(map.network==member & map.direction==d.direction & map.gridIndex==d.gridIndex,:); assert(row.feasible);
                sampleRow=sampleRow+1;
                sampledRows(sampleRow,:)=[member d.direction d.gridIndex d.alpha d.betaNormalized row.prBlock row.observed row.expected mean(err) mean(endpoint) duplicate];
            end
            fprintf('Independent cache audit: network %02d complete\n',member);
        end
        compare('primary PR table',primaryPR,r.metrics.pr); compare('primary AI table',primaryAI,r.metrics.alignmentObservedExpected);
        % Verify frozen choice optimality predicates without invoking selection.
        base=map(map.network==1 & map.direction==1,:);
        key=[abs(log(base.alpha.^2+base.betaNormalized.^2)),-base.alpha,base.betaNormalized];
        [~,ordering]=sortrows(key,[1 2 3]);
        common=arrayfun(@(j)sum(map.feasible & map.direction==1 & map.gridIndex==j)==10,(1:36).');
        admissible=ordering(common(ordering)); assert(registry.primaryGridIndex==admissible(1));
        for network=1:10
            previous=zeros(0,2);
            for direction=1:3
                a=sampledRows(sampledRows(:,1)==network & sampledRows(:,2)==direction,:); assert(size(a,1)==1);
                acceptable=map.gridIndex(map.network==network & map.direction==direction & map.feasible);
                ranked=ordering(ismember(ordering,acceptable));
                if ~isempty(previous)
                    distances=zeros(numel(ranked),1);
                    for candidate=1:numel(ranked)
                        point=[base.alpha(ranked(candidate)),base.betaNormalized(ranked(candidate))];
                        distances(candidate)=min(vecnorm((point-previous)./[range(cfg.alpha),range(cfg.betaNormalized)],2,2));
                    end
                    ranked=ranked(distances==max(distances));
                end
                assert(a(3)==ranked(1),'Audit:Selection','Saved solution violates frozen ordering predicate.');
                previous(end+1,:)=a(4:5); %#ok<AGROW>
            end
        end
        assert(~registry.movementInspected && r.selectionBeforeMovement);
        compare('primary movement table',primaryError,r.metrics.earlyErrorMM);
        random=RandStream('mt19937ar','Seed',cfg.bootstrapSeed); compare('bootstrap fixed indices',randi(random,10,10000,10),r.bootstrapIndices);
        values={primaryPR,primaryAI,primaryError}; names={'pr','alignment','earlyErrorMM'};
        for j=1:3
            [med,se]=uncertainty(values{j},r.bootstrapIndices);
            compare('summary median',med,r.statistics.(names{j}).median); compare('summary independent SE',se,r.statistics.(names{j}).se);
        end
        diffs=[primaryPR(:,2)-primaryPR(:,1),primaryAI(:,1)-primaryAI(:,2),primaryError(:,2)-primaryError(:,1)];
        names={'prTest','alignmentTest','earlyTest'}; ps=zeros(1,3);
        for j=1:3
            d=diffs(:,j); sums=0;
            for n=1:10, sums=[sums+d(n);sums-d(n)]; end
            stat=abs(sum(d)/10); ps(j)=sum(abs(sums/10)>=stat-1e-12*max(1,stat))/1024;
            saved=r.statistics.(names{j}); [med,se]=uncertainty(d,r.bootstrapIndices);
            compare('paired median and SE',[med se],[saved.medianDifference saved.medianDifferenceSE]);
            compare('exact 1024 signs',ps(j),saved.p);
        end
        [p,order]=sort(ps(1:2)); q=zeros(1,2); q(order)=[min(2*p(1),p(2)),p(2)]; compare('two-test BH',q,r.statistics.geometryQ);
        for j=1:4
            s=load(fullfile(cfg.cacheRoot,'evidence_recovery',sprintf('sensitivity_%d.mat',j)),'raw'); raw=s.raw; d=raw.identity.definition;
            s=load(fullfile(cfg.ensembleRoot,'network_01.mat'),'model'); m=s.model;
            nativeCheck(raw.intact,d,m); nativeCheck(raw.block,d,m);
            saved=r.sensitivity{j}; sensitivityRows(j,:)=[j saved.prIntact saved.prBlock saved.observed saved.expected saved.K saved.stateError saved.inputMax];
        end
        s=load(fullfile(cfg.cacheRoot,'evidence_recovery','fine_n01_d1_g05.mat'),'raw');
        nativeCheck(s.raw.prep,registry.primary{1},m);
        assert(r.stepCheck.curveRelative<=cfg.stepCurveRelativeTolerance && r.stepCheck.goRelative<=cfg.stepReleaseRelativeTolerance);
        audit.counts=struct('rows',height(map),'tested',sum(map.tested),'untested',sum(~map.tested), ...
            'feasible',sum(map.feasible),'outsideBoundEmpirical',sum(map.physical & map.finitePhenotype & ~map.analytical), ...
            'primaryAdditionalRecords',40,'uniqueSampleIdentities',size(unique(sampledRows(:,1:3),'rows'),1),'duplicates',sum(sampledRows(:,11)));
        audit.limitations={'Grid native state trajectories were deliberately not retained: native input/rate/state extrema are checked against saved extrema and thresholds, not recomputed by unauthorized grid replay.', ...
            'Geometry effects are inverse-design constraints, not independent predictions or scientific acceptance.'};
        audit.status='PASS'; audit.completedUTC=char(datetime('now','TimeZone','UTC'));
        exports=fullfile(cfg.resultsRoot,'recovery_audit'); assert(~isfolder(exports)); mkdir(exports);
        writetable(array2table(policyRows,'VariableNames',{'network','policy','stateError','PR','observed','expected','K','corticalMax','sustainedMax','feedbackMax','cbMax','totalMax','belowNull'}),fullfile(exports,'policies.csv'));
        writetable(array2table(sampledRows,'VariableNames',{'network','direction','gridIndex','alpha','betaNormalized','PR','observed','expected','earlyErrorMM','endpointErrorMM','duplicatesPrimary'}),fullfile(exports,'sampled_solutions.csv'));
        writetable(array2table(sensitivityRows,'VariableNames',{'variant','prIntact','prBlock','observed','expected','K','stateError','corticalMax','sustainedMax','feedbackMax','cbMax','totalMax'}),fullfile(exports,'sensitivities.csv'));
    catch err
        audit.status='STOP'; audit.error=err.message; stage3_write_json(destination,audit); rethrow(err);
    end
    stage3_write_json(destination,audit); fprintf('Saved-output independent audit PASS (%d comparisons)\n',numel(audit.checks));

    function compare(label,actual,expected)
        assert(isequal(size(actual),size(expected)),'Audit:Shape','%s shape mismatch.',label);
        delta=max(abs(double(actual)-double(expected)),[],'all'); tolerance=1e-9+1e-10*max(abs(double(expected)),[],'all');
        ok=all(isfinite(actual),'all') && delta<=tolerance;
        audit.checks{end+1}=struct('label',label,'error',delta,'tolerance',tolerance,'pass',ok);
        if ~ok
            audit.mismatch=struct('label',label,'actual',actual,'preserved',expected);
            error('Audit:Mismatch','%s: %.17g exceeds %.17g.',label,delta,tolerance);
        end
    end
    function geometryCheck(label,g,saved)
        compare([label ' covariance'],g.covariance,saved.covariance);
        compare([label ' PR'],g.pr,saved.pr); compare([label ' K'],g.k,saved.k);
        assert(sum(g.eigenvalues(1:g.k))>.95*sum(g.eigenvalues));
        assert(g.k==1 || sum(g.eigenvalues(1:g.k-1))<=.95*sum(g.eigenvalues));
    end
    function nativeCheck(p,d,m)
        states=p.nativeStates; maxima=zeros(1,5); stateMax=0; rateMax=0;
        fB=-d.xB+m.W*max(d.xB,0)+m.h; fS=-m.xstar+m.W*max(m.xstar,0)+m.h;
        b=fB-fS+d.kappa*(m.xstar-d.xB);
        every=round(.001/p.dt); sample=0;
        for nativeIndex=1:size(states,3)
            nativeX=states(:,:,nativeIndex); c=-fB-d.kappa*(nativeX-d.xB); feedback=-d.nu*(nativeX-m.xstar);
            terms={c,b,feedback,b+feedback,c+p.mode(1)*b+p.mode(2)*feedback};
            for pieceIndex=1:5, maxima(pieceIndex)=max(maxima(pieceIndex),max(sqrt(sum(terms{pieceIndex}.^2,1)))); end
            rateMax=max(rateMax,max(max(nativeX,0),[],'all')); stateMax=max(stateMax,max(sqrt(sum(nativeX.^2,1))));
            if mod(nativeIndex-1,every)==0
                sample=sample+1; compare('saved activity from native state',squeeze(p.rates(sample,:,:)),max(nativeX,0));
                compare('saved distance from native state',p.distance(sample),mean(sqrt(sum((nativeX-m.xstar).^2,1))));
            end
        end
        compare('native component maxima',maxima,p.inputMax); compare('native rate/state maxima',[rateMax stateMax],[p.rateMax p.statesNormMax]);
        compare('terminal state saved',states(:,:,end),p.go);
    end
end

function rms=errors(hand,reference,onset)
    rms=zeros(1,8);
    for target=1:8
        rows=1+onset(target)+(0:200); x=hand(rows,1,target)-reference(rows,1,target); y=hand(rows,3,target)-reference(rows,3,target);
        rms(target)=1000*sqrt((dot(x,x)+dot(y,y))/201);
    end
end

function [med,se]=uncertainty(values,indices)
    ordered=sort(values,1); med=(ordered(5,:)+ordered(6,:))/2; samples=zeros(size(indices,1),size(values,2));
    for draw=1:size(indices,1)
        ordered=sort(values(indices(draw,:),:),1); samples(draw,:)=(ordered(5,:)+ordered(6,:))/2;
    end
    average=sum(samples,1)/size(samples,1); se=sqrt(sum((samples-average).^2,1)/(size(samples,1)-1));
end
