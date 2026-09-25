function receipt=v2_preflight(root)
    cfg=v2_paths(root); path=fullfile(cfg.dest,'preflight.json'); assert(~isfile(path));
    files=dir(fullfile(root,'analysis','paper_ready','final_v2','*.m'));
    receipt.static=cell(numel(files),1);
    for j=1:numel(files)
        file=fullfile(files(j).folder,files(j).name); receipt.static{j}=checkcode(file,'-id');
        for message=receipt.static{j}.'
            fprintf('%s:%d %s %s\n',files(j).name,message.line,message.id,message.message);
        end
        assert(isempty(regexp(fileread(file),'(?m)^\s*%%','once')));
    end
    assert(all(cellfun(@isempty,receipt.static)),'Review Code Analyzer messages before production.');
    for n=1:10
        s=load(fullfile(cfg.cacheRoot,sprintf('grid_%02d.mat',n)),'definitions');
        assert(isequal(size(s.definitions),[3 36])); d=s.definitions(1,:);
        a=cellfun(@(x)x.alpha,d); b=cellfun(@(x)x.betaNormalized,d);
        assert(isequal(unique(a),cfg.alpha) && isequal(unique(b),cfg.beta));
        s=load(fullfile(cfg.paper,'cache','alignment95',sprintf('controls_n%02d.mat',n)),'c');
        assert(s.c.lambda==10 && norm(s.c.L-s.c.P/10,'fro')<1e-12);
    end
    receipt.status='PASS'; receipt.onlyGeometryProductionAuthorized=true;
    paper_json(path,receipt);
end
