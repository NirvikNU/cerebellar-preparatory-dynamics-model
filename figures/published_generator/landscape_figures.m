function receipt=landscape_figures(root,replaceNewPairs)
    if nargin<2, replaceNewPairs=false; end
    c=landscape_paths(root);
    audit=jsondecode(fileread(fullfile(c.land,'independent_audit.json'))); assert(strcmp(audit.status,'PASS'));
    loaded=load(fullfile(c.land,'summary.mat'),'s'); s=loaded.s;
    loaded=load(fullfile(c.cache,'landscape_01.mat'),'result'); r=loaded.result;
    loaded=load(fullfile(c.gate1.ensembleRoot,'network_01.mat'),'model'); m=loaded.model;
    names={'diagnostic_9_movement_landscape','diagnostic_10_launch_sensitivity'};
    for j=1:2
        assert(replaceNewPairs || (~isfile(fullfile(c.plotsFigRoot,[names{j} '.fig'])) && ~isfile(fullfile(c.plotsPngRoot,[names{j} '.png']))));
    end
    f=figure('Visible','off','Color','w','Position',[40 40 1850 1080]);
    layout=tiledlayout(f,2,3,'TileSpacing','loose','Padding','loose');
    title(layout,{'Stage 1 | Frozen movement landscape','x* is a launch state; time-varying drive makes movement non-autonomous'},'FontWeight','normal','FontSize',18);
    ax=nexttile(layout); plot(ax,1000*s.time,s.drive,'k','LineWidth',2); hold(ax,'on');
    plot(ax,1000*r.snapshotTimes,r.snapshotAlpha,'o','MarkerFaceColor',[.2 .5 .7],'MarkerEdgeColor','k');
    xlabel(ax,'Time after GO (ms)'); ylabel(ax,'Common drive (source units)'); title(ax,'A  Movement drive'); style(ax);
    key=gobjects(5,1);
    key(1)=plot(ax,NaN,NaN,'ks','MarkerFaceColor','w');
    key(2)=plot(ax,NaN,NaN,'p','Color',[.85 .3 .1],'MarkerFaceColor',[.85 .3 .1]);
    key(3)=plot(ax,NaN,NaN,'o','Color',[.1 .6 .2],'MarkerFaceColor',[.1 .6 .2]);
    key(4)=plot(ax,NaN,NaN,'^','Color',[.8 .15 .15],'MarkerFaceColor',[.8 .15 .15]);
    key(5)=plot(ax,NaN,NaN,'d','Color',[.6 .3 .7],'MarkerFaceColor',[.6 .3 .7]);
    keyLegend=legend(ax,key,{'x_{sp}','x* launch','Stable root','Unstable/marginal','Nonsmooth root'}, ...
        'Location','southeast','Box','off','FontSize',9,'NumColumns',2);
    title(keyLegend,'Snapshot markers (D-F)');
    ax=nexttile(layout); hold(ax,'on');
    for i=1:size(r.links,1)
        row=r.links(i,:);
        if all(row(4:6))
            x=[norm(r.roots{row(1)}(:,row(2))-m.spontaneous),norm(r.roots{row(1)+1}(:,row(3))-m.spontaneous)];
            plot(ax,c.alpha(row(1)+(0:1)),x,'-','Color',[.65 .65 .65],'HandleVisibility','off');
        end
    end
    for i=1:numel(c.alpha)
        for j=1:size(r.roots{i},2)
            marker='o'; if r.poles{i}(j)>=-1e-7, marker='^'; end
            if r.kinks{i}(j), marker='d'; end
            scatter(ax,c.alpha(i),norm(r.roots{i}(:,j)-m.spontaneous),24,r.poles{i}(j),marker,'filled');
        end
    end
    xlabel(ax,'Frozen drive alpha'); ylabel(ax,'Equilibrium distance from x_{sp}'); title(ax,'B  Identified equilibria: network 1');
    cb=colorbar(ax); cb.Label.String='max Re eigenvalue (s^{-1})'; style(ax);
    drawnow; pos=ax.Position;
    inset=axes(f,'Position',[pos(1)+.51*pos(3),pos(2)+.08*pos(4),.43*pos(3),.28*pos(4)]);
    hold(inset,'on'); plot(inset,1:10,s.rootSummary.maxRoots,'ko-','MarkerSize',3);
    plot(inset,1:10,s.rootSummary.minStable,'s--','Color',[.1 .5 .7],'MarkerSize',3);
    title(inset,'All networks: max roots / min stable','FontSize',8,'FontWeight','normal');
    xlabel(inset,'Network','FontSize',8); ylim(inset,[0 max(s.rootSummary.maxRoots)+.5]); set(inset,'FontSize',8,'Box','off');
    ax=nexttile(layout); hold(ax,'on');
    for n=1:10, plot(ax,1000*s.time,s.distance(n,:),'Color',[.75 .82 .88],'LineWidth',.6); end
    plot(ax,1000*s.time,s.distanceMedian,'Color',[.05 .35 .65],'LineWidth',2);
    ii=1:25:numel(s.time); errorbar(ax,1000*s.time(ii),s.distanceMedian(ii),s.distanceSE(ii),'LineStyle','none','Color',[.05 .35 .65],'CapSize',3,'Tag','landDistanceSummary');
    xlabel(ax,'Time after GO (ms)'); ylabel(ax,'Nearest stable-equilibrium distance'); title(ax,'C  Actual accepted movements');
    subtitle(ax,'Target means; networks and median +/- bootstrap SE'); style(ax);
    arrowDuration=1.4*min([r.xx(1,2)-r.xx(1,1),r.yy(2,1)-r.yy(1,1)]) / ...
        max(hypot(r.flow(:,:,1,:),r.flow(:,:,2,:)),[],'all');
    assert(isfinite(arrowDuration) && arrowDuration>0);
    for phase=1:3
        ax=nexttile(layout); hold(ax,'on');
        quiver(ax,r.xx,r.yy,arrowDuration*r.flow(:,:,1,phase),arrowDuration*r.flow(:,:,2,phase),0, ...
            'Color',[.4 .4 .4],'LineWidth',.8,'MaxHeadSize',1,'Tag',sprintf('landFlow%d',phase));
        plot(ax,r.projectedTrajectory(:,1),r.projectedTrajectory(:,2),'-','Color',[.2 .4 .7],'LineWidth',1);
        near=abs(r.time-r.snapshotTimes(phase))<=.05;
        plot(ax,r.projectedTrajectory(near,1),r.projectedTrajectory(near,2),'-','Color',[.05 .2 .55],'LineWidth',3);
        plot(ax,0,0,'ks','MarkerFaceColor','w','MarkerSize',8);
        plot(ax,r.launchProjection(1),r.launchProjection(2),'p','Color',[.85 .3 .1],'MarkerFaceColor',[.85 .3 .1],'MarkerSize',11);
        roots=r.snapshotRoots{phase}; xy=(roots-m.spontaneous).'*r.plane;
        for j=1:size(roots,2)
            pole=max(real(eig((-eye(m.n)+m.W.*(roots(:,j)>0).')/m.tau)));
            color=[.1 .6 .2]; marker='o';
            if pole>=-1e-7, color=[.8 .15 .15]; marker='^'; end
            if any(abs(roots(:,j))<=1e-8), marker='d'; color=[.6 .3 .7]; end
            plot(ax,xy(j,1),xy(j,2),marker,'Color',color,'MarkerFaceColor',color,'MarkerSize',9);
        end
        axis(ax,'equal');
        xlim(ax,[min(r.xx,[],'all') max(r.xx,[],'all')]); ylim(ax,[min(r.yy,[],'all') max(r.yy,[],'all')]);
        xlabel(ax,'Launch-minus-spontaneous axis'); ylabel(ax,'Orthogonal peak-displacement axis');
        title(ax,sprintf('%c  N1/T3 | %.1f ms | alpha %.3f','D'+phase-1,1000*r.snapshotTimes(phase),r.snapshotAlpha(phase)));
        subtitle(ax,'2-D projection of full 200-D vector field');
        style(ax);
    end
    f.UserData=struct('task','STAGE1-MOVEMENT-LANDSCAPE-DIAGNOSTIC-01','diagnostic',9,'arrowDurationSeconds',arrowDuration);
    save_pair(f,c,names{1}); close(f);
    f=figure('Visible','off','Color','w','Position',[40 40 1600 1080]);
    layout=tiledlayout(f,2,2,'TileSpacing','loose','Padding','loose');
    title(layout,{'Stage 1 | Sensitivity to displacement from frozen launch states','Lines: network median +/- bootstrap SE; small points: all 10 networks; signs kept separate'},'FontWeight','normal','FontSize',18);
    colors=[.85 .33 .1;.1 .55 .8;.5 .3 .7]; metrics=[1 2 5 4];
    labels={'Native maximum neural amplification','Early hand RMS deviation (mm)','Intended-target endpoint error (mm)','Signed peak-speed change (m/s)'};
    for panel=1:4
        ax=nexttile(layout); hold(ax,'on'); handles=gobjects(6,1); legendNames=cell(6,1); k=0;
        metric=metrics(panel); amplitudes=1:6; if metric==1, amplitudes=2:6; end
        for g=1:3
          for sign=1:2
            k=k+1; ls='--'; marker='v'; if sign==2, ls='-'; marker='^'; end
            x=c.fractions(amplitudes)+(g-2)*.0009+(sign-1.5)*.00035;
            for n=1:10
                plot(ax,x,reshape(s.values(n,g,sign,amplitudes,metric),1,[]),'.','Color',.6+.4*colors(g,:),'MarkerSize',7,'HandleVisibility','off');
            end
            handles(k)=errorbar(ax,x,reshape(s.median(g,sign,amplitudes,metric),1,[]),reshape(s.se(g,sign,amplitudes,metric),1,[]), ...
                'Color',colors(g,:),'LineStyle',ls,'Marker',marker,'MarkerSize',5,'LineWidth',1.4,'CapSize',3);
            handles(k).UserData=struct('class',g,'sign',sign,'amplitudes',amplitudes,'metric',metric);
            legendNames{k}=sprintf('%s %+.0f',s.classes{g},s.signs(sign));
          end
        end
        yline(ax,0,':','Color',[.5 .5 .5],'HandleVisibility','off');
        xlabel(ax,'Perturbation / median pairwise launch distance'); ylabel(ax,labels{panel});
        title(ax,sprintf('%c  %s','A'+panel-1,labels{panel})); style(ax);
        xlim(ax,[-.005 .21]); xticks(ax,c.fractions);
        if panel==1
            legend(ax,handles,legendNames,'Location','best','NumColumns',3,'Box','off','FontSize',10);
            subtitle(ax,'Zero-amplitude amplification is undefined (0/0)');
        end
    end
    f.UserData=struct('task','STAGE1-MOVEMENT-LANDSCAPE-DIAGNOSTIC-01','diagnostic',10);
    save_pair(f,c,names{2}); close(f);
    receipt=struct('status','PASS','newPairs',2,'reopenedFIGs',2,'sensitivityErrorbarSeries',24);
    for j=1:2
        f=openfig(fullfile(c.plotsFigRoot,[names{j} '.fig']),'invisible');
        assert(f.UserData.diagnostic==8+j);
        if j==2
            bars=findall(f,'Type','errorbar'); assert(numel(bars)==24);
            for k=1:numel(bars)
                u=bars(k).UserData;
                assert(isequal(bars(k).YData,reshape(s.median(u.class,u.sign,u.amplitudes,u.metric),1,[])));
                assert(isequal(bars(k).YPositiveDelta,reshape(s.se(u.class,u.sign,u.amplitudes,u.metric),1,[])));
                assert(isequal(bars(k).YNegativeDelta,bars(k).YPositiveDelta));
            end
        else
            bar=findall(f,'Tag','landDistanceSummary');
            assert(isequaln(bar.YData,s.distanceMedian(ii)) && isequaln(bar.YPositiveDelta,s.distanceSE(ii)));
            for phase=1:3
                arrow=findall(f,'Tag',sprintf('landFlow%d',phase));
                assert(isequal(arrow.UData,arrowDuration*r.flow(:,:,1,phase)) && isequal(arrow.VData,arrowDuration*r.flow(:,:,2,phase)));
                assert(isequal(arrow.Parent.DataAspectRatio,[1 1 1]));
            end
        end
        close(f); info=imfinfo(fullfile(c.plotsPngRoot,[names{j} '.png'])); assert(info.Width>1000);
    end
    receiptName='FIGURES.json';
    if replaceNewPairs, receiptName='FIGURES_FINAL.json'; end
    landscape_json(fullfile(c.manifest,receiptName),receipt);
end

function style(ax)
    set(ax,'FontName','Arial','FontSize',12,'TickDir','out','Box','off','LineWidth',.5);
end

function save_pair(f,c,name)
    savefig(f,fullfile(c.plotsFigRoot,[name '.fig']));
    exportgraphics(f,fullfile(c.plotsPngRoot,[name '.png']),'Resolution',160);
end
