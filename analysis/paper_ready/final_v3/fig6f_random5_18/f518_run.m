function receipt=f518_run(root)
    % Five prespecified random illustrations, no model or statistics.
    addpath(fullfile(root,'analysis/paper_ready'),fullfile(root,'analysis/paper_ready/final_v2'));
    base='fig6f_random5_18'; results=fullfile(root,'results/paper_ready/final_v3',base);
    docs=fullfile(root,'docs/paper_ready/final_v3',base); plots=fullfile(root,'plots/paper_ready/final_v3',base);
    if ~isfolder(results), mkdir(results); end
    files=dir(fullfile(root,'analysis/paper_ready/final_v3',base,'*.m')); issues={};
    for file=files.'
        found=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(found), issues{end+1}=struct('file',file.name,'issues',found); end %#ok<AGROW>
    end
    paper_json(fullfile(docs,'code_analyzer.json'),struct('files',numel(files),'issues',{issues})); assert(isempty(issues));
    loaded=load(fullfile(root,'results/paper_ready/cache/fig6fgh_highrms14/display_sources.mat'),'d'); d=loaded.d;
    assert(d.selectedNetwork==8 && all(d.successes(:)>=4));
    seeds=18001:18005; panels=repmat(struct('seed',0,'chosen',zeros(4,8,2),'means',zeros(101,2,8,2)),1,5);
    idRows=[]; meansRows=[]; allBounds=100*[d.targetXY+0.015;d.targetXY-0.015]; rawRows=[];
    for version=1:5
        stream=RandStream('mt19937ar','Seed',seeds(version)); panels(version).seed=seeds(version);
        for p=1:2
            c=d.condition{p};
            for q=1:8
                n=c.counts(q); pick=randperm(stream,n,4); chosen=(q-1)*30+pick(:);
                panels(version).chosen(:,q,p)=chosen;
                xy=mean(c.phaseXY(:,:,chosen),3); panels(version).means(:,:,q,p)=xy;
                meansRows=[meansRows;repmat([version seeds(version) p q],101,1) d.phase xy]; %#ok<AGROW>
                for rank=1:4
                    tr=chosen(rank);
                    idRows=[idRows;version seeds(version) 8 p q rank tr c.attemptID(tr) c.seed(tr) c.pathRMS(tr) c.moMs(tr) c.endMs(tr) n]; %#ok<AGROW>
                    last=c.endMs(tr)+1; path=c.xy(1:last,:,tr);
                    rawRows=[rawRows;repmat([version p q c.attemptID(tr)],last,1) (0:last-1).' path]; %#ok<AGROW>
                    allBounds=[allBounds;100*path]; %#ok<AGROW>
                end
            end
        end
    end
    lo=min(allBounds,[],1); hi=max(allBounds,[],1); padding=.05*(hi-lo);
    limits=[lo-padding;hi+padding]; % One common spatial frame across all five pairs.
    v2_csv(fullfile(results,'selected_trials.csv'),{'version','selectionSeed','network','condition','target','drawRank','poolIndex','attemptID','simulationSeed','pathRMS_M','moMs','entryMs','successPoolCount'},idRows);
    v2_csv(fullfile(results,'same_four_phase_means.csv'),{'version','selectionSeed','condition','target','phase','xM','yM'},meansRows);
    v2_csv(fullfile(results,'displayed_native_paths.csv'),{'version','condition','target','attemptID','timeFromGOms','xM','yM'},rawRows);
    summary=struct('network',8,'seeds',seeds,'successCounts',d.successes,'selection','Uniform four without replacement, one draw per condition-target, no ranking/rejection/reroll', ...
        'phaseSamples',101,'summary','Arithmetic mean of same four displayed trials','axisLimitsCM',limits,'noWinnerSelected',true);
    paper_json(fullfile(results,'selection_plan.json'),summary);
    assert(~isfile(fullfile(results,'display_sources.mat')));
    save(fullfile(results,'display_sources.mat'),'panels','limits','-v7');
    receipt=f518_audit(d,panels,limits,results,plots,false);
    for k=1:5, f518_render(d,panels(k),k,limits,plots); end
    receipt.figures=f518_audit(d,panels,limits,results,plots,true);
    f=figure('Visible','off','Color','w','Position',[20 20 1600 1320]); layout=tiledlayout(f,3,2,'TileSpacing','compact','Padding','compact');
    for k=1:5
        ax=nexttile(layout); image(ax,imread(fullfile(plots,'png',sprintf('Fig6f_option%d_seed%d.png',k,seeds(k))))); axis(ax,'image'); axis(ax,'off');
    end
    ax=nexttile(layout); axis(ax,'off');
    text(ax,.05,.70,{'Five fixed random draws; no ranking or rerolls.','Same network8, source pool, colors and spatial axes.', ...
        'Thin: four random successes per target/condition.','Thick: 101-point phase mean of those same four.', ...
        'Block target4 has only four successes: same in all versions.','Review only; current manuscript figure unchanged.'},'FontSize',14,'Interpreter','none');
    exportgraphics(f,fullfile(plots,'Five_options_overview.png'),'Resolution',120); close(f);
    receipt.status='PASS'; receipt.versions=5; receipt.noSimulation=true; receipt.noScientificStatistics=true;
    paper_json(fullfile(results,'validation.json'),receipt); disp(summary); disp(receipt);
end
