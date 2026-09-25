function data=v2_sources(root)
    cfg=v2_paths(root); output=fullfile(cfg.dest,'figure_sources.mat'); assert(~isfile(output));
    a=jsondecode(fileread(fullfile(cfg.dest,'audit.json'))); assert(strcmp(a.status,'PASS'));
    s=load(fullfile(cfg.dest,'summary.mat'),'summary'); r=s.summary; data.summary=r;
    data.selection=jsondecode(fileread(fullfile(cfg.dest,'geometry_selection.json')));
    s=load(fullfile(cfg.dest,'geometry.mat'),'result'); data.geometry=s.result;
    s=load(fullfile(cfg.dest,'readiness.mat'),'result','curves'); data.readiness=s.result; data.readinessCurves=s.curves;
    s=load(fullfile(cfg.paper,'timing','timing.mat'),'result'); data.historicalTiming=s.result;
    s=load(fullfile(cfg.paper,'empirical','targets.mat'),'target'); data.empirical=s.target;
    s=load(fullfile(root,'results','stage_2','current','neural_geometry_r2','analysis.mat'),'out'); data.stage2=s.out;
    data.stage2.deltaPR=data.stage2.pr-data.stage2.pr(:,1);
    data.stage2.deficitPP=100*(data.stage2.expected-data.stage2.observed);
    data.colors=[86 180 233;0 158 115;204 121 167;213 94 0]/255;
    data.targetColors=lines(8); targetCfg=stage_1_gate1_config(root);
    data.targetXY=targetCfg.gate1.radiusM*[cosd(targetCfg.gate1.targetAnglesDeg(:)) sind(targetCfg.gate1.targetAnglesDeg(:))];
    data.representative=cell(1,2);
    for j=1:2
        p=[1 4]; [~,move]=v2_load(cfg,1,2,p(j));
        data.representative{j}=struct('hand',move.hand,'speed',move.speed,'peakMs',move.peakMs,'peak',move.peak);
    end
    data.tests=struct('dispersion',behaviorTest(r.dispersion),'peakSpeed',behaviorTest(squeeze(r.peakSpeed(:,2,[1 4]))));
    network=zeros(120,24); trials=zeros(28800,25); matches=[]; count=0;
    for n=1:10
        for v=1:5
            policies=[1 4]; if v==2, policies=1:4; end
            for p=policies
                count=count+1; s=load(fullfile(cfg.raw,sprintf('analysis_n%02d_v%d_p%d.mat',n,v,p)),'result'); z=s.result; qc=z.qc;
                network(count,:)=[n cfg.pairs(v,:) p r.pr(n,v,p) r.observed(n,v,p) r.expected(n,v,p) r.deficit(n,v,p) r.k(n,v) ...
                    r.convergence(n,v,p) r.r2(n,v,p) r.shuffle(n,v,p) r.matched(n,v,p) r.peakSpeed(n,v,p) r.endpoint(n,v,p) r.separation(n,v,p) ...
                    qc.nearZero qc.missingWindow qc.boundaryPeak qc.multiPeak z.convergence.undefined reshape(r.pc75(n,v,p,:),1,2) z.predictionEvaluable];
                for j=1:240
                    q=ceil(j/30); fold=z.folds.outer(j); cr=z.convergence;
                    trials((count-1)*240+j,:)=[n cfg.pairs(v,:) p q j-(q-1)*30 fold cr.k(q,fold) cr.capture(q,fold) cr.before(q,fold) ...
                        cr.precue(j) cr.prego(j) cr.ratio(j) cr.c(j) ~isfinite(cr.c(j)) z.movement.moMs(j) z.movement.peakMs(j) ...
                        z.movement.peak(j) z.movement.nearZero(j) z.movement.missingWindow(j) z.movement.boundaryPeak(j) z.movement.multiPeakCount(j) cr.guard(q,fold) z.peakPosition(j,:)];
                end
            end
        end
        b=r.behavior{n};
        for q=1:8
            pairs=[b.indices{q,1}(:) b.indices{q,2}(:)];
            matches=[matches;repmat([n q],size(pairs,1),1) pairs]; %#ok<AGROW>
        end
    end
    v2_csv(fullfile(cfg.dest,'network_metrics.csv'),{'network','s_init','s_temporal','policy','PR','observedPct','expectedPct','deficitPP','K95','C','R2','shuffleR2','matchedR2','peakSpeedMps','endpointRmsM','targetSeparationScatter','nearZero','missingWindow','boundaryPeak','multipleLargePeak','undefinedC','prepPC75','movePC75','predictionEvaluable'},network);
    v2_csv(fullfile(cfg.dest,'trial_metrics.csv'),{'network','s_init','s_temporal','policy','target','trial','fold','K95','capture','beforeCapture','d_precue','d_prego','ratio','C','undefinedC','moMs','peakMs','peakSpeedMps','nearZero','missingWindow','boundaryPeak','largePeakCount','denominatorGuard','peakPositionX_M','peakPositionY_M'},trials);
    v2_csv(fullfile(cfg.dest,'behavior_matching.csv'),{'network','target','IntactTrialIndex','BlockTrialIndex'},matches);
    for name={'map','ensemble'}
        t=data.geometry.(name{1}); v2_csv(fullfile(cfg.dest,['calibration_' name{1} '_fullprecision.csv']),t.Properties.VariableNames,table2array(t));
    end
    paired=zeros(50,9);
    for n=1:10
        for v=1:5
            paired((n-1)*5+v,:)=[n cfg.pairs(v,:) r.deltaC(n,v) r.deltaR2(n,v) r.lossPct(n,v) isfinite(r.lossPct(n,v)) r.r2(n,v,1) r.r2(n,v,4)];
        end
    end
    v2_csv(fullfile(cfg.dest,'paired_noise_effects.csv'),{'network','s_init','s_temporal','deltaC','deltaR2','relativeR2LossPct','relativeLossDefined','R2Intact','R2Block'},paired);
    save(output,'data','-v7.3'); paper_json(fullfile(cfg.dest,'behavior_statistics.json'),data.tests);
    paper_json(fullfile(cfg.dest,'sources.json'),struct('status','PASS','networkRows',count,'trialRows',size(trials,1),'matchingRows',size(matches,1)));
end

function out=behaviorTest(values)
    paired=all(isfinite(values),2); difference=values(paired,2)-values(paired,1);
    out=struct('n',sum(paired),'networkMask',paired,'difference',difference,'alpha',.05,'tail','two-sided','unit','network');
    if numel(difference)<3
        out.test='unevaluable: fewer than three paired networks'; out.p=NaN; out.adP=NaN; return
    end
    [reject,out.adP]=adtest(difference,'Alpha',.05); out.adReject=reject;
    if reject
        [out.p,~,out.statistics]=signrank(values(paired,1),values(paired,2),'tail','both'); out.test='two-sided Wilcoxon signed-rank';
    else
        [~,out.p,out.confidenceInterval,out.statistics]=ttest(values(paired,2),values(paired,1),'Tail','both'); out.test='two-sided paired t';
    end
    out.corrected=false; out.family='one predeclared paired comparison for this separate behavioral metric';
end
