function receipt=fs21_run(root)
    % Exhaustive display-subset matching; no model simulation or inference.
    addpath(fullfile(root,'analysis/paper_ready'),fullfile(root,'analysis/paper_ready/final_v2'));
    base='fig6f_scatter21'; dest=fullfile(root,'results/paper_ready/final_v3',base);
    docs=fullfile(root,'docs/paper_ready/final_v3',base); plots=fullfile(root,'plots/paper_ready/final_v3',base);
    files=dir(fullfile(root,'analysis/paper_ready/final_v3',base,'*.m')); issues={};
    for file=files.'
        found=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(found), issues{end+1}=struct('file',file.name,'issues',found); end %#ok<AGROW>
    end
    paper_json(fullfile(docs,'code_analyzer.json'),struct('files',numel(files),'issues',{issues})); assert(isempty(issues));
    assert(~isfolder(dest),'Do not overwrite completed sources'); mkdir(dest);
    z=load(fullfile(root,'results/paper_ready/cache/fig6fgh_highrms14/display_sources.mat'),'d'); d=z.d;
    assert(d.selectedNetwork==8 && sum(d.successes,'all')==453);
    panel=struct('chosen',zeros(4,8,2),'means',zeros(101,2,8,2),'scores',zeros(8,2), ...
        'fullD',zeros(8,2),'subsetD',zeros(8,2),'candidateCounts',zeros(8,2));
    allPeaks=[]; selected=[]; paths=[]; phaseRows=[]; quality=[];
    bounds=100*[d.targetXY+.015;d.targetXY-.015];
    for p=1:2
        c=d.condition{p};
        for q=1:8
            ids=(q-1)*30+(1:c.counts(q)); assert(issorted(c.attemptID(ids)) && numel(ids)>=4);
            points=c.peakXY(ids,:); [fullCenter,fullScatter,fullD]=moments(points);
            combinations=nchoosek(1:numel(ids),4); scores=subset_scores(points,combinations,fullCenter,fullScatter,fullD);
            [score,k]=min(scores); choose=ids(combinations(k,:)).'; panel.chosen(:,q,p)=choose;
            [center,scatter,subsetD]=moments(c.peakXY(choose,:));
            panel.means(:,:,q,p)=mean(c.phaseXY(:,:,choose),3); panel.scores(q,p)=score;
            panel.fullD(q,p)=fullD; panel.subsetD(q,p)=subsetD; panel.candidateCounts(q,p)=size(combinations,1);
            centerError=norm(center-fullCenter); scatterError=norm(scatter-fullScatter,'fro');
            if fullD==0, relativeD=0; relativeScatter=0;
            else, relativeD=100*(subsetD/fullD-1); relativeScatter=scatterError/norm(fullScatter,'fro'); end
            quality=[quality;p q numel(ids) size(combinations,1) score fullD subsetD relativeD centerError relativeScatter ...
                fullCenter center fullScatter(1,1) fullScatter(1,2) fullScatter(2,2) scatter(1,1) scatter(1,2) scatter(2,2)]; %#ok<AGROW>
            phaseRows=[phaseRows;repmat([p q],101,1) d.phase panel.means(:,:,q,p)]; %#ok<AGROW>
            for j=1:numel(ids)
                tr=ids(j); pick=ismember(tr,choose);
                row=[8 p q tr c.attemptID(tr) c.seed(tr) c.peakMs(tr) c.peakSpeed(tr) c.peakXY(tr,:) c.moMs(tr) c.endMs(tr) pick];
                allPeaks=[allPeaks;row]; %#ok<AGROW>
                path=c.xy(1:c.endMs(tr)+1,:,tr); bounds=[bounds;100*path]; %#ok<AGROW>
                if pick
                    selected=[selected;row]; %#ok<AGROW>
                    paths=[paths;repmat([p q c.attemptID(tr)],size(path,1),1) (0:size(path,1)-1).' path]; %#ok<AGROW>
                end
            end
        end
    end
    lo=min(bounds,[],1); hi=max(bounds,[],1); padding=.05*(hi-lo); limits=[lo-padding;hi+padding];
    headers={'network','condition','target','poolIndex','attemptID','simulationSeed','peakMs','peakMps','peakXM','peakYM','moMs','entryMs','selected'};
    v2_csv(fullfile(dest,'all_peak_positions.csv'),headers,allPeaks);
    v2_csv(fullfile(dest,'selected_trials.csv'),headers,selected);
    v2_csv(fullfile(dest,'displayed_native_paths.csv'),{'condition','target','attemptID','timeFromGOms','xM','yM'},paths);
    v2_csv(fullfile(dest,'same_four_phase_means.csv'),{'condition','target','phase','xM','yM'},phaseRows);
    qHeaders={'condition','target','poolCount','subsetsEvaluated','J','fullRMS_M','selectedRMS_M','RMS_relativeErrorPercent','medianShiftM','scatterRelativeFrobeniusError', ...
        'fullMedianXM','fullMedianYM','selectedMedianXM','selectedMedianYM','fullSxxM2','fullSxyM2','fullSyyM2','selectedSxxM2','selectedSxyM2','selectedSyyM2'};
    v2_csv(fullfile(dest,'scatter_match_quality.csv'),qHeaders,quality);
    summary=struct('network',8,'selection','Exhaustive minimum normalized median-center plus median-centered scatter-matrix mismatch', ...
        'objective','J=norm(m4-mN)^2/DN^2 + norm(S4-SN,fro)^2/norm(SN,fro)^2; fixed unit weights', ...
        'denominator','N and4, not N-1; S is median-centered second moment','random',false,'contrastSelected',false, ...
        'successCounts',d.successes,'candidateCounts',panel.candidateCounts,'totalCandidates',sum(panel.candidateCounts,'all'), ...
        'axisLimitsCM',limits,'thickSummary','101-point phase mean of same four displayed successes', ...
        'IntactIDs',reshape(d.condition{1}.attemptID(panel.chosen(:,:,1)),4,8), ...
        'BlockIDs',reshape(d.condition{2}.attemptID(panel.chosen(:,:,2)),4,8), ...
        'fullRMS_M',panel.fullD,'selectedRMS_M',panel.subsetD,'scores',panel.scores);
    paper_json(fullfile(dest,'selection.json'),summary);
    save(fullfile(dest,'display_sources.mat'),'panel','limits','-v7');
    receipt=fs21_audit(root,d,panel,limits,dest,plots,false);
    fs21_render(d,panel,limits,plots);
    receipt.figure=fs21_audit(root,d,panel,limits,dest,plots,true);
    receipt.noSimulation=true; receipt.noManuscriptInference=true;
    paper_json(fullfile(dest,'validation.json'),receipt); disp(summary); disp(receipt);
end

function [center,scatter,D]=moments(points)
    center=median(points,1); residual=points-center; scatter=(residual.'*residual)/size(points,1);
    D=sqrt(trace(scatter));
end

function scores=subset_scores(points,combinations,center,scatter,D)
    if D==0, scores=zeros(size(combinations,1),1); return; end
    x=reshape(points(combinations(:),1),size(combinations)); y=reshape(points(combinations(:),2),size(combinations));
    sx=sort(x,2); sy=sort(y,2); mx=(sx(:,2)+sx(:,3))/2; my=(sy(:,2)+sy(:,3))/2;
    dx=x-mx; dy=y-my; xx=mean(dx.^2,2); xy=mean(dx.*dy,2); yy=mean(dy.^2,2);
    scores=((mx-center(1)).^2+(my-center(2)).^2)/D^2 ...
        +((xx-scatter(1,1)).^2+2*(xy-scatter(1,2)).^2+(yy-scatter(2,2)).^2)/sum(scatter.^2,'all');
end
