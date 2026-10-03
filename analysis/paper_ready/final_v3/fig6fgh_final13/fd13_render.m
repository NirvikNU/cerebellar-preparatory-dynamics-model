function receipt=fd13_render(d,folder)
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
            for tr=c.order(1:4,q).'
                xy=100*c.xy(:,:,tr); h=plot(ax,xy(:,1),xy(:,2),'Color',color,'LineWidth',.65);
                h.UserData=record('trajectory',p,q,tr,xy(:,1),xy(:,2)); bounds=[bounds;xy]; %#ok<AGROW> Bounded eighty display curves.
            end
            xy=100*c.meanXY(:,:,q); h=plot(ax,xy(:,1),xy(:,2),'Color',color,'LineWidth',2.4);
            h.UserData=record('fourPhaseMean',p,q,0,xy(:,1),xy(:,2)); bounds=[bounds;xy]; %#ok<AGROW> Bounded sixteen target means.
        end
        xlabel(ax,'Hand x (cm)'); ylabel(ax,'Hand y (cm)'); axis(ax,'equal');
        title(ax,{sprintf('6f  %s | network %d',d.names{p},d.selectedNetwork),'4 successes/target + same-four normalized mean'});
    end
    bounds=[bounds;100*d.targetXY+1.5;100*d.targetXY-1.5]; lo=min(bounds,[],1,'omitnan'); hi=max(bounds,[],1,'omitnan');
    pad=.05*(hi-lo); for ax=axesF.', xlim(ax,[lo(1)-pad(1) hi(1)+pad(1)]); ylim(ax,[lo(2)-pad(2) hi(2)+pad(2)]); end
    annotation(f,'textbox',[.05 .015 .9 .06],'String','Saved successful trials only; 101-point means of the four shown. Outcome-selected illustration, not inference.', ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',13);
    receipt=savePanel(receipt,f,folder,'Fig6f');
    q=d.selectedTarget; styles={'-','-'};
    f=canvas([1100 750],d); ax=axes(f,'Position',[.12 .17 .83 .65]); style(ax); handles=gobjects(1,2);
    for p=1:2
        c=d.condition{p}; color=d.conditionColors(p,:);
        for tr=c.order(1:10,q).'
            y=c.alignedSpeed(:,tr); h=plot(ax,d.timesMs,y,styles{p},'Color',color,'LineWidth',.5,'HandleVisibility','off');
            h.UserData=record('selectedRawSpeed',p,q,tr,d.timesMs,y);
        end
        y=c.medianSpeed(:,q); handles(p)=plot(ax,d.timesMs,y,styles{p},'Color',color,'LineWidth',2.8,'DisplayName',d.names{p});
        handles(p).UserData=record('all30MedianSpeed',p,q,0,d.timesMs,y);
    end
    xlabel(ax,'Time from movement onset (ms)'); ylabel(ax,'Speed (m/s)'); xlim(ax,[0 600]);
    title(ax,{sprintf('6g  Hand speed | network %d, target %d',d.selectedNetwork,q), ...
        '10 raw successful profiles + all-30 median'});
    legend(ax,handles,'Location','northeast','AutoUpdate','off');
    annotation(f,'textbox',[.05 .015 .9 .07],'String','Median only: full-support Gaussian 50 ms, then nActive >= 15 display cutoff. Thin traces unsmoothed.', ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',12);
    receipt=savePanel(receipt,f,folder,'Fig6g');
    f=canvas([1450 800],d); axesH=gobjects(1,2); bounds=[0 0;100*d.targetXY(q,:)];
    for p=1:2
        c=d.condition{p};
        for tr=c.order(1:10,q).', bounds=[bounds;100*c.xy(:,:,tr)]; end %#ok<AGROW> Twenty saved display paths.
    end
    lo=min(bounds,[],1,'omitnan'); hi=max(bounds,[],1,'omitnan'); span=max(hi-lo,[2 2]);
    for p=1:2
        ax=axes(f,'Position',[.035+(p-1)*.325 .22 .29 .58]); axesH(p)=ax; hold(ax,'on'); axis(ax,'equal'); axis(ax,'off');
        c=d.condition{p}; color=d.conditionColors(p,:); ids=c.order(1:10,q);
        h=plot(ax,100*[0 d.targetXY(q,1)],100*[0 d.targetXY(q,2)],'k--','LineWidth',1.2,'HandleVisibility','off');
        h.UserData=record('idealPath',p,q,0,100*[0 d.targetXY(q,1)],100*[0 d.targetXY(q,2)]);
        for tr=ids.'
            xy=100*c.xy(:,:,tr); h=plot(ax,xy(:,1),xy(:,2),'-','Color',color,'LineWidth',.8);
            h.UserData=record('trajectory',p,q,tr,xy(:,1),xy(:,2));
        end
        xy=100*c.peakXY(ids,:); h=scatter(ax,xy(:,1),xy(:,2),36,color,'filled','Marker','o','MarkerEdgeColor',color);
        h.UserData=record('selectedUnsmoothedPeak',p,q,ids,xy(:,1),xy(:,2));
        xlim(ax,[lo(1)-.12*span(1) hi(1)+.08*span(1)]); ylim(ax,[lo(2)-.20*span(2) hi(2)+.08*span(2)]);
        x=lo(1); y=lo(2)-.12*span(2); plot(ax,[x x+1],[y y],'k-','LineWidth',2);
        plot(ax,[x x],[y y+1],'k-','LineWidth',2); text(ax,x+.5,y-.025*span(2),'1 cm','HorizontalAlignment','center','FontSize',12);
        title(ax,d.names{p},'FontSize',18);
    end
    assert(isequal(axesH(1).XLim,axesH(2).XLim) && isequal(axesH(1).YLim,axesH(2).YLim));
    inset=axes(f,'Position',[.73 .33 .24 .40]); style(inset);
    maximum=max([d.condition{1}.distanceCM(:,q);d.condition{2}.distanceCM(:,q)]); edges=linspace(0,maximum*1.01,12);
    for p=1:2
        values=d.condition{p}.distanceCM(:,q); color=d.conditionColors(p,:); face={'bar','stairs'};
        h=histogram(inset,values,edges,'DisplayStyle',face{p},'EdgeColor',color,'LineWidth',1.5);
        if p==1, h.FaceColor=color; h.FaceAlpha=.35; end
        h.UserData=struct('kind','all30Inset','condition',p,'target',q,'samples',values,'edges',edges);
    end
    xlabel(inset,{'Distance from all-30 median','peak position (cm)'},'FontSize',12); ylabel(inset,'Trials');
    title(inset,{'All 30 successes/condition','Intact filled / Block outline'},'FontSize',13); set(inset,'FontSize',12);
    annotation(f,'textbox',[.03 .86 .94 .09],'String',sprintf('6h  Peak-speed positions | network %d, target %d',d.selectedNetwork,q), ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',19);
    annotation(f,'textbox',[.03 .035 .94 .10],'String',{'10 successful trajectories/condition; unsmoothed prefix-peak positions; black dashed ideal center-to-center path.', ...
        'All-30-success illustrative inset; independent n=6 speed-matched assay unchanged.'}, ...
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
