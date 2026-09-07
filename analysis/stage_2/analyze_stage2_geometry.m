function out = analyze_stage2_geometry(cfg)
    % Three revised analyses only; no call to controller or movement functions.
    preflight=jsondecode(fileread(fullfile(cfg.resultsRoot,'cache_preflight.json')));
    assert(strcmp(preflight.status,'PASS'));
    manifest=readtable(fullfile(cfg.originalResultsRoot,'cache_manifest.csv'),'TextType','string');
    out=struct('cfg',cfg,'status','R2 COMPUTED / VALIDATED; SCIENTIFIC REVIEW PENDING');
    out.pr=zeros(10,8); out.observed=zeros(10,8); out.expected=zeros(10,8);
    out.minimumK=zeros(10,8); out.commonK=zeros(10,8);
    out.capturedReference=zeros(10,8); out.capturedComparison=zeros(10,8);
    out.prepMoveObserved=zeros(10,1); out.prepMoveExpected=zeros(10,1);
    out.prepMoveMinimumK=zeros(10,2); out.prepMoveCommonK=zeros(10,1);
    out.prepMoveCaptured=zeros(10,2); out.scale=zeros(10,200);
    out.null=zeros(cfg.nullDraws,10,8); out.prepMoveNull=zeros(cfg.nullDraws,10);
    out.eigenvalues=zeros(10,8,200); out.prepMoveEigenvalues=zeros(10,2,200);
    out.independentErrors=zeros(10,3);
    originalHash=sha256_file(fullfile(cfg.projectRoot,'config','stage_2_config.m'));
    for member=1:10
        path=fullfile(cfg.cacheRoot,sprintf('network_%02d.mat',member));
        assert(sha256_file(path)==manifest.SHA256(member));
        saved=load(path,'net');
        assert(saved.net.configHash==originalHash);
        p=stage2_geometry_population(saved.net,cfg,member);
        fields={'pr','observed','expected','minimumK','commonK','capturedReference', ...
            'capturedComparison','prepMoveObserved','prepMoveExpected', ...
            'prepMoveMinimumK','prepMoveCommonK','prepMoveCaptured','scale'};
        for j=1:numel(fields), out.(fields{j})(member,:)=p.(fields{j}); end
        out.null(:,member,:)=reshape(p.null,cfg.nullDraws,1,8);
        out.prepMoveNull(:,member)=p.prepMoveNull;
        out.eigenvalues(member,:,:)=reshape(p.eigenvalues,1,8,200);
        out.prepMoveEigenvalues(member,:,:)=reshape(p.prepMoveEigenvalues,1,2,200);
        out.independentErrors(member,:)=[p.prError p.varianceError p.directError];
        assert(isequal(p.scale,preflight.referenceSD(member,:)));
        assert(isequal(p.onset,squeeze(preflight.onsetMs(member,:,:))));
        fprintf('R2 network %02d analysis validated.\n',member);
    end
    bs=RandStream('mt19937ar','Seed',cfg.bootstrapSeed);
    out.bootstrapIndices=randi(bs,10,cfg.bootstrapDraws,10);
    original=load(fullfile(cfg.originalResultsRoot,'analysis.mat'),'out');
    assert(isequal(out.bootstrapIndices,original.out.bootstrapIndices));
    out.deficit=out.expected-out.observed;
    fields={'pr','observed','expected','deficit','prepMoveObserved','prepMoveExpected'};
    for j=1:numel(fields)
        out.summary.(fields{j})=stage2_bootstrap(out.(fields{j}),out.bootstrapIndices);
    end
    tests=struct([]);
    families={'Prep PR: lambda-reference','Prep alignment: observed-expected'};
    for f=1:2
        p=zeros(1,7);
        for l=2:8
            if f==1, d=out.pr(:,l)-out.pr(:,1); else, d=out.observed(:,l)-out.expected(:,l); end
            t=stage2_signflip(d,out.bootstrapIndices);
            t.family=families{f}; t.lambda=cfg.lambda(l); t.q=NaN;
            tests=[tests;t]; %#ok<AGROW>
            p(l-1)=t.p;
        end
        q=stage2_bh(p);
        for l=1:7, tests((f-1)*7+l).q=q(l); end
    end
    x=[ones(8,1) log10(cfg.lambda(:))];
    slope=x\out.pr.'; out.prSlope=slope(2,:).';
    slope=x\out.deficit.'; out.deficitSlope=slope(2,:).';
    out.prSlopeTest=stage2_signflip(out.prSlope,out.bootstrapIndices);
    out.deficitSlopeTest=stage2_signflip(out.deficitSlope,out.bootstrapIndices);
    out.prepMoveTest=stage2_signflip(out.prepMoveObserved-out.prepMoveExpected,out.bootstrapIndices);
    out.tests=struct2table(tests);
    % Independent uncertainty via explicit whole-network resamples and sample variance.
    values=[out.pr out.observed out.expected out.deficit out.prepMoveObserved out.prepMoveExpected];
    medians=zeros(cfg.bootstrapDraws,size(values,2));
    for j=1:cfg.bootstrapDraws, medians(j,:)=median(values(out.bootstrapIndices(j,:),:),1); end
    manual=sqrt(sum((medians-sum(medians,1)/cfg.bootstrapDraws).^2,1)/(cfg.bootstrapDraws-1));
    shared=stage2_bootstrap(values,out.bootstrapIndices);
    out.bootstrapError=max(abs(manual-shared.se)); assert(out.bootstrapError<1e-10);
    [time,neuron,target]=ndgrid(1:11,1:200,1:8);
    sentinel=100000*neuron+100*target+time;
    X=stage2_matrix(sentinel); explicit=zeros(88,200);
    for n=1:200, explicit(:,n)=reshape(sentinel(:,n,:),[],1); end
    assert(isequal(X,explicit) && all(floor(X/100000)==1:200,'all'));
    out.sentinelExact=true;
    out.audit=struct('status','PASS','maxIndependentPRError',max(out.independentErrors(:,1)), ...
        'maxIndependentVarianceError',max(out.independentErrors(:,2)), ...
        'maxIndependentAlignmentError',max(out.independentErrors(:,3)), ...
        'maxIndependentBootstrapSEError',out.bootstrapError,'sentinelExact',true, ...
        'minimumSD',min(out.scale,[],'all'),'maximumSD',max(out.scale,[],'all'), ...
        'prepCommonKRange',[min(out.commonK,[],'all') max(out.commonK,[],'all')], ...
        'prepMoveCommonKRange',[min(out.prepMoveCommonK) max(out.prepMoveCommonK)], ...
        'minimumCommonCapturedVariance',min([out.capturedReference(:);out.capturedComparison(:);out.prepMoveCaptured(:)]));
    flat=@(v)reshape(v.',[],1);
    network=repelem((1:10).',8); lambda=repmat(cfg.lambda(:),10,1);
    metrics=table(network,lambda,flat(out.pr),flat(out.observed),flat(out.expected), ...
        flat(out.deficit),repelem(out.minimumK(:,1),8),flat(out.minimumK),flat(out.commonK), ...
        flat(out.capturedReference),flat(out.capturedComparison),'VariableNames', ...
        {'Network','Lambda','PrepPR','Observed','Expected','Deficit','Kref','Klambda','CommonK','ReferenceCaptured','ComparisonCaptured'});
    paired=table((1:10).',out.prepMoveObserved,out.prepMoveExpected, ...
        out.prepMoveMinimumK(:,1),out.prepMoveMinimumK(:,2),out.prepMoveCommonK, ...
        out.prepMoveCaptured(:,1),out.prepMoveCaptured(:,2),out.prSlope,out.deficitSlope, ...
        'VariableNames',{'Network','Observed','Expected','Kprep','Kmove','CommonK','PrepCaptured','MoveCaptured','PRSlope','DeficitSlope'});
    writetable(metrics,fullfile(cfg.resultsRoot,'network_metrics.csv'));
    writetable(paired,fullfile(cfg.resultsRoot,'network_paired_metrics.csv'));
    writetable(out.tests,fullfile(cfg.resultsRoot,'planned_tests.csv'));
    save(fullfile(cfg.resultsRoot,'analysis.mat'),'out','-v7');
    report=struct('status',out.status,'lambda',cfg.lambda,'summary',out.summary, ...
        'prSlopeTest',out.prSlopeTest,'deficitSlopeTest',out.deficitSlopeTest, ...
        'prepMoveTest',out.prepMoveTest,'tests',tests,'audit',out.audit);
    write_json(fullfile(cfg.resultsRoot,'summary.json'),report);
    write_json(fullfile(cfg.resultsRoot,'configuration.json'),cfg);
    disp(out.audit);
end

function write_json(path,value)
    fid=fopen(path,'w'); assert(fid>0); cleanup=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',jsonencode(value,PrettyPrint=true));
end
