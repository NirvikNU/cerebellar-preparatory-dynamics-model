function receipt=v2_finalize_figures(root)
    % Cache-only authorized Panel E revision and cosmetic legend repair.
    cfg=v2_paths(root); path=fullfile(cfg.manifest,'final_figures.json'); assert(~isfile(path));
    s=load(fullfile(cfg.dest,'dispersion_resolution.mat'),'out'); out=s.out;
    original=jsondecode(fileread(fullfile(cfg.manifest,'figures.json'))); receipt=original;
    backup=fullfile(cfg.raw,'render_drafts_before_resolution'); assert(~isfolder(backup)); mkdir(backup);
    receipt.objectChecks=0; receipt.legendRepairs=0; receipt.pairs=original.pairs;
    dimensions=[2200 2700;1500 650;2100 650;2000 650;1900 1200;1900 1200];
    for j=1:numel(original.pairs)
        pair=original.pairs(j); f=openfig(pair.fig,'invisible');
        set(f,'Units','pixels','Position',[20 20 dimensions(j,:)]);
        before=snapshot(f); changed=false;
        if j==1
            copyfile(pair.fig,fullfile(backup,'MainFig_Modelling_v2.fig')); copyfile(pair.png,fullfile(backup,'MainFig_Modelling_v2.png'));
            axesList=findall(f,'Type','axes'); ax=[];
            for h=axesList.', if startsWith(string(h.Title.String(1)),'E  '), ax=h; break; end, end
            assert(~isempty(ax)); cla(ax); hold(ax,'on'); colors=[86 180 233;213 94 0]/255;
            plot(ax,1:2,out.matchedCM.','Color',[.84 .84 .84],'LineWidth',.6,'HandleVisibility','off');
            for p=1:2
                scatter(ax,repmat(p,6,1),out.matchedCM(:,p),25,colors(p,:),'filled','MarkerFaceAlpha',.3,'HandleVisibility','off');
                h=errorbar(ax,p,out.matched.median(p),out.matched.se(p),'o','Color',colors(p,:),'MarkerFaceColor',colors(p,:), ...
                    'MarkerSize',8,'LineWidth',2,'CapSize',10);
                h.UserData=struct('x',p,'y',out.matched.median(p),'err',out.matched.se(p),'raw',out.matchedCM(:,p),'indexKind','subset','kind','networkBootstrap');
            end
            f.UserData.subsetIndices=out.indices;
            xticks(ax,1:2); xticklabels(ax,{'Intact','Block'}); xlim(ax,[.6 2.4]);
            ylabel(ax,'Peak-speed position dispersion (cm)');
            title(ax,{'E  Speed-matched dispersion | 6/10 eligible','Wilcoxon signed-rank, n=6, p=0.03125'});
            changed=true;
        end
        legends=findall(f,'Type','legend');
        for lg=legends.'
            if any(startsWith(string(lg.String),'data'))
                ax=lg.Axes; curves=flipud(findall(ax,'Type','errorbar'));
                curves=curves(arrayfun(@(h)~isempty(h.DisplayName),curves)); assert(numel(curves)==2);
                legend(ax,curves,'Location','best','FontSize',12,'AutoUpdate','off');
                receipt.legendRepairs=receipt.legendRepairs+1; changed=true;
            end
        end
        after=snapshot(f);
        if j==1
            before=before(~cellfun(@(u)isfield(u,'raw')&&size(u.raw,1)==10&&any(isnan(u.raw(:))),before));
            after=after(~cellfun(@(u)isfield(u,'indexKind')&&strcmp(u.indexKind,'subset'),after));
        end
        assert(isequaln(before,after),'Figure scientific data changed outside authorized Panel E');
        if changed
            if j~=1
                [~,name]=fileparts(pair.fig); copyfile(pair.fig,fullfile(backup,[name '.fig'])); copyfile(pair.png,fullfile(backup,[name '.png']));
            end
            drawnow; savefig(f,pair.fig); exportgraphics(f,pair.png,'Resolution',160);
        end
        close(f); f=openfig(pair.fig,'invisible');
        objects=findall(f,'-property','UserData'); count=0;
        for h=objects.'
            u=h.UserData; if ~isstruct(u), continue; end
            if isfield(u,'x'), assert(isequaln(h.XData(:),u.x(:))&&isequaln(h.YData(:),u.y(:))); count=count+1; end
            if isfield(u,'err'), assert(isequaln(h.YPositiveDelta(:),u.err(:))&&isequaln(h.YNegativeDelta(:),u.err(:))); end
            if isfield(u,'image'), assert(isequaln(h.CData,u.image)); count=count+1; end
            if isfield(u,'raw')
                ix=f.UserData.indices;
                if strcmp(u.indexKind,'legacy'), ix=f.UserData.legacyIndices; end
                if strcmp(u.indexKind,'subset'), ix=f.UserData.subsetIndices; end
                for k=1:size(u.raw,2)
                    v=u.raw(:,k); draws=median(reshape(v(ix),size(ix)),2);
                    assert(abs(median(v)-u.y(k))<1e-10 && abs(std(draws)-u.err(k))<1e-10);
                end
            end
        end
        for lg=findall(f,'Type','legend').', assert(~any(startsWith(string(lg.String),'data'))); end
        close(f); receipt.pairs(j).objectChecks=count; receipt.objectChecks=receipt.objectChecks+count;
    end
    receipt.status='PASS'; receipt.visualStatus='PENDING'; receipt.noSimulationOrFit=true; paper_json(path,receipt);
end

function values=snapshot(f)
    objects=findall(f,'-property','UserData'); values={};
    for h=objects.'
        u=h.UserData;
        if isstruct(u)&&(isfield(u,'x')||isfield(u,'image')), values{end+1}=u; end %#ok<AGROW>
    end
end
