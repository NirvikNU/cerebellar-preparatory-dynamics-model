function receipt=validate_publication(outputRoot)
    % Fresh-clone acceptance: rendering is distinct from actual bounded replay.
    root=fileparts(fileparts(mfilename('fullpath')));
    if nargin<1, outputRoot=fullfile(root,'generated/publication_validation'); end
    assert(~isfolder(outputRoot),'Use a new output directory; preserve prior evidence.');
    restoredefaultpath;
    addpath(root);
    receipt.figures=run_paper_figures(fullfile(outputRoot,'figures'));
    receipt.model=run_paper_model('check',fullfile(outputRoot,'model'));
    addpath(fullfile(root,'analysis/paper_ready/final_v3/production'));
    receipt.static=pf_static(root,fullfile(outputRoot,'code_analyzer.json'));
    assert(isempty(checkcode(mfilename('fullpath'),'-id')));
    manifest=jsondecode(fileread(fullfile(root,'data/paper_ready/final_v3/production_manifest.json')));
    assert(numel(manifest.panels)==11 && receipt.figures.panelCount==11);
    receipt.masterChecks=cell(1,11);
    for j=1:11
        panel=manifest.panels(j);
        a=openfig(fullfile(root,panel.nativeFigure),'invisible');
        b=openfig(fullfile(outputRoot,'figures/fig',[panel.panel '.fig']),'invisible');
        assert(isequaln(pf_snapshot(a),pf_snapshot(b)), ...
            'Publication:MasterMismatch','Native data/style/annotation mismatch: %s',panel.panel);
        close(a); close(b);
        canonical=imfinfo(fullfile(root,panel.png));
        generated=imfinfo(fullfile(outputRoot,'figures/png',[panel.panel '.png']));
        % Raster crop/antialiasing can depend on the graphics environment.
        % Record it separately from the exact native scientific/style comparison.
        dimensionsExact=isequal([canonical.Width canonical.Height],[generated.Width generated.Height]);
        if ~dimensionsExact
            warning('Publication:RasterSize','%s export %dx%d; master %dx%d. Inspect PNG; native snapshot matched.', ...
                panel.panel,generated.Width,generated.Height,canonical.Width,canonical.Height);
        end
        receipt.masterChecks{j}=struct('panel',panel.panel,'nativeSnapshotExact',true, ...
            'width',generated.Width,'height',generated.Height,'masterWidth',canonical.Width, ...
            'masterHeight',canonical.Height,'rasterDimensionsExact',dimensionsExact);
    end
    receipt.sourceTables=0;
    files=dir(fullfile(root,'data/paper_ready/final_v3/tables','*'));
    for j=1:numel(files)
        if files(j).isdir, continue; end
        a=fileread(fullfile(files(j).folder,files(j).name));
        b=fileread(fullfile(outputRoot,'figures/source',files(j).name));
        assert(isequal(a,b)); receipt.sourceTables=receipt.sourceTables+1;
    end
    assert(receipt.sourceTables==24);
    for name={'Figure_6','Extended_Data_Figure_7'}
        a=openfig(fullfile(outputRoot,'figures/fig',[name{1} '.fig']),'invisible');
        assert(~any(strcmp(a.UserData.panels,'ED7d')));
        if strcmp(name{1},'Extended_Data_Figure_7'), assert(isequal(a.UserData.panels,{'ED7a','ED7b','ED7c'})); end
        close(a);
    end
    [mfiles,mexfiles]=inmem('-completenames'); loaded=[mfiles(:);mexfiles(:)];
    assert(all(startsWith(loaded,root)|startsWith(loaded,matlabroot)), ...
        'Publication:Dependency','Loaded code outside the clone or MathWorks installation.');
    receipt.loadedCode=loaded; receipt.matlab=version; receipt.toolboxes=ver;
    receipt.notExecuted={'Full ten-network stochastic replay','Full ten-network geometry replay'};
    receipt.status='PASS'; pf_json(fullfile(outputRoot,'validation.json'),receipt);
    fprintf('PUBLICATION VALIDATION PASS: 11 panels, 2 assemblies, 24 tables, actual 480-trial model check.\n');
end
