function d=fd14_build(root,dest)
    % Saved hand trajectories only. No model, random draw, fit or test is executed.
    z=load(fullfile(root,'results/paper_ready/final_v3/summary.mat'),'s');
    source=fullfile(root,'results/paper_ready/cache/fig6fgh_successful11/reservoir');
    d=struct('task','PAPER-MODELLING-FIG6FGH-HIGHRMS-EMPIRICALSTYLE-14','selectedNetwork',8, ...
        'timesMs',(0:599).','phase',linspace(0,1,101).','targetXY',z.s.targetXY, ...
        'targetColors',[1 0 .16;1 .601 0;.2549 .4118 .8824;0 1 .1476;.2510 .8784 .8157;.3137 .7843 .4706;.4827 0 1;1 0 .75], ...
        'conditionColors',[86 180 233;213 94 0]/255,'names',{{'Intact','Block'}},'condition',{cell(1,2)}, ...
        'attempts',zeros(8,2),'successes',zeros(8,2),'attempt30',inf(8,2),'targetScores',nan(8,1));
    assert(max(abs(d.targetXY-.1*[cosd((-90:45:225).') sind((-90:45:225).')]),[],'all')<1e-15);
    attempts=zeros(0,9); ranks=zeros(0,10); sourceAudit=struct('trials',0,'successes',0,'maxPathError',0,'status','PASS');
    for p=1:2
        c=struct('xy',nan(600,2,240),'hand',nan(600,4,240),'phaseXY',nan(101,2,240), ...
            'alignedSpeed',nan(600,240),'meanXY',nan(101,2,8),'order',nan(30,8),'lowOrder',nan(30,8),'counts',zeros(8,1), ...
            'attemptID',nan(240,1),'seed',nan(240,1),'pathRMS',nan(240,1),'moMs',nan(240,1), ...
            'endMs',nan(240,1),'peakXY',nan(240,2),'peakSpeed',nan(240,1),'peakMs',nan(240,1), ...
            'distanceCM',nan(30,8),'medianPeakXY',nan(8,2),'nActive',zeros(600,8), ...
            'rawMedian',nan(600,8),'fullSmoothMedian',nan(600,8),'medianSpeed',nan(600,8), ...
            'cutoffMs',nan(8,1),'supportEndMs',nan(8,1));
        for q=1:8
            folder=fullfile(source,sprintf('p%d_t%d',p,q)); files=dir(fullfile(folder,'batch_*.mat'));
            rows=zeros(0,9); hands=zeros(600,4,0);
            for file=files.'
                z=load(fullfile(folder,file.name),'raw'); r=z.raw; count=numel(r.attemptIDs);
                assert(r.network==8 && r.conditionIndex==p && r.target==q && r.visualizationOnly);
                assert(isequal(r.seeds,610000000+1000000*p+10000*q+r.attemptIDs));
                audit=jsondecode(fileread(fullfile(folder,strrep(strrep(file.name,'batch_','audit_'),'.mat','.json'))));
                assert(strcmp(audit.status,'PASS') && audit.trials==count);
                for j=1:count
                    xy=r.hand(:,[1 3],j)-r.hand(1,[1 3],j); v=hypot(r.hand(:,2,j),r.hand(:,4,j));
                    ix=find(hypot(xy(:,1)-d.targetXY(q,1),xy(:,2)-d.targetXY(q,2))<=.015,1);
                    assert(r.success(j)==~isempty(ix)); mo=find(v>=.2*max(v),1)-1;
                    assert(isequal(mo,r.moMs(j)) && isequal(v,r.speed(:,j)));
                    if ~isempty(ix)
                        assert(ix-1==r.entryMs(j) && mo<ix-1 && ix<=600);
                        path=xy(mo+1:ix,:); target=d.targetXY(q,:); a=max(0,min(1,path*target.'/sum(target.^2)));
                        rms=sqrt(mean(sum((path-a.*target).^2,2)));
                        sourceAudit.maxPathError=max(sourceAudit.maxPathError,abs(rms-r.pathRMS(j)));
                    end
                end
                rows=[rows;repmat([8 p q],count,1) r.attemptIDs.' r.seeds.' r.success.' r.moMs.' r.entryMs.' r.pathRMS.']; %#ok<AGROW> Saved bounded ledger.
                hands=cat(3,hands,r.hand(:,:,r.success));
            end
            assert(isequal(rows(:,4),(1:size(rows,1)).'));
            prior=fullfile(root,'results/paper_ready/final_v3/fig6fgh_successful11',sprintf('attempts_p%d_t%d.csv',p,q));
            if p==2 && q==5, prior=fullfile(fileparts(prior),'partial_p2_t5_attempts.csv'); end
            assert(isequaln(readmatrix(prior),rows));
            good=rows(rows(:,6)==1,:); n=size(good,1); assert(n>=4 && n<=30);
            d.attempts(q,p)=size(rows,1); d.successes(q,p)=n;
            if n==30, d.attempt30(q,p)=good(30,4); end
            attempts=[attempts;rows]; %#ok<AGROW> Saved attempt ledger.
            sourceAudit.trials=sourceAudit.trials+size(rows,1); sourceAudit.successes=sourceAudit.successes+n;
            c.counts(q)=n; ids=(q-1)*30+(1:n);
            for j=1:n
                tr=ids(j); first=good(j,7)+1; last=good(j,8)+1; hand=hands(:,:,j); xy=hand(:,[1 3])-hand(1,[1 3]); v=hypot(hand(:,2),hand(:,4));
                c.hand(:,:,tr)=hand; c.xy(1:last,:,tr)=xy(1:last,:); c.attemptID(tr)=good(j,4); c.seed(tr)=good(j,5);
                c.pathRMS(tr)=good(j,9); c.moMs(tr)=first-1; c.endMs(tr)=last-1;
                c.phaseXY(:,:,tr)=interp1(linspace(0,1,last-first+1).',xy(first:last,:),d.phase,'linear');
                c.alignedSpeed(1:last-first+1,tr)=v(first:last);
                [c.peakSpeed(tr),ix]=max(v(1:last)); c.peakMs(tr)=ix-1; c.peakXY(tr,:)=xy(ix,:);
            end
            low=sortrows([c.pathRMS(ids) c.attemptID(ids) ids.'],[1 2]); c.lowOrder(1:n,q)=low(:,3);
            ordered=sortrows([c.pathRMS(ids) c.attemptID(ids) ids.'],[-1 2]); c.order(1:n,q)=ordered(:,3);
            c.meanXY(:,:,q)=mean(c.phaseXY(:,:,c.order(1:4,q)),3);
            c.medianPeakXY(q,:)=median(c.peakXY(ids,:),1);
            c.distanceCM(1:n,q)=100*hypot(c.peakXY(ids,1)-c.medianPeakXY(q,1),c.peakXY(ids,2)-c.medianPeakXY(q,2));
            for rank=1:n
                tr=c.order(rank,q);
                ranks(end+1,:)=[8 p q rank tr c.attemptID(tr) c.seed(tr) c.pathRMS(tr) c.moMs(tr) c.endMs(tr)]; %#ok<AGROW> At most480 successes.
            end
        end
        d.condition{p}=c;
    end
    assert(sourceAudit.trials==12674 && sourceAudit.successes==453 && sourceAudit.maxPathError<1e-14);
    d.eligible=all(d.attempt30<=500,2);
    for q=find(d.eligible).', c=d.condition{1}; d.targetScores(q)=mean(c.pathRMS(c.lowOrder(1:10,q))); end
    eligible=find(d.eligible); assert(~isempty(eligible)); rank=sortrows([d.targetScores(eligible) eligible],[1 2]); d.selectedTarget=rank(1,2);
    q=d.selectedTarget; medRows=zeros(1200,8); speedRows=[]; peaks=zeros(60,10); phaseRows=zeros(1616,5); at=0;
    fIDs=zeros(4,8,2); ghIDs=zeros(10,2);
    for p=1:2
        c=d.condition{p}; ids=(q-1)*30+(1:30); assert(c.counts(q)==30);
        [c.rawMedian(:,q),c.fullSmoothMedian(:,q),c.nActive(:,q),c.cutoffMs(q),c.supportEndMs(q),c.medianSpeed(:,q)]=fd14_median(c.alignedSpeed(:,ids));
        d.condition{p}=c;
        medRows((p-1)*600+(1:600),:)=[repmat(p,600,1) d.timesMs c.nActive(:,q) c.rawMedian(:,q) c.fullSmoothMedian(:,q) c.medianSpeed(:,q) repmat([c.cutoffMs(q) c.supportEndMs(q)],600,1)];
        ghIDs(:,p)=c.attemptID(c.order(1:10,q)); fIDs(:,:,p)=reshape(c.attemptID(c.order(1:4,:)),4,8);
        for tr=c.order(1:10,q).'
            speedRows=[speedRows;repmat([p c.attemptID(tr)],600,1) d.timesMs c.alignedSpeed(:,tr)]; %#ok<AGROW> Twenty thin curves.
        end
        for j=1:30
            tr=ids(j); peaks((p-1)*30+j,:)=[p c.attemptID(tr) c.seed(tr) c.peakMs(tr) c.peakSpeed(tr) 100*c.peakXY(tr,:) c.distanceCM(j,q) ismember(tr,c.order(1:10,q)) c.endMs(tr)];
        end
        for target=1:8, phaseRows(at+(1:101),:)=[repmat([p target],101,1) d.phase c.meanXY(:,:,target)]; at=at+101; end
    end
    headers={'network','condition','target','descendingDisplayRank','poolIndex','attemptID','seed','pathRMS_M','moMs','entryMs'};
    v2_csv(fullfile(dest,'all_saved_attempts.csv'),{'network','condition','target','attemptID','seed','success','moMs','entryMs','pathRMS_M'},attempts);
    v2_csv(fullfile(dest,'successful_rankings.csv'),headers,ranks);
    v2_csv(fullfile(dest,'Fig6f_selected_trials.csv'),headers,ranks(ranks(:,4)<=4,:));
    v2_csv(fullfile(dest,'Fig6gh_selected_trials.csv'),headers,ranks(ranks(:,3)==q & ranks(:,4)<=10,:));
    eligibility=[(1:8).' d.successes d.attempts d.attempt30 double(d.eligible) d.targetScores double((1:8).'==q)];
    v2_csv(fullfile(dest,'eligibility.csv'),{'target','IntactSuccess','BlockSuccess','IntactAttempts','BlockAttempts','IntactAttempt30','BlockAttempt30','eligible','IntactTenBestScoreM','selected'},eligibility);
    v2_csv(fullfile(dest,'Fig6f_four_trial_phase_means.csv'),{'condition','target','phase','xM','yM'},phaseRows);
    v2_csv(fullfile(dest,'Fig6g_median_support.csv'),{'condition','timeFromMO_Ms','nActive','rawMedianMps','fullSmoothedMedianMps','displayedMedianMps','cutoffMs','supportEndMs'},medRows);
    v2_csv(fullfile(dest,'Fig6g_raw_thin_traces.csv'),{'condition','attemptID','timeFromMO_Ms','unsmoothedSpeedMps'},speedRows);
    v2_csv(fullfile(dest,'Fig6h_all30_inset.csv'),{'condition','attemptID','seed','peakMs','peakMps','xCM','yCM','distanceCM','displayed','entryMs'},peaks);
    d.sourceAudit=sourceAudit;
    d.histEdgesCM=0:.5:6; d.histCounts=zeros(12,2);
    for p=1:2
        values=d.condition{p}.distanceCM(:,q); assert(all(values>=0 & values<=6));
        d.histCounts(:,p)=histcounts(values,d.histEdgesCM).';
    end
    v2_csv(fullfile(dest,'Fig6h_histogram_counts.csv'),{'lowerCM','upperCM','IntactCount','BlockCount'},[d.histEdgesCM(1:end-1).' d.histEdgesCM(2:end).' d.histCounts]);
    selection=struct('network',8,'target',q,'eligibility',eligibility,'Fig6f_Intact',fIDs(:,:,1),'Fig6f_Block',fIDs(:,:,2), ...
        'Fig6gh',ghIDs,'cutoffMs',[d.condition{1}.cutoffMs(q) d.condition{2}.cutoffMs(q)], ...
        'fullSupportEndMs',[d.condition{1}.supportEndMs(q) d.condition{2}.supportEndMs(q)],'sourceAudit',sourceAudit);
    paper_json(fullfile(dest,'selection.json'),selection); disp(selection);
end
