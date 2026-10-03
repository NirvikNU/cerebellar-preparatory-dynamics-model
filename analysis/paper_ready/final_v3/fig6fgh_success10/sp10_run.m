function receipt=sp10_run(root)
    addpath(fullfile(root,'analysis/paper_ready'),fullfile(root,'analysis/paper_ready/final_v2'), ...
        fullfile(root,'analysis/paper_ready/final_v3/fig6fgh_cleanup09'),fullfile(root,'analysis/paper_ready/prospective_variability'));
    base='fig6fgh_success10'; docs=fullfile(root,'docs/paper_ready/final_v3',base);
    dest=fullfile(root,'results/paper_ready/final_v3',base); plots=fullfile(root,'plots/paper_ready/final_v3',base);
    assert(~isfolder(dest) && ~isfolder(plots),'Refuse to overwrite prior output.');
    files=dir(fullfile(root,'analysis/paper_ready/final_v3',base,'*.m')); issues={};
    for file=files.'
        found=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(found), issues{end+1}=struct('file',file.name,'issues',found); end %#ok<AGROW> Bounded file list.
    end
    paper_json(fullfile(docs,'code_analyzer.json'),struct('files',numel(files),'messages',{issues}));
    assert(isempty(issues),'Code Analyzer findings: stop before source calculations.');
    mkdir(dest); mkdir(plots);
    d=sp10_build(root,dest); receipt=sp10_audit(root,d);
    receipt.rendered=sp10_render(d,plots); receipt.figures=sp10_figcheck(root,d,plots);
    current={'summary.mat','fig6ab_pvalues_correction/statistics.mat','fig6degh_pvalues_correction/statistics.mat', ...
        'fig6ij_ed7b_stats_correction/statistics.mat','fig6ij_fourlevel/summary.mat'};
    for j=1:numel(current)
        z=load(fullfile(root,'results/paper_ready/final_v3',current{j})); assert(~isempty(fieldnames(z)));
    end
    receipt.currentCompactsReadable=numel(current);
    paper_json(fullfile(dest,'validation.json'),receipt); disp(receipt);
end
