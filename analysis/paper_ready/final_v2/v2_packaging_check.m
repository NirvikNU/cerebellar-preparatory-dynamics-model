function receipt=v2_packaging_check(root)
    % Read-only source/path checks for the newly included release bundles.
    cfg=v2_paths(root); path=fullfile(cfg.manifest,'packaging_static.json'); assert(~isfile(path));
    files=[dir(fullfile(root,'analysis','paper_ready','final_v2','*.m')); ...
        dir(fullfile(root,'figures','paper_ready','final_v2','*.m')); ...
        dir(fullfile(root,'analysis','paper_ready','noise_sensitivity','*.m')); ...
        dir(fullfile(root,'figures','paper_ready','noise_sensitivity','*.m'))];
    receipt.files=cell(numel(files),1); receipt.messages=receipt.files;
    for j=1:numel(files)
        file=fullfile(files(j).folder,files(j).name);
        receipt.files{j}=strrep(erase(file,[root filesep]),filesep,'/');
        assert(isempty(regexp(fileread(file),'(?m)^\s*%%','once')));
        receipt.messages{j}=checkcode(file,'-id');
    end
    entries={'v2_grid','v2_convergence','v2_simulate','v2_analyze','v2_audit','v2_output_audit', ...
        'paper_prepare','paper_noise','paper95_geometry','paper95_direct','pe_features', ...
        'stage3_prediction_ridge','stage3_prediction_folds','stage2_bootstrap','eta_move','ns_controls'};
    receipt.resolved=cell(numel(entries),2);
    for j=1:numel(entries)
        file=which(entries{j}); assert(startsWith(file,[root filesep]));
        assert(~contains(lower(file),'archive'));
        receipt.resolved(j,:)={entries{j},strrep(erase(file,[root filesep]),filesep,'/')};
    end
    receipt.status='PASS';
    if ~all(cellfun(@isempty,receipt.messages)), receipt.status='REVIEW_MESSAGES'; end
    receipt.scientificFunctionsExecuted=false; paper_json(path,receipt);
    assert(strcmp(receipt.status,'PASS'),'Packaging:Analyzer','Review Code Analyzer messages before release.');
end
