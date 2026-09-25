function receipt=v2_static(root,label)
    cfg=v2_paths(root); path=fullfile(cfg.manifest,['static_' label '.json']); assert(~isfile(path));
    files=[dir(fullfile(root,'analysis','paper_ready','final_v2','*.m'));dir(fullfile(root,'figures','paper_ready','final_v2','*.m'))];
    receipt.files=cell(numel(files),1); receipt.messages=receipt.files;
    for j=1:numel(files)
        file=fullfile(files(j).folder,files(j).name); receipt.files{j}=files(j).name;
        assert(isempty(regexp(fileread(file),'(?m)^\s*%%','once')));
        receipt.messages{j}=checkcode(file,'-id');
        for message=receipt.messages{j}.'
            fprintf('%s:%d %s %s\n',files(j).name,message.line,message.id,message.message);
        end
    end
    receipt.status='PASS'; if ~all(cellfun(@isempty,receipt.messages)), receipt.status='REVIEW_MESSAGES'; end
    paper_json(path,receipt);
end
