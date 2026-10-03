function r=sp10_finish_display(root)
    % Presentation-only title repair; reuse completed display source arrays.
    addpath(fullfile(root,'analysis/paper_ready'),fullfile(root,'analysis/paper_ready/prospective_variability'));
    folder='fig6fgh_success10'; docs=fullfile(root,'docs/paper_ready/final_v3',folder);
    files=dir(fullfile(root,'analysis/paper_ready/final_v3',folder,'*.m')); messages={};
    for file=files.'
        issues=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(issues), messages{end+1}=struct('file',file.name,'issues',issues); end %#ok<AGROW> Bounded file list.
    end
    assert(isempty(messages));
    paper_json(fullfile(docs,'code_analyzer_final.json'),struct('files',numel(files),'messages',{messages}));
    z=load(fullfile(root,'results/paper_ready/final_v3',folder,'display_sources.mat'),'d');
    plots=fullfile(root,'plots/paper_ready/final_v3',folder);
    r=sp10_render(z.d,plots); r.audit=sp10_figcheck(root,z.d,plots);
    paper_json(fullfile(root,'results/paper_ready/final_v3',folder,'render_validation_final.json'),r);
end
