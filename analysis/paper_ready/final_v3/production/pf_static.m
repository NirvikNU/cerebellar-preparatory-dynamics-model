function receipt=pf_static(root,output)
    folder=fullfile(root,'analysis/paper_ready/final_v3/production'); files=dir(fullfile(folder,'*.m'));
    names=[arrayfun(@(f)fullfile(f.folder,f.name),files,'UniformOutput',false); ...
        {fullfile(root,'run_paper_figures.m');fullfile(root,'run_paper_model.m')}];
    issues={};
    for k=1:numel(names)
        found=checkcode(names{k},'-id');
        if ~isempty(found), issues{end+1}=struct('file',names{k},'issues',found); end %#ok<AGROW>
        if ~endsWith(names{k},'pf_static.m')
            body=fileread(names{k});
            assert(isempty(regexp(body,'[A-Z]:[/\\]|fig6f_random|fig6gh_fifteen|cache[/\\]|genpath','once')), ...
                'Production:HistoricalDependency','Nonportable production dependency');
        end
    end
    receipt=struct('status','PASS','files',numel(names),'issues',{issues});
    if ~isempty(issues), receipt.status='FAIL'; end
    pf_json(output,receipt); assert(isempty(issues),'Production:CodeAnalyzer','See static receipt');
end
