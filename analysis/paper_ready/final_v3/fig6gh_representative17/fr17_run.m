function receipt=fr17_run(root)
    % No simulation, scientific refitting or inferential calculations.
    addpath(fullfile(root,'analysis/paper_ready'),fullfile(root,'analysis/paper_ready/final_v2'));
    base='fig6gh_representative17'; dest=fullfile(root,'results/paper_ready/final_v3',base);
    if ~isfolder(dest), mkdir(dest); end
    docs=fullfile(root,'docs/paper_ready/final_v3',base); plots=fullfile(root,'plots/paper_ready/final_v3',base);
    cache=fullfile(root,'results/paper_ready/cache',base);
    files=dir(fullfile(root,'analysis/paper_ready/final_v3',base,'*.m')); issues={};
    for file=files.'
        found=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(found), issues{end+1}=struct('file',file.name,'issues',found); end %#ok<AGROW>
    end
    paper_json(fullfile(docs,'code_analyzer_complete.json'),struct('files',numel(files),'issues',{issues})); assert(isempty(issues));
    z=load(fullfile(root,'results/paper_ready/cache/fig6fgh_highrms14/display_sources.mat'),'d'); d=z.d;
    d.task='FIG6GH-SPATIALLY-REPRESENTATIVE-17'; d.selectedTarget=6; q=6;
    assert(d.selectedNetwork==8 && all(d.attempt30(q,:)<=500) && all(d.successes(q,:)==30));
    d.displayIDs=cell(1,2); d.groups=cell(1,2); d.draws=cell(1,2); d.selectionSeeds=[170801 170802];
    selectionRows=[]; strataRows=[];
    for p=1:2
        c=d.condition{p}; ids=(q-1)*30+(1:30);
        [loc,groups,draws]=fr17_select(c.peakXY(ids,:),c.attemptID(ids),d.selectionSeeds(p));
        chosen=ids(loc).'; d.displayIDs{p}=chosen; d.groups{p}=groups; d.draws{p}=draws;
        for k=1:10
            selectionRows=[selectionRows;8 q p k chosen(k) c.attemptID(chosen(k)) d.selectionSeeds(p) draws(k)]; %#ok<AGROW>
            for j=1:3
                tr=ids(groups(k,j));
                strataRows=[strataRows;8 q p k j tr c.attemptID(tr) c.peakXY(tr,:) tr==chosen(k)]; %#ok<AGROW>
            end
        end
    end
    % Freeze both selections on disk BEFORE reading speeds for subset evaluation.
    v2_csv(fullfile(dest,'selection_frozen_before_speed.csv'),{'network','target','condition','stratum','poolIndex','attemptID','selectionSeed','drawWithinStratum'},selectionRows);
    v2_csv(fullfile(dest,'spatial_strata.csv'),{'network','target','condition','stratum','member','poolIndex','attemptID','peakX_M','peakY_M','selected'},strataRows);
    medRows=[]; thinRows=[]; pathRows=[]; allRows=[]; idRows=[]; summaryRows=[];
    for p=1:2
        c=d.condition{p}; ids=(q-1)*30+(1:30); chosen=d.displayIDs{p};
        [c.rawMedian(:,q),c.fullSmoothMedian(:,q),c.nActive(:,q),c.cutoffMs(q),c.supportEndMs(q),c.medianSpeed(:,q)]=fr17_median(c.alignedSpeed(:,chosen));
        d.condition{p}=c;
        medRows=[medRows;repmat(p,600,1) d.timesMs c.nActive(:,q) c.rawMedian(:,q) c.fullSmoothMedian(:,q) c.medianSpeed(:,q) repmat([c.cutoffMs(q) c.supportEndMs(q)],600,1)]; %#ok<AGROW>
        for j=1:10
            tr=chosen(j);
            idRows=[idRows;8 q p j tr c.attemptID(tr) c.seed(tr) c.pathRMS(tr) c.moMs(tr) c.endMs(tr) c.peakSpeed(tr)]; %#ok<AGROW>
            thinRows=[thinRows;repmat([p c.attemptID(tr)],600,1) d.timesMs c.alignedSpeed(:,tr)]; %#ok<AGROW>
            pathRows=[pathRows;repmat([8 q p c.attemptID(tr)],600,1) d.timesMs 100*c.xy(:,:,tr)]; %#ok<AGROW>
        end
        for j=1:30
            tr=ids(j);
            allRows=[allRows;8 q p tr c.attemptID(tr) c.seed(tr) c.peakMs(tr) c.peakSpeed(tr) 100*c.peakXY(tr,:) c.distanceCM(j,q) ismember(tr,chosen) c.endMs(tr)]; %#ok<AGROW>
        end
        for n=[10 30]
            ix=chosen; if n==30, ix=ids; end
            pts=100*c.peakXY(ix,:); center=median(pts,1); dist=sqrt(sum((pts-center).^2,2)); covariance=cov(pts,1);
            summaryRows=[summaryRows;8 q p n median(c.peakSpeed(ix)) sqrt(mean(dist.^2)) center covariance(1,1) covariance(2,2) covariance(1,2)]; %#ok<AGROW>
        end
    end
    d.histEdgesCM=0:.5:ceil(max(allRows(:,11))/.5)*.5; d.histCounts=zeros(numel(d.histEdgesCM)-1,2);
    for p=1:2, d.histCounts(:,p)=histcounts(d.condition{p}.distanceCM(:,q),d.histEdgesCM).'; end
    v2_csv(fullfile(dest,'Fig6gh_selected_trials.csv'),{'network','target','condition','stratum','poolIndex','attemptID','simulationSeed','pathRMS_M','moMs','entryMs','peakMps'},idRows);
    v2_csv(fullfile(dest,'Fig6g_median_support.csv'),{'condition','timeFromMOms','nActive','rawMedianMps','fullSmoothedMedianMps','displayedMedianMps','cutoffMs','supportEndMs'},medRows);
    v2_csv(fullfile(dest,'Fig6g_raw_thin_traces.csv'),{'condition','attemptID','timeFromMOms','unsmoothedSpeedMps'},thinRows);
    v2_csv(fullfile(dest,'Fig6h_display_paths.csv'),{'network','target','condition','attemptID','timeFromGOms','xCM','yCM'},pathRows);
    v2_csv(fullfile(dest,'Fig6h_all30_inset.csv'),{'network','target','condition','poolIndex','attemptID','seed','peakMs','peakMps','xCM','yCM','distanceCM','displayed','entryMs'},allRows);
    v2_csv(fullfile(dest,'Fig6h_histogram_counts.csv'),{'lowerCM','upperCM','IntactCount','BlockCount'},[d.histEdgesCM(1:end-1).' d.histEdgesCM(2:end).' d.histCounts]);
    v2_csv(fullfile(dest,'illustration_descriptives_NOT_MANUSCRIPT_STATS.csv'),{'network','target','condition','count','medianPeakMps','RMS_toOwnMedianCM','medianX_CM','medianY_CM','varianceX_CM2','varianceY_CM2','covarianceXY_CM2'},summaryRows);
    selection=struct('network',8,'target',q,'sameTrialsGH',true,'sampling','One spatially stratified draw; no speed criterion in selection', ...
        'seeds',d.selectionSeeds,'IntactIDs',idRows(1:10,6).','BlockIDs',idRows(11:20,6).','medianCount',10,'insetCount',30, ...
        'cutoffsMs',[d.condition{1}.cutoffMs(q) d.condition{2}.cutoffMs(q)], ...
        'supportEndsMs',[d.condition{1}.supportEndMs(q) d.condition{2}.supportEndMs(q)], ...
        'selectedMedianPeakMps',summaryRows([1 3],5).','all30MedianPeakMps',summaryRows([2 4],5).', ...
        'selectedRMSspreadCM',summaryRows([1 3],6).','all30RMSspreadCM',summaryRows([2 4],6).');
    paper_json(fullfile(dest,'selection.json'),selection);
    receipt=fr17_audit(root,d,z.d,dest,plots,false);
    assert(~isfolder(cache)); mkdir(cache); save(fullfile(cache,'display_sources.mat'),'d','-v7.3');
    % Failure here preserves frozen selection/results for review, never draws again.
    assert(selection.selectedMedianPeakMps(2)<selection.selectedMedianPeakMps(1),'Report subset speed result before any g fallback.');
    receipt.g=fr17_render_g(d,plots); receipt.h=fr17_render_h(d,plots);
    receipt.figures=fr17_audit(root,d,z.d,dest,plots,true);
    receipt.status='PASS'; paper_json(fullfile(dest,'validation.json'),receipt);
    disp(selection); disp(receipt);
end
