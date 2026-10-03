function d=sp10_build(root,dest)
    assert(~isfile(fullfile(dest,'display_sources.mat')));
    z=load(fullfile(root,'results/paper_ready/final_v3/summary.mat'),'s');
    d=struct('task','PAPER-MODELLING-FIG6FGH-SUCCESS-PATH-10','timesMs',(0:599).', ...
        'targetXY',z.s.targetXY,'targetColors',[1 0 .16;1 .601 0;.2549 .4118 .8824;0 1 .1476; ...
        .2510 .8784 .8157;.3137 .7843 .4706;.4827 0 1;1 0 .75], ...
        'conditionColors',[86 180 233;213 94 0]/255,'names',{{'Intact','Block'}}, ...
        'targetRadiusM',.015,'horizonMs',600,'targetScores5',zeros(10,8), ...
        'condition',{cell(1,2)},'sourcePaths',{cell(10,2)});
    assert(max(abs(d.targetXY-.1*[cosd((-90:45:225).') sind((-90:45:225).')]),[],'all')<1e-15);
    ranking=zeros(4800,12); at=0;
    for n=1:10
        raw=sp10_load(root,n,1); c=sp10_measure(raw,d.targetXY);
        d.targetScores5(n,:)=c.score5; d.sourcePaths{n,1}=raw.path;
        rows=trialRows(n,1,c); ranking(at+(1:240),:)=rows; at=at+240;
    end
    d.networkScore=mean(d.targetScores5,2); d.networkRanking=sortrows([(1:10).' d.networkScore],[2 1]);
    d.selectedNetwork=d.networkRanking(1,1); % Frozen BEFORE reading any Block.
    for n=1:10
        raw=sp10_load(root,n,2); c=sp10_measure(raw,d.targetXY); d.sourcePaths{n,2}=raw.path;
        rows=trialRows(n,2,c); ranking(at+(1:240),:)=rows; at=at+240;
        if n==d.selectedNetwork, d.condition{2}=c; end
    end
    d.condition{1}=sp10_measure(sp10_load(root,d.selectedNetwork,1),d.targetXY);
    [d.selectedTarget,d.targetEligibility,d.targetRule]=sp10_choose_target( ...
        d.condition{1}.successCount,d.condition{2}.successCount,d.condition{1}.score10);
    d.allTrialRankings=ranking;
    d.selectionDisclosure='Outcome-selected illustration, not an inferential unit or typicality claim. Success-first ideal center-to-target segment RMS; Intact-only five-trial/eight-target network score; Block success affects target eligibility only.';
    d.samplingDisclosure='Frozen kinematic movement onset through first entry inclusive for path RMS. Native GO 0:599 ms inside 600-ms horizon. Post-end samples NaN; no synthetic 600-ms sample. All-30 summaries/inset are independent of display selection.';
    save(fullfile(dest,'display_sources.mat'),'d','-v7.3');
    v2_csv(fullfile(dest,'network_ranking.csv'),{'network','IntactNetworkScoreM'},d.networkRanking);
    v2_csv(fullfile(dest,'all_intact_target_scores.csv'),{'network','target','fiveTrialMeanPathRMS_M'}, ...
        [repelem((1:10).',8) repmat((1:8).',10,1) reshape(d.targetScores5.',[],1)]);
    v2_csv(fullfile(dest,'target_eligibility.csv'),{'target','successIntact','successBlock','eligibleBoth10','minSuccess','IntactTenTrialScoreM','candidate','candidateRank','selected'},d.targetEligibility);
    headers={'network','condition','target','rank','localTrial','globalTrial','success','pathRMS_M','moMs','endMs','endIndex','peakMs'};
    v2_csv(fullfile(dest,'all_trial_rankings.csv'),headers,ranking);
    selected=ranking(:,1)==d.selectedNetwork;
    v2_csv(fullfile(dest,'Fig6f_selected_trials.csv'),headers,ranking(selected & ranking(:,4)<=5,:));
    v2_csv(fullfile(dest,'Fig6gh_selected_trials.csv'),headers,ranking(selected & ranking(:,3)==d.selectedTarget & ranking(:,4)<=10,:));
    peaks=zeros(60,9);
    for p=1:2
        c=d.condition{p}; ids=(d.selectedTarget-1)*30+(1:30);
        for k=1:30
            tr=ids(k); peaks((p-1)*30+k,:)=[p k tr c.peakMs(tr) c.peakSpeed(tr) 100*c.peakXY(tr,:) ...
                c.distanceCM(k,d.selectedTarget) ismember(tr,c.order(1:10,d.selectedTarget))];
        end
    end
    v2_csv(fullfile(dest,'Fig6h_all30_inset.csv'),{'condition','localTrial','globalTrial','peakMs','peakMps','xCM','yCM','distanceFromAll30MedianCM','displayed'},peaks);
    r=struct('network',d.selectedNetwork,'networkScoreM',d.networkScore(d.selectedNetwork),'target',d.selectedTarget, ...
        'targetScoreM',d.condition{1}.score10(d.selectedTarget),'targetRule',d.targetRule, ...
        'successCounts',[d.condition{1}.successCount;d.condition{2}.successCount], ...
        'Fig6f_localIDs_Intact',d.condition{1}.order(1:5,:)-(0:7)*30, ...
        'Fig6f_localIDs_Block',d.condition{2}.order(1:5,:)-(0:7)*30, ...
        'Fig6gh_localIDs',[d.condition{1}.order(1:10,d.selectedTarget) d.condition{2}.order(1:10,d.selectedTarget)]-(d.selectedTarget-1)*30, ...
        'networkRanking',d.networkRanking,'targetEligibility',d.targetEligibility,'disclosure',d.selectionDisclosure);
    paper_json(fullfile(dest,'selection.json'),r); disp(r);
end

function rows=trialRows(n,p,c)
    rows=zeros(240,12); at=0;
    for q=1:8
        for rank=1:30
            tr=c.order(rank,q); at=at+1;
            rows(at,:)=[n p q rank tr-(q-1)*30 tr c.entered(tr) c.pathRMS(tr) c.moMs(tr) c.endMs(tr) c.endIndex(tr) c.peakMs(tr)];
        end
    end
end
