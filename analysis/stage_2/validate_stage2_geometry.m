function receipt = validate_stage2_geometry(cfg)
    % Post-analysis validation only, including independent statistics and preservation.
    saved=load(fullfile(cfg.resultsRoot,'analysis.mat'),'out'); o=saved.out;
    assert(isequal(o.cfg,cfg) && isequal(cfg.lambda,[.1 .2 .5 1 2 5 10 100]));
    assert(cfg.nullDraws==1000 && cfg.bootstrapDraws==10000);
    assert(all(o.scale>0,'all') && all(isfinite(o.scale),'all'));
    assert(max(abs(o.observed(:,1)-1))<1e-10);
    assert(isequal(o.commonK,max(o.minimumK(:,1),o.minimumK)));
    assert(isequal(o.prepMoveCommonK,max(o.prepMoveMinimumK,[],2)));
    assert(all([o.capturedReference(:);o.capturedComparison(:);o.prepMoveCaptured(:)]>.95));
    % Independent exact tests: explicit bit-pattern enumeration, not the shared helper.
    tests=o.tests;
    difference=[o.pr(:,2:8)-o.pr(:,1) o.observed(:,2:8)-o.expected(:,2:8) ...
        o.prSlope o.deficitSlope o.prepMoveObserved-o.prepMoveExpected];
    exact=zeros(1,size(difference,2));
    manualSE=exact;
    for j=1:size(difference,2)
        d=difference(:,j); observed=abs(sum(d)/10); extreme=0;
        for pattern=0:1023
            signs=ones(10,1);
            for n=1:10, if bitget(pattern,n)==0, signs(n)=-1; end, end
            extreme=extreme+(abs(sum(signs.*d)/10)>=observed-1e-12*max(1,observed));
        end
        exact(j)=extreme/1024;
        medians=zeros(cfg.bootstrapDraws,1);
        for b=1:cfg.bootstrapDraws, medians(b)=median(d(o.bootstrapIndices(b,:))); end
        manualSE(j)=sqrt(sum((medians-mean(medians)).^2)/(cfg.bootstrapDraws-1));
    end
    expectedP=[tests.p.' o.prSlopeTest.p o.deficitSlopeTest.p o.prepMoveTest.p];
    expectedSE=[tests.medianDifferenceSE.' o.prSlopeTest.medianDifferenceSE ...
        o.deficitSlopeTest.medianDifferenceSE o.prepMoveTest.medianDifferenceSE];
    assert(isequal(exact,expectedP));
    assert(max(abs(manualSE-expectedSE))<1e-10);
    for f=1:2
        ix=(f-1)*7+(1:7); p=tests.p(ix); independentQ=zeros(7,1);
        for j=1:7
            eligible=p>=p(j); candidates=p(eligible);
            adjusted=zeros(size(candidates));
            for k=1:numel(candidates), adjusted(k)=7*candidates(k)/sum(p<=candidates(k)); end
            independentQ(j)=min(1,min(adjusted));
        end
        assert(max(abs(independentQ-tests.q(ix)))<1e-10);
    end
    C=diag([ones(1,5) zeros(1,15)]); I=eye(20);
    assert(trace(I(:,1:5).'*C*I(:,1:5))/5==1);
    assert(trace(I(:,6:10).'*C*I(:,6:10))/5==0);
    null=stage2_null(eye(20),C,5,5,1000,20260910);
    assert(abs(mean(null)-.25)<.03);
    before=readtable(fullfile(cfg.originalResultsRoot,'protected_before.csv'),'TextType','string');
    for j=1:height(before)
        assert(sha256_file(fullfile(cfg.projectRoot,before.relative_path(j)))==before.sha256(j));
    end
    % Original tracked Stage-2 content not authorized for replacement is checked by Git.
    protected={'src/stage_2','config/stage_2_config.m','results/stage_2/current/analysis.mat', ...
        'plots/stage_2/png/result_1_preparation_trajectories.png', ...
        'plots/stage_2/fig/result_1_preparation_trajectories.fig', ...
        'plots/stage_2/png/result_2_controller_operation.png', ...
        'plots/stage_2/fig/result_2_controller_operation.fig'};
    for j=1:numel(protected)
        command=sprintf('git -C "%s" diff --exit-code %s -- "%s"', ...
            cfg.projectRoot,cfg.startCheckpoint,protected{j});
        [status,output]=system(command); assert(status==0,'%s',output);
    end
    stems={'result_3_prep_move_alignment','diagnostic_1_pr_lambda','diagnostic_2_alignment_lambda'};
    for j=1:3
        f=openfig(fullfile(cfg.plotsFigRoot,[stems{j} '.fig']),'invisible');
        ax=findall(f,'Type','axes'); assert(all(arrayfun(@(a)a.FontSize==16,ax)));
        assert(~isempty(findall(f,'Type','errorbar'))); drawnow; close(f);
        pixels=imread(fullfile(cfg.plotsPngRoot,[stems{j} '.png']));
        assert(size(pixels,1)>500 && size(pixels,2)>500 && std(double(pixels(:)))>1);
    end
    changed={'run_stage_2.m','config/stage_2_geometry_config.m', ...
        'analysis/stage_2/preflight_stage2_geometry.m', ...
        'analysis/stage_2/stage2_geometry_population.m','analysis/stage_2/analyze_stage2_geometry.m', ...
        'analysis/stage_2/validate_stage2_geometry.m','figures/stage_2/create_stage2_geometry_figures.m'};
    issues=struct('file',{},'line',{},'message',{});
    for j=1:numel(changed)
        path=fullfile(cfg.projectRoot,changed{j});
        assert(isempty(regexp(fileread(path),'(?m)^\s*%%','once')));
        found=checkcode(path,'-id');
        for k=1:numel(found)
            issues(end+1)=struct('file',changed{j},'line',found(k).line,'message',found(k).message); %#ok<AGROW>
        end
    end
    receipt=struct('status','PASS','protectedStage1FilesUnchanged',height(before), ...
        'controllerAndResultsFigures12Unchanged',true,'revisedFIGsReopened',3,'revisedPNGsReopened',3, ...
        'independentExactTests',17,'maxPairedBootstrapSEError',max(abs(manualSE-expectedSE)), ...
        'independentBHFamilies',2,'syntheticIsotropicNullMean',mean(null), ...
        'codeAnalyzerFiles',numel(changed),'codeAnalyzerIssues',{issues},'analysisAudit',o.audit);
    if ~isempty(issues), receipt.status='STOP: Code Analyzer issues'; end
    fid=fopen(fullfile(cfg.resultsRoot,'final_validation.json'),'w'); assert(fid>0);
    cleanup=onCleanup(@()fclose(fid)); fprintf(fid,'%s\n',jsonencode(receipt,PrettyPrint=true));
    disp(receipt); if ~isempty(issues), disp(struct2table(issues)); end
    assert(isempty(issues),'Code Analyzer must pass before checkpoint.');
end
