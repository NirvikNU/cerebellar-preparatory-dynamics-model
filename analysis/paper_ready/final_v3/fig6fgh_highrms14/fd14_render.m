function receipt=fd14_render(d,folder)
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
        title(ax,{sprintf('6f  %s | network %d',d.names{p},d.selectedNetwork),'4 highest-pathRMS successes + same-four mean'});
    end
    bounds=[bounds;100*d.targetXY+1.5;100*d.targetXY-1.5]; lo=min(bounds,[],1,'omitnan'); hi=max(bounds,[],1,'omitnan');
    pad=.05*(hi-lo); for ax=axesF.', xlim(ax,[lo(1)-pad(1) hi(1)+pad(1)]); ylim(ax,[lo(2)-pad(2) hi(2)+pad(2)]); end
    annotation(f,'textbox',[.05 .015 .9 .06],'String','Deliberately selected high-deviation successes; 101-point means of the same four shown. Not statistically typical.', ...
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
        '10 highest-pathRMS raw successes + all-30 median'});
    legend(ax,handles,'Location','northeast','AutoUpdate','off');
    annotation(f,'textbox',[.05 .015 .9 .07],'String','Median only: full-support Gaussian 50 ms, then nActive >= 15 display cutoff. Thin traces unsmoothed.', ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',12);
    receipt=savePanel(receipt,f,folder,'Fig6g');
    f=canvas([1120 1000],d); ax=axes(f,'Position',[.055 .20 .59 .66]); hold(ax,'on'); axis(ax,'equal'); axis(ax,'off');
    ax.Tag='empiricalOverlay'; bounds=[0 0;100*d.targetXY(q,:)];
    h=plot(ax,100*[0 d.targetXY(q,1)],100*[0 d.targetXY(q,2)],'k--','LineWidth',1,'HandleVisibility','off');
    h.UserData=record('idealPath',1,q,0,100*[0 d.targetXY(q,1)],100*[0 d.targetXY(q,2)]);
    for p=1:2
        c=d.condition{p}; color=d.conditionColors(p,:); ids=c.order(1:10,q);
        for tr=ids.'
            xy=100*c.xy(:,:,tr);
            h=surface(ax,[xy(:,1) xy(:,1)],[xy(:,2) xy(:,2)],zeros(600,2),'FaceColor','none','EdgeColor',color,'EdgeAlpha',.35,'LineWidth',.8,'LineStyle','-');
            h.UserData=record('trajectory',p,q,tr,xy(:,1),xy(:,2)); bounds=[bounds;xy]; %#ok<AGROW> Twenty illustrative paths.
        end
        xy=100*c.peakXY(ids,:); h=scatter(ax,xy(:,1),xy(:,2),34,color,'filled','Marker','o','MarkerEdgeColor',color);
        h.UserData=record('selectedUnsmoothedPeak',p,q,ids,xy(:,1),xy(:,2));
    end
    lo=min(bounds,[],1,'omitnan'); hi=max(bounds,[],1,'omitnan'); span=max(hi-lo,[2 2]);
    xlim(ax,[lo(1)-.25*span(1) hi(1)+.07*span(1)]); ylim(ax,[lo(2)-.07*span(2) hi(2)+.08*span(2)]);
    x=lo(1)-.15*span(1); y=hi(2)-1.6;
    plot(ax,[x x+1],[y y],'k-','LineWidth',2,'Tag','scaleBarX'); plot(ax,[x x],[y y+1],'k-','LineWidth',2,'Tag','scaleBarY');
    text(ax,x+.5,y-.2,'1 cm','HorizontalAlignment','center','VerticalAlignment','top','FontSize',13);
    key=axes(f,'Position',[.70 .69 .16 .17]); hold(key,'on'); axis(key,'equal'); axis(key,'off'); key.Tag='targetDirectionKey';
    for t=1:8
        xy=d.targetXY(t,:)/.1;
        h=scatter(key,xy(1),xy(2),120,d.targetColors(t,:),'filled','MarkerFaceAlpha',.22,'MarkerEdgeColor','none','Tag',sprintf('keyTarget%d',t));
        if t==q, h.MarkerFaceAlpha=1; h.MarkerEdgeColor='k'; h.LineWidth=1; end
    end
    plot(key,[0 d.targetXY(q,1)/.1],[0 d.targetXY(q,2)/.1],'k--','LineWidth',.8);
    xy=d.targetXY(q,:)/.1; rectangle(key,'Position',[xy(1)-.43 xy(2)-.43 .86 .86],'EdgeColor',[.25 .25 .25],'LineWidth',1);
    xlim(key,[-1.4 1.4]); ylim(key,[-1.6 1.4]);
    inset=axes(f,'Position',[.59 .18 .35 .36]); hold(inset,'on'); axis(inset,'equal'); axis(inset,'off'); inset.Tag='empiricalAngledHistogram';
    e=[cosd(45) sind(45)]; countAxis=.18*[cosd(-45) sind(-45)]; vertices=[];
    for p=1:2
        for bin=1:12
            n=d.histCounts(bin,p); range=d.histEdgesCM(bin:bin+1);
            xy=[range(1) range(2) range(2) range(1)].'*e+[0 0 n n].'*countAxis;
            h=patch(inset,xy(:,1),xy(:,2),d.conditionColors(p,:),'FaceAlpha',.25,'EdgeColor',d.conditionColors(p,:),'LineWidth',1);
            h.UserData=struct('kind','histogramBin','condition',p,'target',q,'bin',bin,'count',n,'rangeCM',range,'x',xy(:,1),'y',xy(:,2));
            vertices=[vertices;xy]; %#ok<AGROW> Fixed24 histogram patches.
        end
    end
    mark=[5 6].'*e-.4*countAxis; plot(inset,mark(:,1),mark(:,2),'k-','LineWidth',1.5,'Tag','histDistanceScale');
    pos=5.5*e-1.5*countAxis; text(inset,pos(1),pos(2),'1 cm','Rotation',45,'HorizontalAlignment','center','FontSize',12);
    mark=6.2*e+[0;2]*countAxis; plot(inset,mark(:,1),mark(:,2),'k-','LineWidth',1.5,'Tag','histCountScale');
    pos=6.7*e+countAxis; text(inset,pos(1),pos(2),'2','Rotation',-45,'HorizontalAlignment','center','FontSize',12);
    lo=min(vertices); hi=max(vertices); xlim(inset,[lo(1)-.4 hi(1)+1]); ylim(inset,[lo(2)-.5 hi(2)+1]);
    annotation(f,'textbox',[.04 .89 .92 .08],'String',sprintf('6h  Peak-speed positions | network %d, target %d',d.selectedNetwork,q), ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',19);
    annotation(f,'textbox',[.05 .07 .90 .08],'String',{'Overlaid highest-pathRMS successful examples; filled unsmoothed peak-speed positions.', ...
        'Angled inset: all 30 successes per condition. Black dashed line: ideal path.'}, ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',12);
    annotation(f,'textbox',[.55 .60 .36 .05],'String','Intact','Color',d.conditionColors(1,:),'EdgeColor','none','FontSize',13);
    annotation(f,'textbox',[.71 .60 .25 .05],'String','Block','Color',d.conditionColors(2,:),'EdgeColor','none','FontSize',13);
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
