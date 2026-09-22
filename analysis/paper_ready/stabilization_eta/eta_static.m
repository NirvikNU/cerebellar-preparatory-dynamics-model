function receipt = eta_static(root)
    folders={fullfile(root,'analysis','paper_ready','stabilization_eta'),fullfile(root,'figures','paper_ready','stabilization_eta')};
    receipt=struct('files',{{}},'messages',{{}},'status','PASS');
    for folder=folders
        files=dir(fullfile(folder{1},'*.m'));
        for j=1:numel(files)
            path=fullfile(files(j).folder,files(j).name); messages=checkcode(path,'-id');
            receipt.files{end+1}=path; receipt.messages{end+1}=messages;
            if ~isempty(messages), receipt.status='FAIL'; fprintf('%s\n%s\n',path,jsonencode(messages)); end
        end
    end
    disp(receipt.status);
end
