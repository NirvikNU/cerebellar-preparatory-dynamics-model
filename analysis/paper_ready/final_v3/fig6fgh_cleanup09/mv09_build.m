function d=mv09_build(root,dest)
    assert(~isfile(fullfile(dest,'display_sources.mat')));
    z=load(fullfile(root,'results','paper_ready','final_v3','summary.mat'),'s'); old=z.s;
    d=struct('task','PAPER-MODELLING-FIG6FGH-CLEANUP-PUSH-09','timesMs',(0:599).', ...
        'targetXY',old.targetXY,'targetColors',[1 0 .16;1 .601 0;.2549 .4118 .8824;0 1 .1476; ...
        .2510 .8784 .8157;.3137 .7843 .4706;.4827 0 1;1 0 .75], ...
        'targetRadiusM',.015,'horizonMs',600,'names',{{'Intact','Block'}}, ...
        'targetRMS',zeros(10,8),'raw',{cell(1,2)},'condition',{cell(1,2)},'intactSourcePaths',{cell(10,1)});
    expected=.1*[cosd((-90:45:225).') sind((-90:45:225).')];
    assert(max(abs(expected-d.targetXY),[],'all')<1e-15);
    for n=1:10
        raw=mv09_load(root,n,1); a=measure(raw,d.targetXY,d.timesMs);
        d.targetRMS(n,:)=a.targetRMS; d.intactSourcePaths{n}=raw.path;
    end
    d.networkScore=mean(d.targetRMS,2);
    d.networkRanking=sortrows([(1:10).' d.networkScore],[2 1]);
    d.selectedNetwork=d.networkRanking(1,1);
    d.targetRanking=sortrows([(1:8).' d.targetRMS(d.selectedNetwork,:).'],[2 1]);
    d.selectedTarget=d.targetRanking(1,1);
    % Network/target choices are now frozen from Intact, before any Block read.
    for p=1:2
        raw=mv09_load(root,d.selectedNetwork,p); d.raw{p}=raw;
        d.condition{p}=measure(raw,d.targetXY,d.timesMs);
    end
    d.selectionDisclosure='Outcome-selected illustrative low-variability example. Network minimizes mean of eight Intact target RMSs; target minimizes Intact target RMS within that network. Not an inferential unit or typicality claim.';
    d.samplingDisclosure='Native saved times GO 0:599 ms within the frozen 600-ms integration horizon; no synthetic 600-ms sample. First target-entry sample retained, later samples NaN; no entry means boundary 600 ms.';
    save(fullfile(dest,'display_sources.mat'),'d','-v7.3');
    v2_csv(fullfile(dest,'network_ranking.csv'),{'network','IntactNetworkScoreM'},d.networkRanking);
    v2_csv(fullfile(dest,'all_intact_target_RMS.csv'),{'network','target','IntactTargetRMS_M'}, ...
        [repelem((1:10).',8) repmat((1:8).',10,1) reshape(d.targetRMS.',[],1)]);
    v2_csv(fullfile(dest,'selected_network_target_ranking.csv'),{'target','IntactTargetRMS_M'},d.targetRanking);
    ranking=zeros(480,9); selection=zeros(80,7); peaks=zeros(60,9); at=0; st=0;
    for p=1:2
        c=d.condition{p};
        for q=1:8
            for rank=1:30
                tr=c.order(rank,q); local=tr-(q-1)*30; at=at+1;
                ranking(at,:)=[p q rank local tr c.trialRMS(tr) c.endMs(tr) c.endIndex(tr) c.entered(tr)];
                if rank<=5, st=st+1; selection(st,:)=[p q rank local tr c.trialRMS(tr) c.endMs(tr)]; end
            end
        end
        ids=(d.selectedTarget-1)*30+(1:30);
        for k=1:30
            tr=ids(k); peaks((p-1)*30+k,:)=[p k tr c.peakMs(tr) c.peakSpeed(tr) 100*c.peakXY(tr,:) ...
                c.distanceCM(k,d.selectedTarget) ismember(tr,c.order(1:10,d.selectedTarget))];
        end
    end
    v2_csv(fullfile(dest,'all_trial_rankings.csv'),{'condition','target','rank','localTrial','globalTrial','RMS_M','endMs','endIndex','enteredZone'},ranking);
    v2_csv(fullfile(dest,'Fig6f_selected_trials.csv'),{'condition','target','rank','localTrial','globalTrial','RMS_M','endMs'},selection);
    v2_csv(fullfile(dest,'Fig6gh_selected_trials.csv'),{'condition','target','rank','localTrial','globalTrial','RMS_M','endMs','endIndex','enteredZone'}, ...
        ranking(ranking(:,2)==d.selectedTarget & ranking(:,3)<=10,:));
    v2_csv(fullfile(dest,'Fig6h_all30_inset.csv'),{'condition','localTrial','globalTrial','peakMs','peakMps','xCM','yCM','distanceFromAll30MedianCM','displayed'},peaks);
    receipt=struct('selectedNetwork',d.selectedNetwork,'IntactNetworkScoreM',d.networkScore(d.selectedNetwork), ...
        'selectedTarget',d.selectedTarget,'IntactTargetRMS_M',d.targetRMS(d.selectedNetwork,d.selectedTarget), ...
        'networkRanking',d.networkRanking,'targetRanking',d.targetRanking, ...
        'Fig6f_globalIDs',[d.condition{1}.order(1:5,:);d.condition{2}.order(1:5,:)], ...
        'Fig6gh_globalIDs',[d.condition{1}.order(1:10,d.selectedTarget) d.condition{2}.order(1:10,d.selectedTarget)], ...
        'selectionDisclosure',d.selectionDisclosure,'samplingDisclosure',d.samplingDisclosure);
    paper_json(fullfile(dest,'selection.json'),receipt); disp(receipt);
end

function c=measure(raw,targets,times)
    origin=raw.hand(1,[1 3],1); xy=raw.hand(:,[1 3],:)-origin;
    c=struct('xy',xy,'speed',raw.speed,'meanXY',nan(600,2,8),'targetRMS',zeros(1,8), ...
        'trialRMS',zeros(240,1),'endIndex',zeros(240,1),'endMs',zeros(240,1),'entered',false(240,1), ...
        'order',zeros(30,8),'smoothSpeed',nan(600,240),'medianSpeed',nan(600,8), ...
        'peakMs',zeros(240,1),'peakSpeed',zeros(240,1),'peakXY',zeros(240,2),'distanceCM',zeros(30,8));
    for tr=1:240
        q=ceil(tr/30); stop=find(sum((xy(:,:,tr)-targets(q,:)).^2,2)<=.015^2,1);
        if isempty(stop), stop=find(times<600,1,'last'); c.endMs(tr)=600;
        else, c.entered(tr)=true; c.endMs(tr)=times(stop); end
        c.endIndex(tr)=stop; c.xy(stop+1:end,:,tr)=NaN; c.speed(stop+1:end,tr)=NaN;
        c.smoothSpeed(1:stop,tr)=smoothdata(c.speed(1:stop,tr),'gaussian',50);
        [c.peakSpeed(tr),ix]=max(c.speed(1:stop,tr)); c.peakMs(tr)=times(ix); c.peakXY(tr,:)=xy(ix,:,tr);
    end
    for q=1:8
        ids=(q-1)*30+(1:30); c.meanXY(:,:,q)=mean(c.xy(:,:,ids),3,'omitnan');
        squared=sum((c.xy(:,:,ids)-c.meanXY(:,:,q)).^2,2);
        c.targetRMS(q)=sqrt(mean(squared,'all','omitnan'));
        for tr=ids
            stop=c.endIndex(tr); err=c.xy(1:stop,:,tr)-c.meanXY(1:stop,:,q);
            c.trialRMS(tr)=sqrt(mean(sum(err.^2,2)));
        end
        rows=sortrows([c.trialRMS(ids) ids.'],[1 2]); c.order(:,q)=rows(:,2);
        med=median(c.speed(:,ids),2,'omitnan'); last=find(isfinite(med),1,'last');
        c.medianSpeed(1:last,q)=smoothdata(med(1:last),'gaussian',50);
        positions=c.peakXY(ids,:); c.distanceCM(:,q)=100*sqrt(sum((positions-median(positions,1)).^2,2));
    end
end
