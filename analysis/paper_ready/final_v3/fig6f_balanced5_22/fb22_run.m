function receipt=fb22_run(root)
    % Five balanced visualization draws from saved evidence, never simulation.
    addpath(fullfile(root,'analysis/paper_ready'),fullfile(root,'analysis/paper_ready/final_v2'));
    name='fig6f_balanced5_22'; dest=fullfile(root,'results/paper_ready/final_v3',name);
    docs=fullfile(root,'docs/paper_ready/final_v3',name); plots=fullfile(root,'plots/paper_ready/final_v3',name);
    assert(~isfolder(dest),'Never overwrite a completed or partial result bundle');
    files=dir(fullfile(root,'analysis/paper_ready/final_v3',name,'*.m')); issues={};
    for file=files.'
        found=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(found), issues{end+1}=struct('file',file.name,'issues',found); end %#ok<AGROW>
    end
    paper_json(fullfile(docs,'code_analyzer.json'),struct('files',numel(files),'issues',{issues})); assert(isempty(issues));
    ledger=readmatrix(fullfile(root,'results/paper_ready/final_v3/fig6fgh_highrms14/all_saved_attempts.csv'));
    assert(size(ledger,1)==12674 && sum(ledger(:,6))==453 && all(ledger(:,1)==8));
    z=load(fullfile(root,'results/paper_ready/cache/fig6fgh_highrms14/display_sources.mat'),'d'); d=z.d;
    seeds=18001:18005; phase=linspace(0,1,101).';
    panels=repmat(struct('seed',0,'chosen',zeros(6,8,2),'means',zeros(101,2,8,2)),1,5);
    counts=zeros(16,4); countAt=0;
    for version=1:5
        stream=RandStream('mt19937ar','Seed',seeds(version)); panels(version).seed=seeds(version);
        for p=1:2
            for q=1:8
                success=find(ledger(:,2)==p & ledger(:,3)==q & ledger(:,6)==1);
                failure=find(ledger(:,2)==p & ledger(:,3)==q & ledger(:,6)==0);
                assert(numel(success)>=3 && numel(failure)>=3);
                assert(issorted(ledger(success,4)) && issorted(ledger(failure,4)));
                pickS=success(randperm(stream,numel(success),3)); pickF=failure(randperm(stream,numel(failure),3));
                panels(version).chosen(:,q,p)=[pickS(:);pickF(:)];
                if version==1
                    countAt=countAt+1; counts(countAt,:)=[p q numel(success) numel(failure)];
                end
            end
        end
    end
    needed=unique(cat(1,panels.chosen)); needed=needed(:);
    records=repmat(struct('ledgerIndex',0,'row',[],'hand',[],'xy',[],'phaseXY',[],'stopMs',0,'batchID',0),numel(needed),1);
    rawRoot=fullfile(root,'results/paper_ready/cache/fig6fgh_successful11/reservoir');
    loadedBatches=0;
    for p=1:2
        for q=1:8
            folder=fullfile(rawRoot,sprintf('p%d_t%d',p,q)); requests=dir(fullfile(folder,'request_*.json'));
            wanted=needed(ledger(needed,2)==p & ledger(needed,3)==q);
            for file=requests.'
                request=jsondecode(fileread(fullfile(folder,file.name)));
                hits=wanted(ismember(ledger(wanted,4),request.attemptIDs));
                if isempty(hits), continue; end
                batchID=sscanf(file.name,'request_%d.json');
                z=load(fullfile(folder,sprintf('batch_%04d.mat',batchID)),'raw'); raw=z.raw; loadedBatches=loadedBatches+1;
                assert(raw.network==8 && raw.conditionIndex==p && raw.target==q && raw.visualizationOnly);
                assert(raw.eta==0 && raw.lambda==10 && raw.alpha==.5 && raw.betaNormalized==1.25 && isequal(raw.noise,[.1 .1]));
                for id=hits.'
                    at=find(needed==id); slot=find(raw.attemptIDs==ledger(id,4)); assert(isscalar(slot) && records(at).ledgerIndex==0);
                    assert(raw.seeds(slot)==ledger(id,5) && raw.success(slot)==ledger(id,6));
                    hand=raw.hand(:,:,slot); assert(isequal(size(hand),[600 4]) && all(isfinite(hand),'all'));
                    last=600; if ledger(id,6), last=ledger(id,8)+1; end
                    first=ledger(id,7)+1; assert(isfinite(first) && first<last && first>=1);
                    xy=hand(:,[1 3])-hand(1,[1 3]); xy(last+1:end,:)=NaN;
                    phaseXY=interp1(linspace(0,1,last-first+1).',xy(first:last,:),phase,'linear');
                    records(at)=struct('ledgerIndex',id,'row',ledger(id,:),'hand',hand,'xy',xy,'phaseXY',phaseXY,'stopMs',last-1,'batchID',batchID);
                end
            end
        end
    end
    assert(isequal([records.ledgerIndex].',needed)); mkdir(dest);
    ids=[]; pathRows=[]; meanRows=[]; bounds=100*[d.targetXY+.015;d.targetXY-.015];
    for version=1:5
        [valid,index]=ismember(panels(version).chosen,needed); assert(all(valid,'all')); panels(version).chosen=index;
        for p=1:2
            for q=1:8
                chosen=index(:,q,p); pieces=cat(3,records(chosen).phaseXY); panels(version).means(:,:,q,p)=mean(pieces,3);
                meanRows=[meanRows;repmat([version seeds(version) p q],101,1) phase panels(version).means(:,:,q,p)]; %#ok<AGROW>
                for rank=1:6
                    at=chosen(rank); r=records(at); last=r.stopMs+1;
                    ids=[ids;version seeds(version) rank r.ledgerIndex r.row(1:8) r.stopMs r.batchID]; %#ok<AGROW>
                    path=r.xy(1:last,:); bounds=[bounds;100*path]; %#ok<AGROW>
                    pathRows=[pathRows;repmat([version p q r.row(4) r.row(6)],last,1) (0:last-1).' path]; %#ok<AGROW>
                end
            end
        end
    end
    lo=min(bounds,[],1); hi=max(bounds,[],1); padding=.05*(hi-lo); limits=[lo-padding;hi+padding];
    v2_csv(fullfile(dest,'selected_trials.csv'),{'version','selectionSeed','drawRank','ledgerRow','network','condition','target','attemptID','simulationSeed','success','moMs','entryMs','displayEndMs','sourceBatch'},ids);
    v2_csv(fullfile(dest,'pool_counts.csv'),{'condition','target','successes','failures'},counts);
    v2_csv(fullfile(dest,'displayed_native_paths.csv'),{'version','condition','target','attemptID','success','timeFromGOms','xM','yM'},pathRows);
    v2_csv(fullfile(dest,'same_six_phase_means.csv'),{'version','selectionSeed','condition','target','phase','xM','yM'},meanRows);
    compact=rmfield(records,'hand'); save(fullfile(dest,'display_sources.mat'),'panels','compact','limits','-v7');
    summary=struct('network',8,'seeds',seeds,'selection','One uniform success-three draw then failure-three draw per condition-target; no rerolls or ranking', ...
        'poolCounts',counts,'selectedRecords',size(ids,1),'uniqueNativeTrials',numel(records),'loadedBatches',loadedBatches, ...
        'phaseSamples',101,'mean','Same six equally weighted, MO-to-entry(success) or MO-to-599ms(failure)', ...
        'axisLimitsCM',limits,'balancedNotActualSuccessRate',true,'noWinnerSelected',true);
    paper_json(fullfile(dest,'selection_plan.json'),summary);
    receipt=fb22_audit(root,d,records,panels,limits,dest,plots,false);
    for version=1:5, fb22_render(d,records,panels(version),version,limits,plots); end
    receipt.figures=fb22_audit(root,d,records,panels,limits,dest,plots,true);
    receipt.noSimulation=true; receipt.noScientificStatistics=true;
    paper_json(fullfile(dest,'validation.json'),receipt); disp(summary); disp(receipt);
end
