function r=fd14_run(root)
    addpath(fullfile(root,'analysis/paper_ready'),fullfile(root,'analysis/paper_ready/final_v2'), ...
        fullfile(root,'analysis/paper_ready/prospective_variability'));
    base='fig6fgh_highrms14'; docs=fullfile(root,'docs/paper_ready/final_v3',base);
    issues={}; files=dir(fullfile(root,'analysis/paper_ready/final_v3',base,'*.m'));
    for file=files.'
        found=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(found), issues{end+1}=struct('file',file.name,'issues',found); end %#ok<AGROW> Bounded source files.
    end
    paper_json(fullfile(docs,'code_analyzer.json'),struct('files',numel(files),'issues',{issues})); assert(isempty(issues));
    dest=fullfile(root,'results/paper_ready/final_v3',base); cache=fullfile(root,'results/paper_ready/cache',base);
    assert(~isfolder(dest) && ~isfile(fullfile(cache,'display_sources.mat'))); mkdir(dest); if ~isfolder(cache), mkdir(cache); end
    d=fd14_build(root,dest); save(fullfile(cache,'display_sources.mat'),'d','-v7');
    r=fd14_audit(d,dest); paper_json(fullfile(dest,'saved_output_validation.json'),r);
    plots=fullfile(root,'plots/paper_ready/final_v3',base); r.render=fd14_render(d,plots);
    r.figures=fd14_figcheck(root,d,plots); paper_json(fullfile(dest,'validation.json'),r); disp(r);
end
