function receipt=ns_static(root,label)
    cfg=ns_paths(root); path=fullfile(cfg.manifest,['static_' label '.json']); assert(~isfile(path));
    files=[dir(fullfile(root,'analysis','paper_ready','noise_sensitivity','*.m'));dir(fullfile(root,'figures','paper_ready','noise_sensitivity','*.m'))];
    receipt.files=cell(numel(files),1); receipt.messages=cell(numel(files),1);
    for j=1:numel(files)
        file=fullfile(files(j).folder,files(j).name); source=fileread(file); assert(isempty(regexp(source,'(?m)^\s*%%','once')));
        receipt.files{j}=file; receipt.messages{j}=checkcode(file,'-id');
    end
    receipt.status='PASS'; if ~all(cellfun(@isempty,receipt.messages)), receipt.status='REVIEW_MESSAGES'; end
    paper_json(path,receipt); disp(receipt.messages);
end
