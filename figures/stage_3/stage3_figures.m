function paths = stage3_figures(cfg,figureIndices)
    % Four planned figures only; missing primary is displayed, never replaced.
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); r=s.result;
    map=stage3_logical_flags(readtable(fullfile(cfg.resultsRoot,'feasibility_map.csv')));
    if nargin<2, figureIndices=1:4; end
    assert(all(ismember(figureIndices,1:4)) && numel(unique(figureIndices))==numel(figureIndices));
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); registry=s.registry;
    s=load(fullfile(cfg.cacheRoot,'reference_01.mat'),'ref'); ref=s.ref;
    names={'result_1_preparation_and_movement','result_2_preparatory_geometry', ...
        'diagnostic_1_feasible_solution_map','diagnostic_2_component_removal'};
    blue=[.1 .5 .7]; orange=[.85 .325 .1]; gray=[.55 .55 .55];
    paths=cell(4,2);
    for figIndex=figureIndices
        if figIndex==4 && isfile(fullfile(cfg.resultsRoot,'gain_time','gain_time.mat'))
            current=stage3_gain_time_figure(cfg);
            paths(figIndex,:)={current.fig,current.png};
            continue;
        end
        f=figure('Visible','off','Color','w','Position',[50 50 1600 650]);
        if figIndex==3
            f.Position=[50 50 1700 850];
            tiledlayout(f,1,2,'Padding','loose','TileSpacing','loose');
            ax=nexttile; hold(ax,'on'); a=map(map.network==1 & map.direction==1,:);
            [xx,yy]=meshgrid(linspace(.08,1.03,150),linspace(.05,1.3,150));
            [cs,ch]=contour(ax,xx,yy,xx.^2+yy.^2,[.25 .5 1 2],'Color',[.75 .75 .75],'ShowText','on');
            clabel(cs,ch,'FontSize',11); ch.HandleVisibility='off';
            [~,ch]=contour(ax,xx,yy,xx.^2+yy.^2,[1 1],'k-','LineWidth',1.3); ch.HandleVisibility='off';
            h1=scatter(ax,a.alpha(~a.rateRealizable),a.betaNormalized(~a.rateRealizable),65,[.75 .2 .2],'x','LineWidth',1.4);
            h7=scatter(ax,a.alpha(~a.modulationOK),a.betaNormalized(~a.modulationOK),85,[.55 .55 .55],'+','LineWidth',1.4);
            h8=scatter(ax,a.alpha(~a.endpointBoundsOK),a.betaNormalized(~a.endpointBoundsOK),105,'k','d','LineWidth',1.3);
            h2=scatter(ax,a.alpha(a.analytical),a.betaNormalized(a.analytical),125,[.45 .3 .65],'^','LineWidth',1.3);
            h3=scatter(ax,a.alpha(a.physical),a.betaNormalized(a.physical),85,blue,'s','LineWidth',1.7);
            empirical=a.physical & a.finitePhenotype & ~a.analytical;
            h4=scatter(ax,a.alpha(empirical),a.betaNormalized(empirical),55,orange,'filled');
            h5=scatter(ax,a.alpha(a.feasible),a.betaNormalized(a.feasible),50,[.1 .6 .3],'filled');
            boundary=cfg.alpha*sqrt(ref.rhoBound*ref.d/ref.T);
            h6=plot(ax,cfg.alpha,boundary,'--','Color',[.45 .3 .65],'LineWidth',1.6);
            sampleHandle=gobjects(0); primaryHandle=gobjects(0);
            for k=1:numel(registry.additional)
                d=registry.additional{k};
                if d.member==1
                    sampleHandle=scatter(ax,d.alpha,d.betaNormalized,180,'k','o','LineWidth',1.5);
                    text(ax,d.alpha+.015,d.betaNormalized+.035,sprintf('sample d%d',d.direction),'FontSize',11);
                end
            end
            if r.hasPrimary
                d=registry.primary{1}; primaryHandle=scatter(ax,d.alpha,d.betaNormalized,240,'k','p','LineWidth',1.8);
            end
            xlabel(ax,'\alpha'); ylabel(ax,'\beta / \surd(T/d)'); xlim(ax,[.05 1.05]); ylim(ax,[0 1.35]);
            title(ax,{'A  Feasible-state map','Network 1, direction 1'},'FontWeight','normal');
            handles=gobjects(1,10); handles(1:8)=[h1 h7 h8 h2 h3 h4 h5 h6]; labels=cell(1,10); labels(1:8)={'Negative rate (nonlinear untested)','Modulation bound (nonlinear untested)', ...
                'Endpoint bound (nonlinear untested)','Analytically sufficient','Physical + dynamically admissible', ...
                'Empirical success outside bound','All criteria feasible','Conservative sufficient boundary'};
            legendCount=8;
            if ~isempty(sampleHandle), legendCount=legendCount+1; handles(legendCount)=sampleHandle; labels{legendCount}='Sampled parameter positions (d1-d3)'; end
            if ~isempty(primaryHandle), legendCount=legendCount+1; handles(legendCount)=primaryHandle; labels{legendCount}='Primary Results setting'; end
            legend(ax,handles(1:legendCount),labels(1:legendCount),'Location','southoutside','FontSize',10,'NumColumns',2);
            apply_plot_style(ax,cfg);
            ax=nexttile; hold(ax,'on'); frequencies=zeros(36,1);
            for j=1:36, frequencies(j)=sum(map.feasible & map.gridIndex==j)/30; end
            scatter(ax,a.alpha,a.betaNormalized,260,frequencies,'filled','s','MarkerEdgeColor',[.3 .3 .3]);
            colormap(ax,parula(256)); clim(ax,[0 1]); cb=colorbar(ax); cb.Label.String='Fraction feasible (30 network/direction sets)';
            xlabel(ax,'\alpha'); ylabel(ax,'\beta / \surd(T/d)'); xlim(ax,[.05 1.05]); ylim(ax,[0 1.35]);
            title(ax,{'B  Generality across the declared family','10 frozen networks \times 3 seeded directions'},'FontWeight','normal');
            apply_plot_style(ax,cfg);
            sgtitle(f,sprintf('Bounded cortical-state feasibility | %d / 1080 declared grid points meet all criteria',sum(map.feasible)),'FontSize',18);
        else
            tiledlayout(f,1,3,'Padding','loose','TileSpacing','loose');
            if ~r.hasPrimary
                labels={{'A  Preparation','B  Eight-target reaches','C  Early movement error'}, ...
                    {'A  Prep eigenspectra','B  Participation ratio','C  Directed alignment'}, ...
                    {},{'A  Preparatory-state error','B  Participation ratio','C  Expected minus observed alignment'}};
                for p=1:3
                    ax=nexttile; axis(ax,'off'); title(ax,labels{figIndex}{p},'FontSize',17,'FontWeight','normal');
                    text(ax,.5,.6,{'No common feasible primary setting','across all ten networks.','','Primary paired result unavailable','under the predeclared selection rule.'}, ...
                        'HorizontalAlignment','center','FontSize',15,'Units','normalized');
                end
                sgtitle(f,'No primary selected; no substitute network or relaxed constraints','FontSize',19);
            elseif figIndex==1
                ax=nexttile; hold(ax,'on'); I=zeros(10,501); B=I;
                for n=1:10, I(n,:)=r.primary{n}.intactDistance; B(n,:)=r.primary{n}.block.distance; end
                for n=1:10
                    plot(ax,-500:0,I(n,:),'Color',.65+.35*blue,'HandleVisibility','off');
                    plot(ax,-500:0,B(n,:),'Color',.65+.35*orange,'HandleVisibility','off');
                end
                band(ax,-500:0,I,r.bootstrapIndices,blue,'Intact'); band(ax,-500:0,B,r.bootstrapIndices,orange,'Block');
                xlabel(ax,'Time from GO (ms)'); ylabel(ax,'Mean target distance to x^* (state units)');
                title(ax,'A  Cortical preparation','FontWeight','normal'); legend(ax,'Location','northeast'); apply_plot_style(ax,cfg);
                ax=nexttile; hold(ax,'on'); style=stage_1_gate1_config(cfg.projectRoot); colors=style.plot.colors;
                p=r.primary{1};
                for q=1:8
                    plot(ax,1000*p.intactHand(:,1,q),1000*p.intactHand(:,3,q),'-','Color',colors(q,:),'LineWidth',1.8,'HandleVisibility','off');
                    plot(ax,1000*p.blockHand(:,1,q),1000*p.blockHand(:,3,q),'--','Color',colors(q,:),'LineWidth',1.8,'HandleVisibility','off');
                    target=squeeze(p.targetHand(end,[1 3],q));
                    plot(ax,1000*target(1),1000*target(2),'o','Color',colors(q,:),'MarkerSize',8,'LineWidth',1.5,'HandleVisibility','off');
                end
                plot(ax,NaN,NaN,'k-','LineWidth',1.8,'DisplayName','Intact'); plot(ax,NaN,NaN,'k--','LineWidth',1.8,'DisplayName','Block');
                axis(ax,'equal'); xlabel(ax,'Hand x (mm)'); ylabel(ax,'Hand y (mm)'); title(ax,'B  Network 1: all eight targets','FontWeight','normal');
                legend(ax,'Location','southoutside'); apply_plot_style(ax,cfg);
                ax=nexttile; paired(ax,r.metrics.earlyErrorMM,{'Intact','Block'},[blue;orange],r.bootstrapIndices,cfg);
                ylabel(ax,'Early trajectory RMS error (mm)'); title(ax,'C  Movement consequence','FontWeight','normal');
                sgtitle(f,'Actual GO-state release; movement outcomes did not select solutions','FontSize',18);
            elseif figIndex==2
                ax=nexttile; hold(ax,'on'); I=zeros(10,15); B=I;
                for n=1:10
                    p=r.primary{n}; I(n,:)=p.intactGeometry.eigenvalues(1:15)/sum(p.intactGeometry.eigenvalues);
                    B(n,:)=p.block.geometry.eigenvalues(1:15)/sum(p.block.geometry.eigenvalues);
                end
                intactLine=band(ax,1:15,I,r.bootstrapIndices,blue,'Intact'); blockLine=band(ax,1:15,B,r.bootstrapIndices,orange,'Block');
                xlabel(ax,'Principal component'); ylabel(ax,'Fraction of prep variance'); title(ax,'A  Measured finite-window spectra','FontWeight','normal');
                legend(ax,[intactLine blockLine],{'Intact','Block'},'Location','northeast','AutoUpdate','off'); xlim(ax,[1 15]); apply_plot_style(ax,cfg);
                ax=nexttile; paired(ax,r.metrics.pr,{'Intact','Block'},[blue;orange],r.bootstrapIndices,cfg);
                ylabel(ax,'Participation ratio'); title(ax,'B  Preparatory dimensionality','FontWeight','normal');
                ylim(ax,[2.8 7.3]);
                ax=nexttile; paired(ax,r.metrics.alignmentObservedExpected,{'Observed','Expected'},[.2 .2 .2;gray],r.bootstrapIndices,cfg);
                ylabel(ax,'Intact projected onto block'); ylim(ax,[0 1]); title(ax,'C  Directed alignment','FontWeight','normal');
                sgtitle(f,'GO -100:10:0 ms | geometry is a construction constraint, not an independent prediction','FontSize',18);
            else
                vals=zeros(10,4,3);
                for n=1:10
                    for p=1:4
                        s=r.primary{n}.policies{p}; vals(n,p,:)=[s.stateError,s.pr,s.expected-s.observed];
                    end
                end
                labels={'State distance to x^*','Participation ratio','Expected - observed alignment'};
                titles={'A  Prepared-state error','B  Prep dimensionality','C  Below-null alignment'};
                for p=1:3
                    ax=nexttile; paired(ax,vals(:,:,p),{'Intact','Remove b','Remove feedback','Remove both'}, ...
                        [blue;.5 .3 .7;.6 .6 .6;orange],r.bootstrapIndices,cfg);
                    xtickangle(ax,25); ylabel(ax,labels{p}); title(ax,titles{p},'FontWeight','normal');
                    if p==2, ylim(ax,[2.8 7.3]); end
                end
                sgtitle(f,'Component removal: same cortical policy, gains and initial state','FontSize',18);
            end
        end
        [paths{figIndex,1},paths{figIndex,2}]=save_figure_bundle(f,names{figIndex},cfg);
        reopened=openfig(paths{figIndex,1},'invisible'); assert(isgraphics(reopened)); close(reopened);
        info=imfinfo(paths{figIndex,2}); assert(info.Width>1000 && info.Height>400);
    end
end

function h = band(ax,x,values,indices,color,label)
    summary=stage2_bootstrap(values,indices); x=x(:).'; y=summary.median; e=summary.se;
    fill(ax,[x fliplr(x)],[y-e fliplr(y+e)],color,'FaceAlpha',.17,'EdgeColor','none','HandleVisibility','off');
    h=plot(ax,x,y,'Color',color,'LineWidth',2.2,'DisplayName',label);
end

function paired(ax,values,labels,colors,indices,cfg)
    hold(ax,'on'); count=size(values,2);
    plot(ax,1:count,values.','-','Color',[.8 .8 .8],'LineWidth',.8);
    summary=stage2_bootstrap(values,indices);
    for j=1:count
        scatter(ax,j*ones(10,1),values(:,j),22,colors(j,:),'filled');
        errorbar(ax,j,summary.median(j),summary.se(j),'o','Color',colors(j,:), ...
            'MarkerFaceColor','w','MarkerSize',9,'LineWidth',2,'CapSize',12);
    end
    xlim(ax,[.6 count+.4]); xticks(ax,1:count); xticklabels(ax,labels); apply_plot_style(ax,cfg);
end
