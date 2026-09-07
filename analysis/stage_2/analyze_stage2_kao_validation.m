function out = analyze_stage2_kao_validation(cfg)
    % Independent Kao Fig. 6C method; source mapping in KAO_VALIDATION_PLAN.md.
    root=cfg.projectRoot; base=fullfile(root,'results','stage_2','current');
    manifest=readtable(fullfile(base,'cache_manifest.csv'),'TextType','string');
    protected=readtable(fullfile(base,'protected_before.csv'),'TextType','string');
    for j=1:height(protected)
        assert(sha256_file(fullfile(root,protected.relative_path(j)))==protected.sha256(j));
    end
    prior=jsondecode(fileread(fullfile(root,'artifacts','manifests', ...
        'stage2_lambda_sweep','R2_FILE_MANIFEST.json')));
    for j=1:numel(prior.files)
        assert(strcmpi(sha256_file(fullfile(root,prior.files(j).Path)),prior.files(j).SHA256));
    end
    out.cfg=cfg; out.observed=zeros(10,1); out.expected=zeros(10,1);
    out.k=zeros(10,1); out.captured=zeros(10,1); out.previousCaptured=zeros(10,1);
    out.moveCaptured=zeros(10,1); out.scale=zeros(10,200);
    out.nullDraws=zeros(cfg.nullDraws,10); out.mcSE=zeros(10,1); out.halfDifference=zeros(10,1);
    out.audit=struct('maxScaleError',0,'maxCenterError',0,'maxProjectionError',0, ...
        'maxKVarianceError',0,'maxIndependentNullError',0,'maxBootstrapSEError',0);
    % Every resulting column identifies exactly one neuron.
    sentinel=reshape(1:31*200*8,31,200,8); flat=stage2_matrix(sentinel);
    for n=1:200
        original=sentinel(:,n,:); assert(isequal(flat(:,n),original(:)));
    end
    assert(isequal(cfg.prepGO+500,150:10:450));
    assert(isequal(cfg.moveGO-cfg.modelMO,-50:10:250) && cfg.modelMO==100);
    for member=1:10
        file=fullfile(cfg.cacheRoot,sprintf('network_%02d.mat',member));
        assert(sha256_file(file)==manifest.SHA256(member),'Cache hash mismatch.');
        saved=load(file,'net'); rates=saved.net.rates;
        assert(isequal(size(rates),[1099 200 8 8]));
        prep=double(rates(cfg.prepGO+501,:,:,1));
        move=double(rates(cfg.moveGO+501,:,:,1));
        both=cat(1,prep,move); raw=stage2_matrix(both);
        scale=max(raw,[],1)-min(raw,[],1)+5;
        assert(all(isfinite(raw),'all') && all(scale>=5));
        prepScaled=prep./scale; moveScaled=move./scale;
        p=prepScaled-mean(prepScaled,3); m=moveScaled-mean(moveScaled,3);
        % Independent explicit-neuron/target normalization, without reshape.
        for neuron=1:200
            v=both(:,neuron,:); independentScale=max(v(:))-min(v(:))+5;
            out.audit.maxScaleError=max(out.audit.maxScaleError,abs(scale(neuron)-independentScale));
            for target=1:8
                centerP=sum(prep(:,neuron,:),3)/8/independentScale;
                centerM=sum(move(:,neuron,:),3)/8/independentScale;
                out.audit.maxCenterError=max([out.audit.maxCenterError; ...
                    abs(p(:,neuron,target)-(prep(:,neuron,target)/independentScale-centerP)); ...
                    abs(m(:,neuron,target)-(move(:,neuron,target)/independentScale-centerM))]);
            end
        end
        P=stage2_matrix(p); M=stage2_matrix(m); F=[P;M];
        Cp=cov(P); Cm=cov(M); Cf=cov(F);
        [Dp,ep]=eig(Cp,'vector'); [ep,order]=sort(real(ep),'descend'); Dp=Dp(:,order);
        [Dm,em]=eig(Cm,'vector'); [em,order]=sort(real(em),'descend'); Dm=Dm(:,order);
        ep=max(ep,0); em=max(em,0); cumulative=cumsum(ep)/sum(ep);
        k=find(cumulative>=.8,1); denominator=sum(ep(1:k));
        [~,S,V]=svd(P-mean(P,1),'econ'); independentEig=diag(S).^2/(size(P,1)-1);
        independentCum=cumsum(independentEig)/sum(independentEig);
        assert(k==find(independentCum>=.8,1));
        previous=sum(ep(1:k-1))/sum(ep); assert(previous<.8 && cumulative(k)>=.8);
        out.audit.maxKVarianceError=max(out.audit.maxKVarianceError,abs(cumulative(k)-independentCum(k)));
        observed=trace(Dm(:,1:k).'*Cp*Dm(:,1:k))/denominator;
        direct=sum(((P-mean(P,1))*Dm(:,1:k)).^2,'all')/sum(((P-mean(P,1))*V(:,1:k)).^2,'all');
        out.audit.maxProjectionError=max(out.audit.maxProjectionError,abs(observed-direct));
        assert(abs(trace(Dp(:,1:k).'*Cp*Dp(:,1:k))/denominator-1)<1e-10);
        null=stage2_null(Cf,Cp,denominator,k,cfg.nullDraws,cfg.nullSeedBase+member);
        % QR and direct activity projection independently check 20 seeded draws.
        [U,S,~]=svd(Cf); bias=U*diag(sqrt(max(diag(S),0)));
        stream=RandStream('mt19937ar','Seed',cfg.nullSeedBase+member);
        for draw=1:20
            G=randn(stream,200,k); G=G./sqrt(sum(G.^2,1));
            [Q,~]=qr(bias*G,0);
            value=sum(((P-mean(P,1))*Q).^2,'all')/(size(P,1)-1)/denominator;
            out.audit.maxIndependentNullError=max(out.audit.maxIndependentNullError,abs(value-null(draw)));
        end
        out.observed(member)=observed; out.expected(member)=mean(null);
        out.k(member)=k; out.captured(member)=cumulative(k); out.previousCaptured(member)=previous;
        out.moveCaptured(member)=sum(em(1:k))/sum(em); out.scale(member,:)=scale;
        out.nullDraws(:,member)=null; out.mcSE(member)=std(null)/sqrt(cfg.nullDraws);
        out.halfDifference(member)=abs(mean(null(1:5000))-mean(null(5001:end)));
        assert(sha256_file(file)==manifest.SHA256(member));
        fprintf('Kao validation network %02d complete\n',member);
    end
    stream=RandStream('mt19937ar','Seed',cfg.bootstrapSeed);
    indices=randi(stream,10,cfg.bootstrapDraws,10); out.bootstrapIndices=indices;
    difference=out.observed-out.expected;
    out.summary.observed=stage2_bootstrap(out.observed,indices);
    out.summary.expected=stage2_bootstrap(out.expected,indices);
    out.summary.difference=stage2_bootstrap(difference,indices);
    out.summary.test=stage2_signflip(difference,indices);
    values=[out.observed out.expected difference];
    se=[out.summary.observed.se out.summary.expected.se out.summary.difference.se];
    for metric=1:3
        med=zeros(10000,1);
        for b=1:10000, med(b)=median(values(indices(b,:),metric)); end
        independentSE=sqrt(sum((med-mean(med)).^2)/9999);
        out.audit.maxBootstrapSEError=max(out.audit.maxBootstrapSEError,abs(independentSE-se(metric)));
    end
    extreme=0; statistic=abs(sum(difference)/10);
    for pattern=0:1023
        signs=ones(10,1);
        for j=1:10, if bitget(pattern,j)==0, signs(j)=-1; end, end
        extreme=extreme+(abs(sum(signs.*difference)/10)>=statistic-1e-12*max(1,statistic));
    end
    assert(out.summary.test.p==extreme/1024);
    assert(max(struct2array(out.audit))<1e-10);
    out.summary.k=out.k; out.summary.prepCaptured=out.captured;
    out.summary.mcSE=out.mcSE; out.summary.halfDifference=out.halfDifference;
    out.summary.plan='KAO_VALIDATION_PLAN.md'; out.summary.networkCount=10;
    out.summary.nullDrawCount=cfg.nullDraws; out.summary.modelMOOffsetMs=100;
    out.metrics=table((1:10).',out.k,out.captured,out.previousCaptured,out.moveCaptured, ...
        out.observed,out.expected,difference,out.mcSE,out.halfDifference, ...
        'VariableNames',{'network','K','prepCaptured','previousPrepCaptured','moveCaptured', ...
        'observed','expected','observedMinusExpected','nullMonteCarloSE','nullHalfDifference'});
    out.audit.protectedStage1Files=height(protected); out.audit.priorManifestFiles=numel(prior.files);
    out.audit.cacheHashesMatched=10; out.audit.neuronSentinel=true; out.audit.windowsVerified=80;
end
