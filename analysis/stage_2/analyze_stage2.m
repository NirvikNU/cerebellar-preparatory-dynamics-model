function analyze_stage2(cfg)
    root = cfg.resultsRoot;
    assert(isfile(fullfile(root,'simulation_audit.json')),'Simulation validation receipt missing.');
    out = struct('cfg',cfg);
    out.pr = zeros(10,8,2);
    out.captured15 = zeros(10,8,2);
    out.observed = zeros(10,8);
    out.expected = zeros(10,1);
    out.prepMove = zeros(10,1);
    out.error = zeros(10,501,8);
    out.stateError = zeros(10,501,8);
    out.effort = zeros(10,8);
    out.perturbation = zeros(10,501,2);
    out.perturbationNorm = zeros(10,800);
    out.activeChange = zeros(10,800);
    out.scale = zeros(10,200);
    out.null = zeros(1000,10);
    out.careResidual = zeros(10,8);
    out.maxPole = zeros(10,8);
    out.gainNorm = zeros(10,8);
    out.fixedPointError = zeros(10,8);
    out.independentErrors = zeros(10,3);
    currentHash = sha256_file(fullfile(cfg.projectRoot,'config','stage_2_config.m'));
    for member = 1:10
        saved = load(fullfile(cfg.cacheRoot,sprintf('network_%02d.mat',member)),'net');
        net = saved.net;
        assert(net.configHash==currentHash);
        pop = stage2_population(net.rates,cfg,member);
        out.pr(member,:,:) = pop.pr;
        out.captured15(member,:,:) = pop.captured15;
        out.observed(member,:) = pop.observed;
        out.expected(member) = pop.expected;
        out.prepMove(member) = pop.prepMove;
        out.null(:,member) = pop.null;
        out.scale(member,:) = pop.scale;
        raw = squeeze(mean(net.sourceCost,2));
        out.error(member,:,:) = 100*raw/raw(1,1);
        rawState = squeeze(mean(net.stateCost,2));
        out.stateError(member,:,:) = rawState;
        out.effort(member,:) = net.effort;
        out.perturbation(member,:,:) = net.perturbation.squaredError;
        out.perturbationNorm(member,:) = net.perturbation.initialNorm;
        out.activeChange(member,:) = net.perturbation.initialActiveChangeFraction;
        out.independentErrors(member,:) = [pop.svdPRError pop.svdCapturedError pop.directAlignmentError];
        for l = 1:8
            ctl = net.controller{l};
            out.careResidual(member,l) = ctl.careRelativeResidual;
            out.maxPole(member,l) = ctl.maxPole;
            out.gainNorm(member,l) = norm(ctl.K,'fro');
            out.fixedPointError(member,l) = ctl.fixedPointError;
        end
        if member==1
            out.demoHand = net.demoHand;
            out.targetHand = net.targetHand;
            angles=[-90 -45 0 45 90 135 180 225];
            targetXY=.1*[cosd(angles);sind(angles)].';
            out.demoEndpointErrorM=zeros(4,8);
            for d=1:4
                h=net.demoHand{d};
                xy=squeeze(h(end,[1 3],:)-h(1,[1 3],:)).';
                out.demoEndpointErrorM(d,:)=sqrt(sum((xy-targetXY).^2,2)).';
            end
        end
    end
    out.deficit = out.expected-out.observed;
    out.error200 = squeeze(out.error(:,201,:));
    bs = RandStream('mt19937ar','Seed',cfg.bootstrapSeed);
    out.bootstrapIndices = randi(bs,10,cfg.bootstrapDraws,10);
    fields = {'pr','captured15','observed','expected','prepMove','deficit', ...
        'error','error200','perturbation','effort','gainNorm'};
    for f = 1:numel(fields)
        name = fields{f};
        out.summary.(name) = stage2_bootstrap(out.(name),out.bootstrapIndices);
    end
    allTests = struct([]);
    familyNames = {'Prep PR: lambda-reference','Motor error 200ms: lambda-reference', ...
        'Prep alignment: observed-expected'};
    for family = 1:3
        p = zeros(1,7);
        for l = 2:8
            if family==1
                difference = out.pr(:,l,1)-out.pr(:,1,1);
            elseif family==2
                difference = out.error200(:,l)-out.error200(:,1);
            else
                difference = out.observed(:,l)-out.expected;
            end
            test = stage2_signflip(difference,out.bootstrapIndices);
            test.family = familyNames{family};
            test.lambda = cfg.lambda(l);
            test.q = NaN;
            p(l-1) = test.p;
            allTests = [allTests;test]; %#ok<AGROW>
        end
        q = stage2_bh(p);
        for l = 1:7, allTests((family-1)*7+l).q=q(l); end
    end
    x = log10(cfg.lambda(:));
    slopes = [ones(8,1) x]\out.pr(:,:,1).';
    out.prSlope = slopes(2,:).';
    slopes = [ones(8,1) x]\out.deficit.';
    out.deficitSlope = slopes(2,:).';
    out.prSlopeTest = stage2_signflip(out.prSlope,out.bootstrapIndices);
    out.deficitSlopeTest = stage2_signflip(out.deficitSlope,out.bootstrapIndices);
    out.prepMoveTest = stage2_signflip(out.prepMove-out.expected,out.bootstrapIndices);
    out.tests = struct2table(allTests);
    writetable(out.tests,fullfile(root,'planned_tests.csv'));
    network = repelem((1:10).',8);
    lambda = repmat(cfg.lambda(:),10,1);
    flatten = @(v) reshape(v.',[],1);
    values = table(network,lambda,flatten(out.pr(:,:,1)),flatten(out.pr(:,:,2)), ...
        flatten(out.captured15(:,:,1)),flatten(out.captured15(:,:,2)), ...
        flatten(out.observed),repelem(out.expected,8),flatten(out.deficit), ...
        flatten(out.error200),flatten(out.effort),flatten(out.gainNorm), ...
        'VariableNames',{'Network','Lambda','PrepPR','MovePR','PrepCaptured15', ...
        'MoveCaptured15','ObservedAlignment','ExpectedAlignment','AlignmentDeficit', ...
        'MotorError200Percent','FeedbackEffort','GainFrobeniusNorm'});
    writetable(values,fullfile(root,'network_metrics.csv'));
    paired = table((1:10).',out.prepMove,out.expected,out.prSlope,out.deficitSlope, ...
        'VariableNames',{'Network','PrepMoveObserved','Expected','PRSlope','DeficitSlope'});
    writetable(paired,fullfile(root,'network_paired_metrics.csv'));
    distribution = table(repelem((1:10).',800),repmat(repelem((1:8).',100),10,1), ...
        repmat((1:100).',80,1),flatten(out.perturbationNorm),flatten(out.activeChange), ...
        'VariableNames',{'Network','Target','Trial','InitialNorm','InitialActiveChangeFraction'});
    writetable(distribution,fullfile(root,'perturbation_initial_checks.csv'));
    % Independent uncertainty audit: explicitly loop whole-network resamples.
    auditValues = [out.pr(:,:,1) out.observed out.deficit out.prepMove out.expected];
    independentMedians = zeros(cfg.bootstrapDraws,size(auditValues,2));
    for draw = 1:cfg.bootstrapDraws
        independentMedians(draw,:) = median(auditValues(out.bootstrapIndices(draw,:),:),1);
    end
    meanB = sum(independentMedians,1)/cfg.bootstrapDraws;
    independentSE = sqrt(sum((independentMedians-meanB).^2,1)/(cfg.bootstrapDraws-1));
    shared = stage2_bootstrap(auditValues,out.bootstrapIndices);
    audit = struct('status','PASS','maxIndependentPRError',max(out.independentErrors(:,1)), ...
        'maxIndependentCapturedVarianceError',max(out.independentErrors(:,2)), ...
        'maxIndependentAlignmentError',max(out.independentErrors(:,3)), ...
        'maxIndependentBootstrapSEError',max(abs(independentSE-shared.se)), ...
        'minimumPrep15Variance',min(out.captured15(:,:,1),[],'all'), ...
        'minimumMove15Variance',min(out.captured15(:,:,2),[],'all'), ...
        'allEffortStepsDecrease',all(diff(out.effort,1,2)<=0,'all'), ...
        'effortIncreasingSteps',nnz(diff(out.effort,1,2)>0), ...
        'maximumCAREResidual',max(out.careResidual,[],'all'), ...
        'maximumFixedPointError',max(out.fixedPointError,[],'all'), ...
        'maximumClosedLoopPole',max(out.maxPole,[],'all'), ...
        'allSelfAlignmentOne',max(abs(out.observed(:,1)-1))<1e-10, ...
        'floorClampedNeuronCounts',sum(out.scale==cfg.floor,2), ...
        'initialNormQuantiles',quantile(out.perturbationNorm(:),[0 .025 .5 .975 1]), ...
        'activeChangeFractionQuantiles',quantile(out.activeChange(:),[0 .025 .5 .975 1]));
    assert(audit.maxIndependentBootstrapSEError<1e-10);
    out.audit = audit;
    out.status = 'COMPUTED / VALIDATED; NOT SCIENTIFICALLY ACCEPTED';
    save(fullfile(root,'analysis.mat'),'out','-v7');
    write_json(fullfile(root,'analysis_audit.json'),audit);
    report = struct('status',out.status,'lambda',cfg.lambda,'summary',out.summary, ...
        'prSlopeTest',out.prSlopeTest,'deficitSlopeTest',out.deficitSlopeTest, ...
        'prepMoveTest',out.prepMoveTest,'demoEndpointErrorM',out.demoEndpointErrorM,'audit',audit);
    % Long time courses remain in the compact MAT, not duplicated in JSON.
    report.summary = rmfield(report.summary,{'error','perturbation'});
    write_json(fullfile(root,'summary.json'),report);
    disp(audit);
end

function write_json(path,value)
    fid=fopen(path,'w'); assert(fid>0); clean=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',jsonencode(value,PrettyPrint=true));
end
