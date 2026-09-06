function receipt = validate_stage2_outputs(cfg)
    % Final bounded checks from saved outputs; no model re-simulation.
    saved=load(fullfile(cfg.resultsRoot,'analysis.mat'),'out'); o=saved.out;
    assert(isequal(o.cfg,cfg),'Saved figure configuration differs.');
    assert(isequal(cfg.lambda,[.1 .2 .5 1 2 5 10 100]));
    assert(cfg.pcCount==15 && cfg.nullDraws==1000 && cfg.bootstrapDraws==10000);
    one=stage2_signflip(ones(10,1),o.bootstrapIndices);
    zero=stage2_signflip(zeros(10,1),o.bootstrapIndices);
    assert(one.p==2/1024 && zero.p==1);
    bh=stage2_bh([.01 .04 .03 .2]);
    assert(max(abs(bh-[.04 .0533333333333333 .0533333333333333 .2]))<1e-12);
    assert(all(isfinite(o.pr),'all') && all(isfinite(o.observed),'all'));
    assert(all(o.observed>=-1e-10 & o.observed<=1+1e-8,'all'));
    assert(max(abs(o.observed(:,1)-1))<1e-10);
    before=readtable(fullfile(cfg.resultsRoot,'protected_before.csv'),'TextType','string');
    for j=1:height(before)
        assert(sha256_file(fullfile(cfg.projectRoot,before.relative_path(j)))==before.sha256(j));
    end
    files=[dir(fullfile(cfg.projectRoot,'src','stage_2','*.m')); ...
        dir(fullfile(cfg.projectRoot,'analysis','stage_2','*.m')); ...
        dir(fullfile(cfg.projectRoot,'figures','stage_2','*.m')); ...
        dir(fullfile(cfg.projectRoot,'config','stage_2_config.m')); ...
        dir(fullfile(cfg.projectRoot,'run_stage_2.m'))];
    issues=struct('file',{},'line',{},'id',{},'message',{});
    for j=1:numel(files)
        path=fullfile(files(j).folder,files(j).name);
        assert(isempty(regexp(fileread(path),'(?m)^\s*%%','once')));
        found=checkcode(path,'-id');
        for k=1:numel(found)
            issueId='';
            if isfield(found,'id'), issueId=found(k).id; end
            issues(end+1)=struct('file',files(j).name,'line',found(k).line, ...
                'id',issueId,'message',found(k).message); %#ok<AGROW>
        end
    end
    pngs=dir(fullfile(cfg.plotsPngRoot,'*.png'));
    figs=dir(fullfile(cfg.plotsFigRoot,'*.fig'));
    assert(numel(pngs)==5 && numel(figs)==5);
    assert(isequal(sort(erase(string({pngs.name}),'.png')),sort(erase(string({figs.name}),'.fig'))));
    for j=1:5
        pixels=imread(fullfile(pngs(j).folder,pngs(j).name));
        assert(size(pixels,1)>500 && size(pixels,2)>500 && std(double(pixels(:)))>1);
    end
    cacheFiles=dir(fullfile(cfg.cacheRoot,'network_*.mat'));
    assert(numel(cacheFiles)==10);
    names=strings(10,1); sizes=zeros(10,1); hashes=strings(10,1);
    for j=1:10
        names(j)=string(cacheFiles(j).name);
        sizes(j)=cacheFiles(j).bytes;
        hashes(j)=sha256_file(fullfile(cacheFiles(j).folder,cacheFiles(j).name));
    end
    writetable(table(names,sizes,hashes,'VariableNames',{'CacheFile','Bytes','SHA256'}), ...
        fullfile(cfg.resultsRoot,'cache_manifest.csv'));
    currentFiles=hash_tree(cfg.projectRoot,["src/stage_2" "analysis/stage_2" ...
        "figures/stage_2" "config/stage_2_config.m" "run_stage_2.m" ...
        "plots/stage_2" "artifacts/manifests/stage2_lambda_sweep/PREREGISTRATION.md"]);
    currentFiles=currentFiles(~endsWith(lower(currentFiles.relative_path),'desktop.ini'),:);
    writetable(currentFiles,fullfile(cfg.resultsRoot,'code_figure_manifest.csv'));
    receipt=struct('status','PASS','protectedFilesUnchanged',height(before), ...
        'codeAnalyzerFiles',numel(files),'codeAnalyzerIssues',{issues}, ...
        'figurePairs',5,'pngsReopened',5,'exactSignflipSanity',true,'bhSanity',true, ...
        'cacheFilesHashed',10,'matlabVersion',version);
    fid=fopen(fullfile(cfg.resultsRoot,'final_validation.json'),'w');
    assert(fid>0); cleanup=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',jsonencode(receipt,PrettyPrint=true));
    disp(receipt);
    if ~isempty(issues), disp(struct2table(issues)); end
end
