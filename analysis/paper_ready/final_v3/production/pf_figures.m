function receipt=pf_figures(root,outputRoot)
    source=fullfile(root,'data/paper_ready/final_v3');
    if isfolder(outputRoot)
        previous=dir(outputRoot);
        assert(all(ismember({previous.name},{'.','..'})), ...
            'Production:ExistingOutput','Choose a new empty output directory; preserve previous evidence.');
    end
    for sub={'fig','png','source'}, d=fullfile(outputRoot,sub{1}); if ~isfolder(d), mkdir(d); end, end
    names=[arrayfun(@(c)['Fig6' c],'a':'h','UniformOutput',false) arrayfun(@(c)['ED5' c],'a':'c','UniformOutput',false)];
    receipt=struct('status','RUNNING','panels',{{}},'matlab',version,'sourceObjectsVerified',0);
    for k=1:numel(names)
        name=names{k};
        fig=fullfile(outputRoot,'fig',[name '.fig']); png=fullfile(outputRoot,'png',[name '.png']);
        master=fullfile(root,'plots/paper_ready/final_v3/production/fig',[name '.fig']);
        copyfile(master,fig);
        if strcmp(name,'Fig6c')
            copyfile(fullfile(root,'plots/paper_ready/final_v3/production/png',[name '.png']),png);
        else
            z=load(fullfile(source,[name '_graphics.mat']),'recipe');
            receipt.exports.(name)=pf_export_png(fig,png,z.recipe.size);
        end
        reopened=hgload(fig,struct('Visible','off'));drawnow;
        if ~strcmp(name,'Fig6c')
            actual=pf_snapshot(reopened); expected=z.recipe;
            assert(numel(actual.axes)==numel(expected.axes));
            for j=1:numel(expected.axes)
                aa=actual.axes{j}.objects; ee=expected.axes{j}.objects;
                assert(numel(aa)==numel(ee));
                for q=1:numel(ee)
                    assert(strcmp(aa{q}.type,ee{q}.type));
                    for field={'XData','YData','ZData','CData','YPositiveDelta','YNegativeDelta','Value'}
                        if isfield(ee{q}.properties,field{1})
                            assert(isequaln(aa{q}.properties.(field{1}),ee{q}.properties.(field{1})), ...
                                'Production:ObjectMismatch','%s object %d field %s',name,q,field{1});
                        end
                    end
                    receipt.sourceObjectsVerified=receipt.sourceObjectsVerified+1;
                end
                assert(isequal(actual.axes{j}.xlabel,expected.axes{j}.xlabel) && isequal(actual.axes{j}.ylabel,expected.axes{j}.ylabel));
            end
        end
        close(reopened); info=imfinfo(png);
        reference=fullfile(root,'plots/paper_ready/final_v3/production/png',[name '.png']);
        receipt.rasters.(name)=pf_check_raster(name,rgba(reference),rgba(png));
        receipt.panels{end+1}=struct('panel',name,'width',info.Width,'height',info.Height);
    end
    assemble(root,outputRoot,'Figure_6',names(1:8),[.015 .665 .245 .32;.265 .665 .245 .32;.53 .36 .46 .63; ...
        .015 .36 .50 .30;.015 .015 .235 .315;.265 .015 .235 .315;.515 .015 .235 .315;.76 .015 .235 .315],[2200 1700]);
    assemble(root,outputRoot,'Extended_Data_Figure_5',names(9:11),[.015 .52 .47 .46;.515 .52 .47 .46;.015 .02 .47 .46],[1800 1500]);
    sourceTables=dir(fullfile(source,'tables','*'));
    for k=1:numel(sourceTables)
        if ~sourceTables(k).isdir
            src=fullfile(sourceTables(k).folder,sourceTables(k).name); dst=fullfile(outputRoot,'source',sourceTables(k).name);
            copyfile(src,dst); assert(isequal(fileread(src),fileread(dst)));
        end
    end
    receipt.sourceAudit=pf_validate_sources(source);
    receipt.status='PASS'; receipt.panelCount=11; receipt.assemblyCount=2;
    pf_json(fullfile(outputRoot,'validation.json'),receipt);
    fprintf('PAPER FIGURES PASS: 11 panels, 2 assemblies, %d exact native data objects.\n',receipt.sourceObjectsVerified);
end

function assemble(root,folder,name,panels,positions,sz)
    f=figure('Visible','off','Color','w','Position',[10 10 sz]);
    for k=1:numel(panels)
        panelPNG=fullfile(folder,'png',[panels{k} '.png']);
        if strcmp(panels{k},'ED5b')
            canonical=fullfile(root,'plots/paper_ready/final_v3/production/png/ED5b.png');
            pf_check_raster('ED5b',rgba(canonical),rgba(panelPNG));
            panelPNG=canonical;
        end
        ax=axes(f,'Position',positions(k,:)); image(ax,imread(panelPNG)); axis(ax,'image'); axis(ax,'off');
        if ~strcmp(panels{k},'Fig6c')
            pos=positions(k,:); annotation(f,'textbox',[pos(1) pos(2)+pos(4)-.035 .03 .035], ...
                'String',[panels{k}(end) '.'],'FontName','Arial','FontSize',24,'FontWeight','bold','EdgeColor','none');
        end
    end
    f.UserData=struct('assembly',name,'panels',{panels},'nativePanelMasters','fig/');
    assert(isequal(f.Position(3:4),sz),'Production:AssemblyCanvas');
    file=fullfile(folder,'fig',[name '.fig']);savefig(f,file);close(f);
    pf_export_png(file,fullfile(folder,'png',[name '.png']),sz);
    f=hgload(file,struct('Visible','off'));assert(numel(findall(f,'Type','image'))==numel(panels));close(f);
end

function out=rgba(file)
    [rgb,map,alpha]=imread(file);assert(isempty(map));
    if size(rgb,3)==1,rgb=repmat(rgb,1,1,3);end
    if isempty(alpha),alpha=repmat(uint8(255),size(rgb,1),size(rgb,2));end
    out=cat(3,rgb,alpha);
end
