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
        if strcmp(panel.panel,'Fig6c')
            schematic=imfinfo(fullfile(root,'data/paper_ready/final_v3/Fig6c_schematic.png'));
            canvas=[schematic.Width schematic.Height];
        else
            spec=load(fullfile(root,'data/paper_ready/final_v3',[panel.panel '_graphics.mat']),'recipe');
            canvas=spec.recipe.size;
        end
        a=pf_read_native(fullfile(root,panel.nativeFigure),canvas);
        expectedSnapshot=pf_snapshot(a);close(a);
        b=pf_read_native(fullfile(outputRoot,'figures/fig',[panel.panel '.fig']),canvas);
        assert(isequaln(expectedSnapshot,pf_snapshot(b)), ...
            'Publication:MasterMismatch','Native data/style/annotation mismatch: %s',panel.panel);
        close(b);
        canonical=imfinfo(fullfile(root,panel.png));
        generated=imfinfo(fullfile(outputRoot,'figures/png',[panel.panel '.png']));
        dimensionsExact=isequal([canonical.Width canonical.Height],[generated.Width generated.Height]);
        assert(dimensionsExact,'Publication:RasterSize','Image dimensions differ: %s',panel.panel);
        receipt.masterChecks{j}=struct('panel',panel.panel,'nativeSnapshotExact',true, ...
            'width',generated.Width,'height',generated.Height,'masterWidth',canonical.Width, ...
            'masterHeight',canonical.Height,'rasterDimensionsExact',dimensionsExact);
    end
    receipt.sourceTables=0;
    files=dir(fullfile(root,'data/paper_ready/final_v3/tables','*'));
    for j=1:numel(files)
        if files(j).isdir, continue; end
        a=bytes(fullfile(files(j).folder,files(j).name));
        b=bytes(fullfile(outputRoot,'figures/source',files(j).name));
        assert(isequal(a,b)); receipt.sourceTables=receipt.sourceTables+1;
    end
    assert(receipt.sourceTables==26);
    for name={'Figure_6','Extended_Data_Figure_5'}
        a=openfig(fullfile(outputRoot,'figures/fig',[name{1} '.fig']),'invisible');
        assert(all(ismember(a.UserData.panels,{manifest.panels.panel})));
        if strcmp(name{1},'Extended_Data_Figure_5'), assert(isequal(a.UserData.panels,{'ED5a','ED5b','ED5c'})); end
        close(a);
    end
    [mfiles,mexfiles]=inmem('-completenames'); loaded=[mfiles(:);mexfiles(:)];
    assert(all(startsWith(loaded,root)|startsWith(loaded,matlabroot)), ...
        'Publication:Dependency','Loaded code outside the clone or MathWorks installation.');
    receipt.loadedCode=loaded; receipt.matlab=version; receipt.toolboxes=ver;
    receipt.notExecuted={'Full ten-network stochastic replay','Full ten-network geometry replay'};
    receipt.status='PASS'; pf_json(fullfile(outputRoot,'validation.json'),receipt);
    fprintf('PUBLICATION VALIDATION PASS: 11 panels, 2 assemblies, 26 tables, actual 480-trial model check.\n');
end

function data=bytes(file)
    fid=fopen(file,'rb');assert(fid>=0);cleanup=onCleanup(@()fclose(fid));
    data=fread(fid,Inf,'*uint8');
end
