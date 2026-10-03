function receipt=fr17_render_h(d,folder)
    for sub={'fig','png'}, p=fullfile(folder,sub{1}); if ~isfolder(p), mkdir(p); end, end
    receipt=struct('figures',{{}},'network',d.selectedNetwork,'target',d.selectedTarget);
    q=d.selectedTarget;
    f=canvas([1120 1000],d); ax=axes(f,'Position',[.055 .20 .59 .66]); hold(ax,'on'); axis(ax,'equal'); axis(ax,'off');
    ax.Tag='empiricalOverlay'; bounds=[0 0;100*d.targetXY(q,:)];
    h=plot(ax,100*[0 d.targetXY(q,1)],100*[0 d.targetXY(q,2)],'k--','LineWidth',1,'HandleVisibility','off');
    h.UserData=record('idealPath',1,q,0,100*[0 d.targetXY(q,1)],100*[0 d.targetXY(q,2)]);
    for p=1:2
        c=d.condition{p}; color=d.conditionColors(p,:); ids=d.displayIDs{p};
        for tr=ids.'
            xy=100*c.xy(:,:,tr);
            h=surface(ax,[xy(:,1) xy(:,1)],[xy(:,2) xy(:,2)],zeros(600,2),'FaceColor','none','EdgeColor',color,'EdgeAlpha',.35,'LineWidth',.8,'LineStyle','-');
            h.UserData=record('trajectory',p,q,tr,xy(:,1),xy(:,2)); bounds=[bounds;xy]; %#ok<AGROW> Twenty illustrative paths.
        end
        xy=100*c.peakXY(ids,:); h=scatter(ax,xy(:,1),xy(:,2),34,color,'filled','Marker','o','MarkerEdgeColor',color);
        h.UserData=record('selectedUnsmoothedPeak',p,q,ids,xy(:,1),xy(:,2));
    end
    uistack(findall(ax,'Type','scatter'),'top');
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
    xlim(key,[-1.55 1.55]); ylim(key,[-1.55 1.55]);
    inset=axes(f,'Position',[.59 .18 .35 .36]); hold(inset,'on'); axis(inset,'equal'); axis(inset,'off'); inset.Tag='empiricalAngledHistogram';
    e=[cosd(45) sind(45)]; countAxis=.18*[cosd(-45) sind(-45)]; vertices=[];
    for p=1:2
        for bin=1:numel(d.histEdgesCM)-1
            n=d.histCounts(bin,p); range=d.histEdgesCM(bin:bin+1);
            xy=[range(1) range(2) range(2) range(1)].'*e+[0 0 n n].'*countAxis;
            h=patch(inset,xy(:,1),xy(:,2),d.conditionColors(p,:),'FaceAlpha',.25,'EdgeColor',d.conditionColors(p,:),'LineWidth',1);
            h.UserData=struct('kind','histogramBin','condition',p,'target',q,'bin',bin,'count',n,'rangeCM',range,'x',xy(:,1),'y',xy(:,2));
            vertices=[vertices;xy]; %#ok<AGROW> All-30 histogram patches.
        end
    end
    lastEdge=d.histEdgesCM(end); mark=[lastEdge-1 lastEdge].'*e-.4*countAxis; plot(inset,mark(:,1),mark(:,2),'k-','LineWidth',1.5,'Tag','histDistanceScale');
    pos=(lastEdge-.5)*e-1.5*countAxis; text(inset,pos(1),pos(2),'1 cm','Rotation',45,'HorizontalAlignment','center','FontSize',12);
    mark=(lastEdge+.2)*e+[0;2]*countAxis; plot(inset,mark(:,1),mark(:,2),'k-','LineWidth',1.5,'Tag','histCountScale');
    pos=(lastEdge+.7)*e+countAxis; text(inset,pos(1),pos(2),'2','Rotation',-45,'HorizontalAlignment','center','FontSize',12);
    lo=min(vertices); hi=max(vertices); xlim(inset,[lo(1)-.4 hi(1)+1]); ylim(inset,[lo(2)-.5 hi(2)+1]);
    annotation(f,'textbox',[.04 .89 .92 .08],'String',sprintf('6h  Peak-speed positions | network %d, target %d',d.selectedNetwork,q), ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',19);
    annotation(f,'textbox',[.05 .07 .90 .08],'String',{'Spatially stratified random successful examples; filled unsmoothed peak-speed positions.', ...
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

function u=record(kind,p,q,tr,x,y)
    u=struct('kind',kind,'condition',p,'target',q,'trials',tr,'x',x,'y',y);
end

function r=savePanel(r,f,folder,name)
    fig=fullfile(folder,'fig',[name '.fig']); png=fullfile(folder,'png',[name '.png']);
    assert(~isfile(fig) && ~isfile(png)); drawnow; savefig(f,fig); exportgraphics(f,png,'Resolution',160); close(f);
    r.figures{end+1}=struct('name',name,'fig',fig,'png',png);
end
