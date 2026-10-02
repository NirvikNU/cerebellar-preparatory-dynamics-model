function receipt=mv09_run(root,phase)
    assert(ismember(phase,{'initial','initial_r1','smoke'}));
    addpath(fullfile(root,'analysis','paper_ready'),fullfile(root,'analysis','paper_ready','final_v2'));
    base='fig6fgh_cleanup09'; docs=fullfile(root,'docs','paper_ready','final_v3',base);
    dest=fullfile(root,'results','paper_ready','final_v3',base);
    plots=fullfile(root,'plots','paper_ready','final_v3',base);
    if strcmp(phase,'smoke'), dest=fullfile(dest,'smoke'); plots=fullfile(plots,'smoke'); end
    assert(~isfolder(dest) && ~isfolder(plots));
    files=dir(fullfile(root,'analysis','paper_ready','final_v3',base,'*.m')); messages={};
    for file=files.'
        issues=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(issues), messages{end+1}=struct('name',file.name,'issues',issues); end %#ok<AGROW> Bounded file list.
    end
    paper_json(fullfile(docs,['code_analyzer_' phase '.json']),struct('files',numel(files),'messages',{messages}));
    assert(isempty(messages),'MV09:Analyzer','Code Analyzer findings before analysis.');
    mkdir(dest); mkdir(plots);
    d=mv09_build(root,dest); rendered=mv09_render(d,plots); receipt=mv09_validate(root,d,plots);
    if strcmp(phase,'smoke')
        z=load(fullfile(fileparts(dest),'display_sources.mat'),'d'); assert(isequaln(d,z.d));
        receipt.postCleanupDisplaySourcesExact=true;
    end
    % Compact current numerical bundles remain readable without recomputing science.
    current={'summary.mat','fig6ab_pvalues_correction/statistics.mat','fig6degh_pvalues_correction/statistics.mat', ...
        'fig6ij_ed7b_stats_correction/statistics.mat','fig6ij_fourlevel/summary.mat'};
    for j=1:numel(current)
        z=load(fullfile(root,'results','paper_ready','final_v3',current{j})); assert(~isempty(fieldnames(z)));
    end
    receipt.currentCompactsReadable=numel(current); receipt.phase=phase; receipt.rendered=rendered;
    paper_json(fullfile(dest,'validation.json'),receipt); disp(receipt);
end
