function r=fd13_run(root)
    addpath(fullfile(root,'analysis/paper_ready'),fullfile(root,'analysis/paper_ready/final_v2'), ...
        fullfile(root,'analysis/paper_ready/prospective_variability'));
    base='fig6fgh_final13'; docs=fullfile(root,'docs/paper_ready/final_v3',base);
    issues={}; files=dir(fullfile(root,'analysis/paper_ready/final_v3',base,'*.m'));
    for file=files.'
        found=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(found), issues{end+1}=struct('file',file.name,'issues',found); end %#ok<AGROW> Bounded source files.
    end
    paper_json(fullfile(docs,'code_analyzer.json'),struct('files',numel(files),'issues',{issues})); assert(isempty(issues));
    dest=fullfile(root,'results/paper_ready/final_v3',base); cache=fullfile(root,'results/paper_ready/cache',base);
    assert(~isfolder(dest) && ~isfolder(cache)); mkdir(dest); mkdir(cache);
    d=fd13_build(root,dest); save(fullfile(cache,'display_sources.mat'),'d','-v7');
    r=fd13_audit(d,dest); paper_json(fullfile(dest,'saved_output_validation.json'),r);
    plots=fullfile(root,'plots/paper_ready/final_v3',base); r.render=fd13_render(d,plots);
    r.figures=fd13_figcheck(root,d,plots); paper_json(fullfile(dest,'validation.json'),r); disp(r);
end
