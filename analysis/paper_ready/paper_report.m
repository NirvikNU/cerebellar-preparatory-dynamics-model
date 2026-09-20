function report = paper_report(root)
    dest=fullfile(root,'results','paper_ready');
    s=load(fullfile(dest,'timing','timing.mat'),'result'); timing=s.result;
    s=load(fullfile(dest,'geometry.mat'),'result'); grid=s.result;
    s=load(fullfile(dest,'controls.mat'),'result'); controls=s.result;
    audit=jsondecode(fileread(fullfile(dest,'independent_audit.json')));
    point=grid.map(grid.map.gridIndex==grid.selectedIndex,:);
    report=struct('status','INDEPENDENTLY_VALIDATED_SCIENTIFIC_REVIEW_PENDING','lambda',grid.lambda, ...
        'alpha',point.alpha(1),'betaNormalized',point.betaNormalized(1),'gridIndex',grid.selectedIndex, ...
        'loss',grid.loss(grid.selectedIndex),'commonFeasible',nnz(grid.commonFeasible),'target',grid.target, ...
        'timing',timing.ensembleMedian,'audit',audit,'predictionRun',false);
    report.selected=stage2_bootstrap([point.prIntact point.prBlock point.observed point.expected point.deltaPR point.deficit],controls.indices);
    report.attainablePRDelta=[min(grid.deltaPR(grid.commonFeasible)),max(grid.deltaPR(grid.commonFeasible))];
    report.attainableDeficit=[min(grid.deficit(grid.commonFeasible)),max(grid.deficit(grid.commonFeasible))];
    report.capture15=[min(point.captureIntact15) max(point.captureIntact15);min(point.captureBlock15) max(point.captureBlock15)];
    report.adaptive=stage2_bootstrap([point.observedAdaptive point.expectedAdaptive point.expectedAdaptive-point.observedAdaptive],controls.indices);
    report.selectedFields={'PR_Intact','PR_Block','Observed','Expected','deltaPR','deficit'};
    report.selectedCommonK=point.commonK.';
    report.selectedEffect=[grid.deltaPR(grid.selectedIndex) grid.deficit(grid.selectedIndex)];
    report.relativeEffectError=(report.selectedEffect-[grid.target.deltaPR grid.target.alignmentDeficit])./abs([grid.target.deltaPR grid.target.alignmentDeficit]);
    report.controlAudit=jsondecode(fileread(fullfile(dest,'control_audit.json')));
    assert(strcmp(report.controlAudit.status,'PASS'));
    report.noiseSummary=controls.summary.noise; report.policySummary=controls.summary.policy;
    report.policyNames=controls.policyNames; report.noiseLevels=controls.levels;
    report.noiseBoundFailures=nnz(controls.noiseBounds(:,:,:,4)==0);
    report.primaryPolicyBoundFailures=nnz(~cellfun(@(q)q.prepBounds,controls.QC));
    report.qc=controls.QC;
    report.nullMCSE=zeros(10,2); report.nullMCSEColumns={'K15','adaptive_common_K'};
    row=0; trials=cell(9600,1); targets=cell(320,1); tr=0;
    for n=1:10
        draws=load(fullfile(dest,'cache',sprintf('grid_n%02d.mat',n)),'nullDraws');
        K=[15 point.commonK(point.network==n)];
        for kk=1:2
            v=draws.nullDraws{K(kk)}; assert(numel(v)==10000);
            report.nullMCSE(n,kk)=std(v)/sqrt(numel(v));
            independentSE=sqrt(sum((v-mean(v)).^2)/(numel(v)-1)/numel(v));
            assert(abs(independentSE-report.nullMCSE(n,kk))<1e-12);
        end
        s=load(fullfile(dest,'cache',sprintf('controls_n%02d.mat',n)),'moves');
        for p=1:4
            m=s.moves{p};
            for q=1:8
                ix=(q-1)*30+(1:30); tr=tr+1;
                targets{tr}=table(n,p,q,m.endpointRmsByTarget(q)*1000,median(m.moMs(ix)),median(m.peakMs(ix)), ...
                    median(m.peak(ix)),sum(m.nearZero(ix)),sum(m.boundaryPeak(ix)),sum(m.missingWindow(ix)), ...
                    'VariableNames',{'network','policy','target','endpointRmsMM','medianMOms','medianPeakMs','medianPeakSpeedMps','nearZero','boundaryPeak','missingWindow'});
                for t=1:30
                    j=ix(t); row=row+1;
                    trials{row}=table(n,p,q,t,m.moMs(j),m.peakMs(j),m.peak(j),m.nearZero(j),m.boundaryPeak(j),m.missingWindow(j),m.multiPeakCount(j), ...
                        'VariableNames',{'network','policy','target','trial','MOms','peakMs','peakMps','nearZero','boundaryPeak','missingWindow','numberLargePeaks'});
                end
            end
        end
    end
    writetable(vertcat(trials{:}),fullfile(dest,'movement_trial_qc.csv'));
    writetable(vertcat(targets{:}),fullfile(dest,'movement_target_qc.csv'));
    rows=cell(100,1); row=0;
    for n=1:10
        for kind=1:2
            for k=1:5
                row=row+1; v=reshape(controls.noise(n,kind,k,:),1,6); b=reshape(controls.noiseBounds(n,kind,k,:),1,5);
                rows{row}=array2table([n kind controls.levels(k) v b], ...
                    'VariableNames',{'network','source','amplitude','PR','observed','expected','deficit','normalizedResidualVariance','rawResidualVariance','rateMax','stateMax','inputMax','boundsPass','numericalRank'});
            end
        end
    end
    writetable(vertcat(rows{:}),fullfile(dest,'noise_controls.csv'));
    paper_json(fullfile(dest,'REPORT.json'),report);
end
