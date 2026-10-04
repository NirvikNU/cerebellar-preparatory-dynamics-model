function receipt=pf_figures(root,outputRoot)
    source=fullfile(root,'data/paper_ready/final_v3');
    for sub={'fig','png','source'}, d=fullfile(outputRoot,sub{1}); if ~isfolder(d), mkdir(d); end, end
    names=[arrayfun(@(c)['Fig6' c],'a':'h','UniformOutput',false) arrayfun(@(c)['ED7' c],'a':'d','UniformOutput',false)];
    receipt=struct('status','RUNNING','panels',{{}},'matlab',version,'sourceObjectsVerified',0);
    for k=1:numel(names)
        name=names{k};
        if strcmp(name,'Fig6c')
            im=imread(fullfile(source,'Fig6c_schematic.png'));
            f=figure('Visible','off','Color','w','Position',[30 30 size(im,2) size(im,1)]);
            ax=axes(f,'Position',[0 0 1 1]); image(ax,im); axis(ax,'image'); axis(ax,'off');
            f.UserData=struct('panel',name,'staticManuscriptAsset',true);
        else
            z=load(fullfile(source,[name '_graphics.mat']),'recipe'); f=pf_draw(z.recipe,name);
        end
        fig=fullfile(outputRoot,'fig',[name '.fig']); png=fullfile(outputRoot,'png',[name '.png']);
        drawnow; savefig(f,fig); exportgraphics(f,png,'Resolution',160); close(f);
        reopened=openfig(fig,'invisible');
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
        receipt.panels{end+1}=struct('panel',name,'width',info.Width,'height',info.Height);
    end
    assemble(outputRoot,'Figure_6',names(1:8),[.015 .665 .245 .32;.265 .665 .245 .32;.53 .36 .46 .63; ...
        .015 .36 .50 .30;.015 .015 .235 .315;.265 .015 .235 .315;.515 .015 .235 .315;.76 .015 .235 .315],[2200 1700]);
    assemble(outputRoot,'Extended_Data_Figure_7',names(9:12),[.015 .52 .47 .46;.515 .52 .47 .46;.015 .02 .47 .46;.515 .02 .47 .46],[1800 1500]);
    sourceTables=dir(fullfile(source,'tables','*'));
    for k=1:numel(sourceTables)
        if ~sourceTables(k).isdir
            src=fullfile(sourceTables(k).folder,sourceTables(k).name); dst=fullfile(outputRoot,'source',sourceTables(k).name);
            copyfile(src,dst); assert(isequal(fileread(src),fileread(dst)));
        end
    end
    receipt.sourceAudit=pf_validate_sources(source);
    receipt.status='PASS'; receipt.panelCount=12; receipt.assemblyCount=2;
    pf_json(fullfile(outputRoot,'validation.json'),receipt);
    fprintf('PAPER FIGURES PASS: 12 panels, 2 assemblies, %d exact native data objects.\n',receipt.sourceObjectsVerified);
end

function assemble(folder,name,panels,positions,sz)
    f=figure('Visible','off','Color','w','Position',[10 10 sz]);
    for k=1:numel(panels)
        ax=axes(f,'Position',positions(k,:)); image(ax,imread(fullfile(folder,'png',[panels{k} '.png']))); axis(ax,'image'); axis(ax,'off');
        if ~strcmp(panels{k},'Fig6c')
            pos=positions(k,:); annotation(f,'textbox',[pos(1) pos(2)+pos(4)-.035 .03 .035], ...
                'String',[panels{k}(end) '.'],'FontName','Arial','FontSize',24,'FontWeight','bold','EdgeColor','none');
        end
    end
    f.UserData=struct('assembly',name,'panels',{panels},'nativePanelMasters','fig/');
    savefig(f,fullfile(folder,'fig',[name '.fig'])); exportgraphics(f,fullfile(folder,'png',[name '.png']),'Resolution',160); close(f);
    f=openfig(fullfile(folder,'fig',[name '.fig']),'invisible'); assert(numel(findall(f,'Type','image'))==numel(panels)); close(f);
end
