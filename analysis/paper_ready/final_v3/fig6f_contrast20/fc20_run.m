function receipt=fc20_run(root)
    % Deliberately contrast-selected display only; no simulation or inference.
    addpath(fullfile(root,'analysis/paper_ready'),fullfile(root,'analysis/paper_ready/final_v2'));
    base='fig6f_contrast20'; dest=fullfile(root,'results/paper_ready/final_v3',base);
    docs=fullfile(root,'docs/paper_ready/final_v3',base); plots=fullfile(root,'plots/paper_ready/final_v3',base);
    files=dir(fullfile(root,'analysis/paper_ready/final_v3',base,'*.m')); issues={};
    for file=files.'
        found=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(found), issues{end+1}=struct('file',file.name,'issues',found); end %#ok<AGROW>
    end
    paper_json(fullfile(docs,'code_analyzer.json'),struct('files',numel(files),'issues',{issues})); assert(isempty(issues));
    if isfolder(dest)
        entries=dir(dest); assert(all(ismember({entries.name},{'.','..'})),'Completed results must not be overwritten');
    else
        mkdir(dest);
    end
    z=load(fullfile(root,'results/paper_ready/cache/fig6fgh_highrms14/display_sources.mat'),'d'); d=z.d;
    assert(d.selectedNetwork==8 && sum(d.successes,'all')==453 && all(d.successes(:)>=4));
    panel=struct('chosen',zeros(4,8,2),'means',zeros(101,2,8,2),'selectedMeanRMS',zeros(8,2));
    selected=[]; ranks=[]; paths=[]; phases=[]; bounds=100*[d.targetXY+.015;d.targetXY-.015];
    for p=1:2
        c=d.condition{p};
        for q=1:8
            ids=(q-1)*30+(1:c.counts(q)); direction=3-2*p;
            ordered=sortrows([c.pathRMS(ids) c.attemptID(ids) ids.'],[direction 2]);
            choose=ordered(1:4,3); panel.chosen(:,q,p)=choose;
            panel.means(:,:,q,p)=mean(c.phaseXY(:,:,choose),3);
            panel.selectedMeanRMS(q,p)=mean(c.pathRMS(choose));
            phases=[phases;repmat([p q],101,1) d.phase panel.means(:,:,q,p)]; %#ok<AGROW>
            for j=1:numel(ids)
                tr=ordered(j,3);
                row=[8 p q j tr c.attemptID(tr) c.seed(tr) c.pathRMS(tr) c.moMs(tr) c.endMs(tr) c.counts(q) j<=4];
                ranks=[ranks;row]; %#ok<AGROW>
                path=c.xy(1:c.endMs(tr)+1,:,tr); bounds=[bounds;100*path]; %#ok<AGROW>
                if j<=4
                    selected=[selected;row]; %#ok<AGROW>
                    paths=[paths;repmat([p q c.attemptID(tr)],size(path,1),1) (0:size(path,1)-1).' path]; %#ok<AGROW>
                end
            end
        end
    end
    lo=min(bounds,[],1); hi=max(bounds,[],1); padding=.05*(hi-lo); limits=[lo-padding;hi+padding];
    headers={'network','condition','target','contrastRank','poolIndex','attemptID','simulationSeed','pathRMS_M','moMs','entryMs','successPoolCount','selected'};
    v2_csv(fullfile(dest,'all_success_rankings.csv'),headers,ranks);
    v2_csv(fullfile(dest,'selected_trials.csv'),headers,selected);
    v2_csv(fullfile(dest,'displayed_native_paths.csv'),{'condition','target','attemptID','timeFromGOms','xM','yM'},paths);
    v2_csv(fullfile(dest,'same_four_phase_means.csv'),{'condition','target','phase','xM','yM'},phases);
    scores=[(1:8).' d.successes panel.selectedMeanRMS diff(panel.selectedMeanRMS,1,2)];
    v2_csv(fullfile(dest,'display_contrast_scores.csv'),{'target','IntactPool','BlockPool','IntactSelectedMeanRMS_M','BlockSelectedMeanRMS_M','BlockMinusIntactSelectedMeanRMS_M'},scores);
    summary=struct('network',8,'selection','Intact four minimum-pathRMS; Block four maximum-pathRMS; ascending attempt-ID tie break', ...
        'objective','Maximize per-target Block-minus-Intact difference of four-trial mean ideal-segment pathRMS', ...
        'random',false,'typicalityClaim',false,'successCounts',d.successes,'phaseSamples',101, ...
        'thickSummary','Arithmetic mean of same four displayed successes','axisLimitsCM',limits, ...
        'IntactIDs',reshape(d.condition{1}.attemptID(panel.chosen(:,:,1)),4,8), ...
        'BlockIDs',reshape(d.condition{2}.attemptID(panel.chosen(:,:,2)),4,8));
    paper_json(fullfile(dest,'selection.json'),summary); save(fullfile(dest,'display_sources.mat'),'panel','limits','-v7');
    receipt=fc20_audit(root,d,panel,limits,dest,plots,false);
    fc20_render(d,panel,limits,plots);
    receipt.figure=fc20_audit(root,d,panel,limits,dest,plots,true);
    receipt.noSimulation=true; receipt.noInferentialStatistics=true;
    paper_json(fullfile(dest,'validation.json'),receipt); disp(summary); disp(receipt);
end
