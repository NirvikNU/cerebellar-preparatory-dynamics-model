function receipt=validate_submission_graphics(publicationFolder,receiptFile)
    % Fixed approved RGBA sites and complete scientific/native graph validation.
    root=fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(root,'analysis/paper_ready/final_v3/production'));
    addpath(fullfile(root,'analysis/paper_ready/final_v3/submission_statistics'));
    source=fullfile(root,'data/paper_ready/final_v3/submission_statistics_20261021');
    folder=fullfile(source,'consolidated_graphics');
    proposal=fullfile(folder,'PROPOSED_CONSOLIDATED_GRAPHICAL_POLICY.json');
    expected='98B575FDC9E76E7FE294941B1A112B0DE535127CDD269FAD401EE62476AF08A8';
    assert(~isfile(receiptFile),'Preserve existing receipt.');
    assert(strcmp(sha(bytes(proposal),'SHA-256'),expected),'Submission:PolicyHash');
    rule=jsondecode(fileread(proposal));approval=jsondecode(fileread(fullfile(folder,'approval.json')));
    assert(strcmp(approval.approvedSHA256,expected)&&~approval.automaticExpansion);
    assert(~rule.enabled&&numel(rule.outputs)==13);
    manifest=jsondecode(fileread(fullfile(source,'source_manifest.json')));
    for j=1:numel(manifest.files)
        item=manifest.files(j);
        assert(strcmp(sha(bytes(fullfile(root,item.path)),'SHA-256'),item.sha256), ...
            'Submission:SourceHash','Changed packaged source: %s',item.path);
    end
    for j=1:numel(rule.pinnedScientificSources)
        item=rule.pinnedScientificSources(j);data=bytes(fullfile(root,item.path));
        prefix=uint8(sprintf('blob %d%c',numel(data),0)).';
        assert(strcmpi(sha([prefix;data],'SHA-1'),item.gitBlobObjectID), ...
            'Submission:CommittedSource','Source bytes differ from committed Git blob: %s',item.path);
    end
    assert(strcmp(version,rule.qualifiedEnvironment.matlab),'Submission:MATLABEnvironment');
    assert(get(groot,'ScreenPixelsPerInch')==rule.qualifiedEnvironment.screenPixelsPerInch);
    dest=[receiptFile '.evidence'];assert(~isfolder(dest));mkdir(dest);rows=cell(13,1);
    try
        for j=1:13
            item=rule.outputs(j);name=item.name;
            png=fullfile(publicationFolder,'figures/png',[name '.png']);
            reference=fullfile(folder,'png',[name '.png']);
            assert(strcmp(sha(bytes(reference),'SHA-256'),item.referenceFileSHA256));
            base=rgba(reference);actual=rgba(png);
            assert(strcmpi(pixelsha(base),item.referenceDecodedRGBA_SHA256));
            [ok,changes]=assess(base,actual,item);
            assert(ok,'Submission:UnapprovedRaster','Unapproved pixel/dimension in %s',name);
            negativeTests(base,item);
            file=fullfile(publicationFolder,'figures/fig',[name '.fig']);beforeBytes=bytes(file);
            close all force;f=hgload(file,struct('Visible','off'));drawnow;
            snapshot=pf_snapshot(f);graph=native(f,file);
            axesHandles=findall(f,'Type','axes');environment=rendererinfo(axesHandles(1));
            assert(isequaln(environment,rule.qualifiedEnvironment.renderer),'Submission:RendererEnvironment');
            assert(strcmp(f.GraphicsSmoothing,rule.qualifiedEnvironment.graphicsSmoothing));
            assert(strcmp(f.Renderer,'opengl')&&strcmp(f.RendererMode,'auto'));
            panels={};if j>11,panels=f.UserData.panels;end
            close(f);
            saved=load(fullfile(folder,'native',[name '.mat']),'snapshot','graph');
            comparisonSnapshot=snapshot;comparisonGraph=graph;
            if j>11
                [comparisonSnapshot,comparisonGraph]=submission_textures(snapshot,graph,fullfile(publicationFolder,'figures'),panels);
            end
            differences=submission_compare(saved.graph,comparisonGraph,'allNativeProperties');
            pf_json(fullfile(dest,[name '_native.json']),struct('scientificExact',isequaln(saved.snapshot,comparisonSnapshot),'differences',{differences}));
            assert(isequaln(saved.snapshot,comparisonSnapshot)&&isempty(differences), ...
                'Submission:NativeMismatch','Native scientific or graphical content differs: %s',name);
            copy=hgload(file,struct('Visible','off'));drawnow;
            assert(isequaln(snapshot,pf_snapshot(copy))&&isequaln(graph,native(copy,file)));
            repeat=fullfile(dest,[name '_independent.png']);
            exportgraphics(copy,repeat,'Resolution',160);close(copy);
            assert(isequal(beforeBytes,bytes(file)),'Submission:CanonicalChanged');
            [repeatOK,repeatChanges]=assess(base,rgba(repeat),item);
            assert(repeatOK,'Submission:UnapprovedRaster','Unapproved separate-instance export in %s',name);
            close all force;after=hgload(file,struct('Visible','off'));drawnow;
            assert(isequaln(snapshot,pf_snapshot(after))&&isequaln(graph,native(after,file)), ...
                'Submission:ReadbackMismatch','Native figure changed after separate export: %s',name);close(after);
            rows{j}=struct('output',name,'status','PASS','dimensionsWH',item.dimensionsWH, ...
                'changedPixelCount',changes,'separateExportChangedPixelCount',repeatChanges, ...
                'pixelSHA256',pixelsha(actual),'separateExportPixelSHA256',pixelsha(rgba(repeat)), ...
                'allNativePropertiesExact',true,'nativeGraphNodes',numel(graph.handleNodes), ...
                'canonicalFIGBytesUnchanged',true,'separateExportReadbackExact',true, ...
                'assemblyTexturesVerified',j>11,'environment',environment);
            pf_json(fullfile(dest,[name '_receipt.json']),rows{j});
            fprintf('CONSOLIDATED GRAPHICS PASS: %s, %d approved changed pixels\n',name,changes);
        end
    catch problem
        pf_json([receiptFile '.failure.json'],struct('status','FAIL','output',name,'identifier',problem.identifier,'message',problem.message));
        rethrow(problem);
    end
    receipt=struct('status','PASS','approvedPolicySHA256',expected,'outputs',{vertcat(rows{:})}, ...
        'sourceFilesChecked',numel(manifest.files),'committedBlobPinsExact',numel(rule.pinnedScientificSources), ...
        'fullNativeContentExact',true,'fixedSiteFullRGBAPalettesOnly',true,'automaticExpansion',false, ...
        'strictOutsideMask',true,'exactDimensions',true,'matlab',version);
    pf_json(receiptFile,receipt);
end

function graph=native(f,file)
    graph=submission_graph(f);actual=graph.handleNodes{1}.properties.FileName;
    assert(strcmpi(strrep(actual,'\','/'),strrep(file,'\','/')),'Submission:NativeSourcePath');
    graph.handleNodes{1}.properties.FileName='<independently verified source path>';
end

function [ok,count]=assess(base,actual,item)
    ok=false;count=NaN;
    if ~isequal(size(base),size(actual))||~isequal([size(actual,2) size(actual,1)],item.dimensionsWH(:).'),return;end
    changed=any(base~=actual,3);count=nnz(changed);
    if count>item.maximumPermittedChangedPixels,return;end
    for k=1:numel(item.permittedSites)
        s=item.permittedSites(k);y=s.y+1;x=s.x+1;value=reshape(actual(y,x,:),1,4);
        if ~ismember(double(value),s.observedRGBA,'rows'),return;end
        changed(y,x)=false;
    end
    ok=~any(changed,'all');
end

function negativeTests(base,item)
    changed=base;changed(1,1,1)=bitxor(changed(1,1,1),uint8(1));assert(~assess(base,changed,item));
    assert(~assess(base,base(1:end-1,:,:),item));
    if ~isempty(item.permittedSites)
        s=item.permittedSites(1);changed=base;changed(s.y+1,s.x+1,4)=254;assert(~assess(base,changed,item));
        changed=base;
        for r=0:255
            v=[r 0 0 255];if ~ismember(v,s.observedRGBA,'rows'),break;end
        end
        changed(s.y+1,s.x+1,:)=uint8(v);assert(~assess(base,changed,item));
    end
end

function value=rgba(file)
    [rgb,map,alpha]=imread(file);assert(isempty(map),'Indexed raster outside measured environment.');
    if size(rgb,3)==1,rgb=repmat(rgb,1,1,3);end
    assert(isa(rgb,'uint8')&&size(rgb,3)==3);
    if isempty(alpha),alpha=repmat(uint8(255),size(rgb,1),size(rgb,2));end
    assert(isa(alpha,'uint8'));value=cat(3,rgb,alpha);
end

function value=pixelsha(data)
    ordered=permute(data,[3 2 1]);value=sha(ordered(:),'SHA-256');
end

function value=sha(data,algorithm)
    md=java.security.MessageDigest.getInstance(algorithm);md.update(data);
    value=upper(reshape(dec2hex(typecast(md.digest(),'uint8'),2).',1,[]));
end

function data=bytes(file)
    fid=fopen(file,'rb');assert(fid>=0);guard=onCleanup(@()fclose(fid));data=fread(fid,Inf,'*uint8');
end
