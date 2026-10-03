function receipt=sp10_render(d,folder)
    for sub={'fig','png'}, p=fullfile(folder,sub{1}); if ~isfolder(p), mkdir(p); end, end
    receipt=struct('figures',{{}},'network',d.selectedNetwork,'target',d.selectedTarget);
    f=canvas([1450 760],d); axesF=gobjects(1,2); bounds=[];
    for p=1:2
        ax=axes(f,'Position',[.07+(p-1)*.49 .15 .40 .70]); style(ax); axesF(p)=ax;
        c=d.condition{p};
        for q=1:8
            color=d.targetColors(q,:); ang=linspace(0,2*pi,101);
            plot(ax,100*d.targetXY(q,1)+1.5*cos(ang),100*d.targetXY(q,2)+1.5*sin(ang), ...
                'Color',color,'LineWidth',.7,'HandleVisibility','off','Tag',sprintf('zone_%d',q));
            for tr=c.order(1:5,q).'
                xy=100*c.xy(:,:,tr); h=plot(ax,xy(:,1),xy(:,2),'Color',color,'LineWidth',.65);
                h.UserData=record('trajectory',p,q,tr,xy(:,1),xy(:,2)); bounds=[bounds;xy]; %#ok<AGROW> Bounded eighty display curves.
            end
            xy=100*c.meanXY(:,:,q); h=plot(ax,xy(:,1),xy(:,2),'Color',color,'LineWidth',2.4);
            h.UserData=record('all30Mean',p,q,0,xy(:,1),xy(:,2)); bounds=[bounds;xy]; %#ok<AGROW> Bounded sixteen target means.
        end
        xlabel(ax,'Hand x (cm)'); ylabel(ax,'Hand y (cm)'); axis(ax,'equal');
        title(ax,{sprintf('6f  %s | network %d',d.names{p},d.selectedNetwork),'5 selected trials/target + all-30 mean'});
    end
    bounds=[bounds;100*d.targetXY+1.5;100*d.targetXY-1.5]; lo=min(bounds,[],1,'omitnan'); hi=max(bounds,[],1,'omitnan');
    pad=.05*(hi-lo); for ax=axesF.', xlim(ax,[lo(1)-pad(1) hi(1)+pad(1)]); ylim(ax,[lo(2)-pad(2) hi(2)+pad(2)]); end
    annotation(f,'textbox',[.05 .015 .9 .06],'String','Success-first ideal-path selection; outcome-selected illustration, not an inferential or typicality claim', ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',13);
    receipt=savePanel(receipt,f,folder,'Fig6f');
    q=d.selectedTarget; styles={'-','--'};
    f=canvas([1100 750],d); ax=axes(f,'Position',[.12 .17 .83 .65]); style(ax); handles=gobjects(1,2);
    for p=1:2
        c=d.condition{p}; color=d.conditionColors(p,:);
        for tr=c.order(1:10,q).'
            y=c.smoothSpeed(:,tr); h=plot(ax,d.timesMs,y,styles{p},'Color',color,'LineWidth',.5,'HandleVisibility','off');
            h.UserData=record('selectedSmoothedSpeed',p,q,tr,d.timesMs,y);
        end
        y=c.medianSpeed(:,q); handles(p)=plot(ax,d.timesMs,y,styles{p},'Color',color,'LineWidth',2.8,'DisplayName',d.names{p});
        handles(p).UserData=record('all30MedianSpeed',p,q,0,d.timesMs,y);
    end
    xlabel(ax,'Time from GO (ms)'); ylabel(ax,'Speed (m/s)'); xlim(ax,[0 600]);
    title(ax,{sprintf('6g  Hand speed | network %d, target %d',d.selectedNetwork,q), ...
        '10 selected trials + all-30 median | 50-ms display smoothing'});
    legend(ax,handles,'Location','northeast','AutoUpdate','off');
    annotation(f,'textbox',[.05 .015 .9 .07],'String','First target entry or 600 ms; smoothing uses no post-end samples. Aggregate statistics unchanged.', ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',12);
    receipt=savePanel(receipt,f,folder,'Fig6g');
    f=canvas([1200 820],d); ax=axes(f,'Position',[.05 .14 .60 .66]); hold(ax,'on'); axis(ax,'equal'); axis(ax,'off');
    title(ax,{sprintf('6h  Peak-speed positions | network %d, target %d',d.selectedNetwork,q), ...
        '10 selected trials per condition'},'FontSize',18);
    bounds=[]; handles=gobjects(1,2);
    for p=1:2
        c=d.condition{p}; color=d.conditionColors(p,:); ids=c.order(1:10,q);
        for tr=ids.'
            xy=100*c.xy(:,:,tr); h=plot(ax,xy(:,1),xy(:,2),styles{p},'Color',color,'LineWidth',.8,'HandleVisibility','off');
            h.UserData=record('trajectory',p,q,tr,xy(:,1),xy(:,2)); bounds=[bounds;xy]; %#ok<AGROW> Bounded twenty curves.
        end
        xy=100*c.peakXY(ids,:); rims={'w','k'};
        handles(p)=scatter(ax,xy(:,1),xy(:,2),36,color,'filled','Marker','o','MarkerEdgeColor',rims{p},'LineWidth',.6,'DisplayName',d.names{p});
        handles(p).UserData=record('selectedUnsmoothedPeak',p,q,ids,xy(:,1),xy(:,2));
    end
    lo=min(bounds,[],1,'omitnan'); hi=max(bounds,[],1,'omitnan'); span=hi-lo;
    xlim(ax,[lo(1)-.12*span(1) hi(1)+.08*span(1)]); ylim(ax,[lo(2)-.20*span(2) hi(2)+.08*span(2)]);
    x=lo(1); y=lo(2)-.12*span(2); plot(ax,[x x+1],[y y],'k-','LineWidth',2,'HandleVisibility','off');
    plot(ax,[x x],[y y+1],'k-','LineWidth',2,'HandleVisibility','off');
    text(ax,x+.5,y-.25,'1 cm','HorizontalAlignment','center','FontSize',13);
    legend(ax,handles,'Location','southoutside','Orientation','horizontal','AutoUpdate','off','FontSize',14);
    inset=axes(f,'Position',[.72 .33 .25 .40]); style(inset);
    maximum=max([d.condition{1}.distanceCM(:,q);d.condition{2}.distanceCM(:,q)]); edges=linspace(0,maximum*1.01,12);
    for p=1:2
        values=d.condition{p}.distanceCM(:,q); color=d.conditionColors(p,:); face={'bar','stairs'};
        h=histogram(inset,values,edges,'DisplayStyle',face{p},'EdgeColor',color,'LineWidth',1.5);
        if p==1, h.FaceColor=color; h.FaceAlpha=.35; end
        h.UserData=struct('kind','all30Inset','condition',p,'target',q,'samples',values,'edges',edges);
    end
    xlabel(inset,{'Distance from all-30 median','peak position (cm)'},'FontSize',12); ylabel(inset,'Trials');
    title(inset,{'All 30 trials/condition','Intact filled / Block outline'},'FontSize',13); set(inset,'FontSize',12);
    annotation(f,'textbox',[.03 .015 .94 .07],'String',{'Intact: solid / white-rim circles; Block: dashed / black-rim circles. Unsmoothed pre-end peaks.', ...
        'All-30 illustrative inset; independent n=6 speed-matched assay unchanged.'}, ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',12);
    receipt=savePanel(receipt,f,folder,'Fig6h');
end

function f=canvas(sizeXY,d)
    f=figure('Visible','off','Color','w','Position',[30 30 sizeXY]);
    set(f,'DefaultAxesFontName','Arial','DefaultAxesFontSize',15,'DefaultAxesTickDir','out','DefaultAxesBox','off');
    f.UserData=struct('network',d.selectedNetwork,'target',d.selectedTarget,'task',d.task,'palette',d.targetColors,'conditionColors',d.conditionColors);
end

function style(ax)
    hold(ax,'on'); set(ax,'FontName','Arial','FontSize',15,'TickDir','out','Box','off');
end

function u=record(kind,p,q,tr,x,y)
    u=struct('kind',kind,'condition',p,'target',q,'trials',tr,'x',x,'y',y);
end

function r=savePanel(r,f,folder,name)
    fig=fullfile(folder,'fig',[name '.fig']); png=fullfile(folder,'png',[name '.png']);
    assert(~isfile(fig) && ~isfile(png)); drawnow; savefig(f,fig); exportgraphics(f,png,'Resolution',160); close(f);
    r.figures{end+1}=struct('name',name,'fig',fig,'png',png);
end
