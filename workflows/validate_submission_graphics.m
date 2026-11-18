function receipt=validate_submission_graphics(publicationFolder,receiptFile)
    % Strict comparison of the authorized manuscript presentation and native content.
    root=fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(root,'analysis/paper_ready/final_v3/production'));
    addpath(fullfile(root,'analysis/paper_ready/final_v3/submission_statistics'));
    assert(isempty(checkcode(mfilename('fullpath'),'-id')),'Publication:CodeAnalyzer','Code Analyzer found issues.');
    assert(~isfile(receiptFile),'Preserve an existing validation receipt.');
    manifest=jsondecode(fileread(fullfile(root,'data/paper_ready/final_v3/submission_statistics_20261021/source_manifest.json')));
    for j=1:numel(manifest.files)
        item=manifest.files(j);
        assert(strcmp(sha(bytes(fullfile(root,item.path))),item.sha256),'Publication:SourceHash','Changed packaged source %s',item.path);
    end
    names=[arrayfun(@(c)['Fig6' c],'a':'h','UniformOutput',false), ...
        arrayfun(@(c)['ED5' c],'a':'c','UniformOutput',false),{'Figure_6','Extended_Data_Figure_5'}];
    dest=[receiptFile '.evidence'];assert(~isfolder(dest));mkdir(dest);
    rows=cell(1,13);
    for j=1:13
        name=names{j};
        master=fullfile(root,'plots/paper_ready/final_v3/production/fig',[name '.fig']);
        actual=fullfile(publicationFolder,'figures/fig',[name '.fig']);
        before=bytes(actual);
        masterBytes=bytes(master);
        if strcmp(name,'Fig6c')
            schematic=imfinfo(fullfile(root,'data/paper_ready/final_v3/Fig6c_schematic.png'));
            canvas=[schematic.Width schematic.Height];
        elseif j<=11
            spec=load(fullfile(root,'data/paper_ready/final_v3',[name '_graphics.mat']),'recipe');
            canvas=spec.recipe.size;
        elseif strcmp(name,'Figure_6')
            canvas=[2200 1700];
        else
            canvas=[1800 1500];
        end
        if j<=11,assert(isequal(before,masterBytes),'Publication:NativeBytes','Native template bytes differ %s',name);end
        close all force;f=pf_read_native(master,canvas);
        expected=pf_snapshot(f);expectedGraph=pf_native_graph(f,master);close(f);
        f=pf_read_native(actual,canvas);
        observed=pf_snapshot(f);observedGraph=pf_native_graph(f,actual);
        [differences,editorBefore,rawBefore]=pf_compare_native(root,name,expectedGraph,observedGraph,master,actual);
        close(f);
        pf_json(fullfile(dest,[name '_native.json']),struct('snapshotExact',isequaln(expected,observed), ...
            'rawDifferences',{rawBefore},'approvedEditorMetadata',{editorBefore},'remainingDifferences',{differences}));
        assert(isequaln(expected,observed)&&isempty(differences),'Publication:NativeMismatch','Native content or properties differ %s',name);
        reference=fullfile(root,'plots/paper_ready/final_v3/production/png',[name '.png']);
        png=fullfile(publicationFolder,'figures/png',[name '.png']);
        a=rgba(reference);b=rgba(png);
        rasterCheck=pf_check_raster(name,a,b);
        repeat=fullfile(dest,[name '_independent.png']);
        if strcmp(name,'Fig6c')
            copyfile(reference,repeat);
        else
            pf_export_png(actual,repeat,canvas);
        end
        repeatCheck=pf_check_raster(name,b,rgba(repeat));
        f=pf_read_native(master,canvas);
        expectedAfter=pf_snapshot(f);expectedGraphAfter=pf_native_graph(f,master);close(f);
        f=pf_read_native(actual,canvas);
        axesList=findall(f,'Type','axes');environment=rendererinfo(axesList(1));
        postSnapshot=pf_snapshot(f);postGraph=pf_native_graph(f,actual);
        [postDifferences,editorAfter,rawAfter]=pf_compare_native(root,name,expectedGraphAfter,postGraph,master,actual);
        pf_json(fullfile(dest,[name '_post_native.json']),struct('snapshotExact',isequaln(expectedAfter,postSnapshot), ...
            'rawDifferences',{rawAfter},'approvedEditorMetadata',{editorAfter},'remainingDifferences',{postDifferences}));
        assert(isequaln(expectedAfter,postSnapshot)&&isempty(postDifferences), ...
            'Publication:NativeReadback','Post-export native content/properties differ %s',name);
        if j>11
            for k=1:numel(f.UserData.panels)
                panel=f.UserData.panels{k};panelPNG=fullfile(publicationFolder,'figures/png',[panel '.png']);
                if strcmp(panel,'ED5b')
                    canonical=fullfile(root,'plots/paper_ready/final_v3/production/png/ED5b.png');
                    pf_check_raster(panel,rgba(canonical),rgba(panelPNG));panelPNG=canonical;
                end
                im=imread(panelPNG);
                images=findall(f,'Type','image');found=false;
                for m=1:numel(images),found=found||isequal(images(m).CData,im);end
                assert(found,'Publication:AssemblyTexture','Assembly image differs %s',panel);
            end
        end
        close(f);assert(isequal(before,bytes(actual))&&isequal(masterBytes,bytes(master)));
        rows{j}=struct('panel',name,'nativeScientificAndOtherPropertiesExact',true,'nativeEditorMetadataAccepted',true, ...
            'allRuntimeNativePropertiesExact',isempty(rawBefore)&&isempty(rawAfter), ...
            'editorMetadataBefore',{editorBefore},'editorMetadataAfter',{editorAfter},'dimensionsWH',[size(b,2) size(b,1)], ...
            'decodedRGBAExact',rasterCheck.exact,'rasterAccepted',rasterCheck.accepted,'approvedPixels',rasterCheck.approvedPixels, ...
            'independentExportExact',repeatCheck.exact,'independentExportAccepted',repeatCheck.accepted,'repeatApprovedPixels',repeatCheck.approvedPixels, ...
            'canonicalUnchanged',true,'nativeGraphNodes',numel(observedGraph.handleNodes),'environment',environment);
        fprintf('STRICT GRAPHICS PASS %s\n',name);
    end
    receipt=struct('status','PASS','outputs',{rows},'sourceFilesChecked',numel(manifest.files), ...
        'exactOutsideApprovedED5bPixels',true,'dimensionsExact',true,'approvedED5bRule',pf_check_raster(), ...
        'nativeEditorRuleSHA256','4C034AC7626504AA55BEFE192D8D9DBA4675E42E46190569E36BEC6765266EC7', ...
        'assemblyEditorRuleSHA256','FF590FE555BF7049A4C068BF51BF07E5D65DBA7C50AE8663B379AEB51047AF3F', ...
        'runtimeEditorMetadataRecorded',true, ...
        'automaticToleranceExpansion',false,'matlab',version);
    pf_json(receiptFile,receipt);
end

function out=rgba(file)
    [rgb,map,alpha]=imread(file);assert(isempty(map));
    if size(rgb,3)==1,rgb=repmat(rgb,1,1,3);end
    if isempty(alpha),alpha=repmat(uint8(255),size(rgb,1),size(rgb,2));end
    out=cat(3,rgb,alpha);
end

function out=sha(data)
    md=java.security.MessageDigest.getInstance('SHA-256');md.update(data);
    out=upper(reshape(dec2hex(typecast(md.digest(),'uint8'),2).',1,[]));
end

function out=bytes(file)
    fid=fopen(file,'rb');assert(fid>=0);guard=onCleanup(@()fclose(fid));out=fread(fid,Inf,'*uint8');
end
