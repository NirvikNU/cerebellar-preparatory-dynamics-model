function receipt=fr23_run(root)
    % No simulation, scientific refitting or inferential calculations.
    addpath(fullfile(root,'analysis/paper_ready'),fullfile(root,'analysis/paper_ready/final_v2'));
    base='fig6gh_fifteen23'; dest=fullfile(root,'results/paper_ready/final_v3',base);
    assert(~isfolder(dest),'Never overwrite a completed or partial successor');
    docs=fullfile(root,'docs/paper_ready/final_v3',base); plots=fullfile(root,'plots/paper_ready/final_v3',base);
    priorFolder=fullfile(root,'results/paper_ready/final_v3/fig6gh_representative17');
    files=dir(fullfile(root,'analysis/paper_ready/final_v3',base,'*.m')); issues={};
    for file=files.'
        found=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(found), issues{end+1}=struct('file',file.name,'issues',found); end %#ok<AGROW>
    end
    paper_json(fullfile(docs,'code_analyzer_complete.json'),struct('files',numel(files),'issues',{issues})); assert(isempty(issues));
    z=load(fullfile(root,'results/paper_ready/cache/fig6gh_representative17/display_sources.mat'),'d'); d=z.d; mkdir(dest);
    d.task='FIG6GH-FIFTEEN23'; d.selectedTarget=6; q=6;
    assert(d.selectedNetwork==8 && all(d.attempt30(q,:)<=500) && all(d.successes(q,:)==30));
    d.priorDisplayIDs=d.displayIDs; d.addedStrata=cell(1,2); d.addedDraws=cell(1,2);
    selectionRows=[]; strataRows=[];
    previous=readmatrix(fullfile(priorFolder,'selection_frozen_before_speed.csv'));
    for p=1:2
        c=d.condition{p}; ids=(q-1)*30+(1:30); prior=d.priorDisplayIDs{p}; groups=d.groups{p};
        assert(isequal(previous(previous(:,3)==p,5),prior));
        [local,strata,draws]=fr23_extend(groups,prior-(q-1)*30,d.selectionSeeds(p));
        chosen=ids(local).'; d.displayIDs{p}=chosen; d.addedStrata{p}=strata; d.addedDraws{p}=draws;
        for k=1:15
            stratum=find(any(groups==local(k),2));
            selectionRows=[selectionRows;8 q p k chosen(k) c.attemptID(chosen(k)) d.selectionSeeds(p) stratum k<=10]; %#ok<AGROW>
        end
        for k=1:10
            for j=1:3
                tr=ids(groups(k,j));
                strataRows=[strataRows;8 q p k j tr c.attemptID(tr) c.peakXY(tr,:) ismember(tr,chosen) ismember(tr,prior)]; %#ok<AGROW>
            end
        end
    end
    % Freeze the extension before subset speed inspection, with no reroll/fallback.
    v2_csv(fullfile(dest,'selection_frozen_before_speed.csv'),{'network','target','condition','displayRank','poolIndex','attemptID','selectionSeed','sourceStratum','retainedOriginal'},selectionRows);
    v2_csv(fullfile(dest,'spatial_strata.csv'),{'network','target','condition','stratum','member','poolIndex','attemptID','peakX_M','peakY_M','selected15','selectedOriginal10'},strataRows);
    medRows=[]; thinRows=[]; pathRows=[]; allRows=[]; idRows=[]; summaryRows=[];
    for p=1:2
        c=d.condition{p}; ids=(q-1)*30+(1:30); chosen=d.displayIDs{p};
        [c.rawMedian(:,q),c.fullSmoothMedian(:,q),c.nActive(:,q),c.cutoffMs(q),c.supportEndMs(q),c.medianSpeed(:,q)]=fr23_median(c.alignedSpeed(:,chosen));
        d.condition{p}=c;
        medRows=[medRows;repmat(p,600,1) d.timesMs c.nActive(:,q) c.rawMedian(:,q) c.fullSmoothMedian(:,q) c.medianSpeed(:,q) repmat([c.cutoffMs(q) c.supportEndMs(q)],600,1)]; %#ok<AGROW>
        for j=1:15
            tr=chosen(j);
            idRows=[idRows;8 q p j tr c.attemptID(tr) c.seed(tr) c.pathRMS(tr) c.moMs(tr) c.endMs(tr) c.peakSpeed(tr)]; %#ok<AGROW>
            thinRows=[thinRows;repmat([p c.attemptID(tr)],600,1) d.timesMs c.alignedSpeed(:,tr)]; %#ok<AGROW>
            pathRows=[pathRows;repmat([8 q p c.attemptID(tr)],600,1) d.timesMs 100*c.xy(:,:,tr)]; %#ok<AGROW>
        end
        for j=1:30
            tr=ids(j);
            allRows=[allRows;8 q p tr c.attemptID(tr) c.seed(tr) c.peakMs(tr) c.peakSpeed(tr) 100*c.peakXY(tr,:) c.distanceCM(j,q) ismember(tr,chosen) c.endMs(tr)]; %#ok<AGROW>
        end
        for n=[15 30]
            ix=chosen; if n==30, ix=ids; end
            pts=100*c.peakXY(ix,:); center=median(pts,1); dist=sqrt(sum((pts-center).^2,2)); covariance=cov(pts,1);
            summaryRows=[summaryRows;8 q p n median(c.peakSpeed(ix)) sqrt(mean(dist.^2)) center covariance(1,1) covariance(2,2) covariance(1,2)]; %#ok<AGROW>
        end
    end
    d.histEdgesCM=0:.5:ceil(max(allRows(:,11))/.5)*.5; d.histCounts=zeros(numel(d.histEdgesCM)-1,2);
    for p=1:2, d.histCounts(:,p)=histcounts(d.condition{p}.distanceCM(:,q),d.histEdgesCM).'; end
    v2_csv(fullfile(dest,'Fig6gh_selected_trials.csv'),{'network','target','condition','displayRank','poolIndex','attemptID','simulationSeed','pathRMS_M','moMs','entryMs','peakMps'},idRows);
    v2_csv(fullfile(dest,'Fig6g_median_support.csv'),{'condition','timeFromMOms','nActive','rawMedianMps','fullSmoothedMedianMps','displayedMedianMps','cutoffMs','supportEndMs'},medRows);
    v2_csv(fullfile(dest,'Fig6g_raw_thin_traces.csv'),{'condition','attemptID','timeFromMOms','unsmoothedSpeedMps'},thinRows);
    v2_csv(fullfile(dest,'Fig6h_display_paths.csv'),{'network','target','condition','attemptID','timeFromGOms','xCM','yCM'},pathRows);
    v2_csv(fullfile(dest,'Fig6h_all30_inset.csv'),{'network','target','condition','poolIndex','attemptID','seed','peakMs','peakMps','xCM','yCM','distanceCM','displayed','entryMs'},allRows);
    v2_csv(fullfile(dest,'Fig6h_histogram_counts.csv'),{'lowerCM','upperCM','IntactCount','BlockCount'},[d.histEdgesCM(1:end-1).' d.histEdgesCM(2:end).' d.histCounts]);
    v2_csv(fullfile(dest,'illustration_descriptives_NOT_MANUSCRIPT_STATS.csv'),{'network','target','condition','count','medianPeakMps','RMS_toOwnMedianCM','medianX_CM','medianY_CM','varianceX_CM2','varianceY_CM2','covarianceXY_CM2'},summaryRows);
    selection=struct('network',8,'target',q,'sameTrialsGH',true,'sampling','Retain original ten, uniformly choose five strata and one of two remaining members; continued original streams, no screening', ...
        'seeds',d.selectionSeeds,'IntactIDs',idRows(1:15,6).','BlockIDs',idRows(16:30,6).','medianCount',15,'minimumActive',8,'insetCount',30,'originalTenPreserved',true,'addedStrata',{d.addedStrata},'addedDraws',{d.addedDraws}, ...
        'cutoffsMs',[d.condition{1}.cutoffMs(q) d.condition{2}.cutoffMs(q)], ...
        'supportEndsMs',[d.condition{1}.supportEndMs(q) d.condition{2}.supportEndMs(q)], ...
        'selectedMedianPeakMps',summaryRows([1 3],5).','all30MedianPeakMps',summaryRows([2 4],5).', ...
        'selectedRMSspreadCM',summaryRows([1 3],6).','all30RMSspreadCM',summaryRows([2 4],6).');
    paper_json(fullfile(dest,'selection.json'),selection);
    receipt=fr23_audit(root,d,z.d,dest,plots,false);
    displayIDs=d.displayIDs; addedStrata=d.addedStrata; addedDraws=d.addedDraws;
    save(fullfile(dest,'selection_sources.mat'),'displayIDs','addedStrata','addedDraws','-v7');
    % Report actual subset descriptives unchanged; never condition rendering on effect direction.
    receipt.g=fr23_render_g(d,plots); receipt.h=fr23_render_h(d,plots);
    receipt.figures=fr23_audit(root,d,z.d,dest,plots,true);
    receipt.status='PASS'; paper_json(fullfile(dest,'validation.json'),receipt);
    disp(selection); disp(receipt);
end
