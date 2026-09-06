function create_stage2_figures(cfg)
    saved = load(fullfile(cfg.resultsRoot,'analysis.mat'),'out');
    o = saved.out;
    stage1Style=published_generator_config(cfg.projectRoot);
    targetColors=stage1Style.plot.colors;
    colors = turbo(8);
    control = [0.1 0.5 0.7];
    expected = [0.55 0.55 0.55];
    orange = [0.85 0.325 0.1];
    f = figure('Visible','off','Color','w','Position',[60 60 1000 900]);
    tl = tiledlayout(f,2,2,'TileSpacing','compact','Padding','compact');
    handLimit=12;
    for d=1:4
        h=o.demoHand{d};
        relative=100*(h(:,[1 3],:)-h(1,[1 3],:));
        handLimit=max(handLimit,ceil(1.05*max(abs(relative),[],'all')));
    end
    for d = 1:4
        ax = nexttile(tl); hold(ax,'on');
        hand = o.demoHand{d};
        for target = 1:8
            trajectory = squeeze(hand(:,[1 3],target));
            start = trajectory(1,:);
            trajectory = 100*(trajectory-start);
            angle = [-90 -45 0 45 90 135 180 225];
            endpoint = 10*[cosd(angle(target)) sind(angle(target))];
            plot(ax,trajectory(:,1),trajectory(:,2),'Color',targetColors(target,:),'LineWidth',1.8);
            plot(ax,endpoint(1),endpoint(2),'o','Color',targetColors(target,:),'MarkerSize',7,'LineWidth',1.5);
        end
        axis(ax,'equal'); xlim(ax,[-handLimit handLimit]); ylim(ax,[-handLimit handLimit]);
        xlabel(ax,'Hand x (cm)'); ylabel(ax,'Hand y (cm)');
        title(ax,sprintf('%c  %d ms preparation','A'+d-1,cfg.demoMs(d)));
        apply_plot_style(ax,cfg);
    end
    title(tl,'Reference \lambda = 0.1 | preselected network 1','FontSize',18);
    save_figure_bundle(f,'result_1_preparation_trajectories',cfg);
    f = figure('Visible','off','Color','w','Position',[30 80 1600 570]);
    tl = tiledlayout(f,1,3,'TileSpacing','compact','Padding','compact');
    t = 0:500;
    ax = nexttile(tl); hold(ax,'on');
    network_lines(ax,t,squeeze(o.error(:,:,1)),control);
    band(ax,t,o.summary.error.median(1:501),o.summary.error.se(1:501),control,'Reference');
    xlabel(ax,'Preparation time (ms)'); ylabel(ax,'Prospective error (% initial)');
    title(ax,'A  Reference \lambda = 0.1'); xlim(ax,[0 500]); marks(ax); apply_plot_style(ax,cfg);
    ax = nexttile(tl); hold(ax,'on'); handles=gobjects(1,8);
    for l = 1:8
        rows = (l-1)*501+(1:501);
        handles(l)=band(ax,t,o.summary.error.median(rows),o.summary.error.se(rows),colors(l,:),num2str(cfg.lambda(l)));
    end
    xlabel(ax,'Preparation time (ms)'); ylabel(ax,'Prospective error (% initial)');
    title(ax,'B  Fixed effort-penalty sweep'); xlim(ax,[0 500]); marks(ax); apply_plot_style(ax,cfg);
    lg=legend(ax,handles,string(cfg.lambda),'Location','northeast','FontSize',10,'NumColumns',2); title(lg,'\lambda');
    ax = nexttile(tl); hold(ax,'on');
    network_lines(ax,t,squeeze(o.perturbation(:,:,1)),orange);
    network_lines(ax,t,squeeze(o.perturbation(:,:,2)),control);
    h1=band(ax,t,o.summary.perturbation.median(1:501),o.summary.perturbation.se(1:501),orange,'Most potent');
    h2=band(ax,t,o.summary.perturbation.median(502:1002),o.summary.perturbation.se(502:1002),control,'Least potent');
    xlabel(ax,'Time from perturbation (ms)'); ylabel(ax,'Squared state error (source units^2)');
    title(ax,'C  Approved Fig. 4F analogue'); xlim(ax,[0 500]);
    legend(ax,[h1 h2],{'Top 10 Q directions','Bottom 10 Q directions'},'Location','best','FontSize',12);
    apply_plot_style(ax,cfg);
    save_figure_bundle(f,'result_2_controller_operation',cfg);
    f = figure('Visible','off','Color','w','Position',[100 100 620 600]);
    ax=axes(f); hold(ax,'on');
    plot(ax,[1 2],100*[o.prepMove o.expected].','-o','Color',[.75 .75 .75], ...
        'MarkerSize',4,'LineWidth',0.8);
    errorbar(ax,1,100*o.summary.prepMove.median,100*o.summary.prepMove.se,'o', ...
        'Color',control,'MarkerFaceColor',control,'MarkerSize',9,'LineWidth',2,'CapSize',12);
    errorbar(ax,2,100*o.summary.expected.median,100*o.summary.expected.se,'o', ...
        'Color',expected,'MarkerFaceColor',expected,'MarkerSize',9,'LineWidth',2,'CapSize',12);
    xlim(ax,[.6 2.4]); xticks(ax,[1 2]); xticklabels(ax,{'Observed','Expected'});
    ylabel(ax,'Prep variance alignment (%)');
    title(ax,{'Reference Prep projected onto Move',sprintf('15 PCs | exact paired p = %.5g',o.prepMoveTest.p)},'FontSize',16);
    apply_plot_style(ax,cfg); save_figure_bundle(f,'result_3_prep_move_alignment',cfg);
    f=figure('Visible','off','Color','w','Position',[80 80 850 580]); ax=axes(f); hold(ax,'on');
    network_lines(ax,cfg.lambda,o.pr(:,:,1),control);
    errorbar(ax,cfg.lambda,o.summary.pr.median(1:8),o.summary.pr.se(1:8),'-o', ...
        'Color',control,'MarkerFaceColor',control,'MarkerSize',7,'LineWidth',2,'CapSize',8);
    set(ax,'XScale','log'); xticks(ax,cfg.lambda); xlim(ax,[.08 130]);
    xlabel(ax,'Controller effort penalty \lambda'); ylabel(ax,'Preparatory participation ratio');
    title(ax,sprintf('Prep PR | slope exact p = %.5g',o.prSlopeTest.p),'FontSize',16);
    xline(ax,.1,':','Reference','HandleVisibility','off','LabelVerticalAlignment','bottom');
    apply_plot_style(ax,cfg); save_figure_bundle(f,'diagnostic_1_pr_lambda',cfg);
    f=figure('Visible','off','Color','w','Position',[60 60 1350 570]);
    tl=tiledlayout(f,1,2,'TileSpacing','compact','Padding','compact');
    ax=nexttile(tl); hold(ax,'on'); network_lines(ax,cfg.lambda,100*o.observed,control);
    h1=errorbar(ax,cfg.lambda,100*o.summary.observed.median,100*o.summary.observed.se,'-o', ...
        'Color',control,'MarkerFaceColor',control,'LineWidth',2,'MarkerSize',6,'CapSize',8);
    h2=errorbar(ax,cfg.lambda,repmat(100*o.summary.expected.median,1,8), ...
        repmat(100*o.summary.expected.se,1,8),'--s','Color',expected,'LineWidth',2,'MarkerSize',5,'CapSize',8);
    title(ax,'A  Reference Prep projected onto each \lambda'); ylabel(ax,'Alignment (%)');
    legend(ax,[h1 h2],{'Observed','Expected'},'Location','best','FontSize',13); log_style(ax,cfg);
    ax=nexttile(tl); hold(ax,'on'); network_lines(ax,cfg.lambda,100*o.deficit,orange);
    errorbar(ax,cfg.lambda,100*o.summary.deficit.median,100*o.summary.deficit.se,'-o', ...
        'Color',orange,'MarkerFaceColor',orange,'LineWidth',2,'MarkerSize',6,'CapSize',8);
    yline(ax,0,':','HandleVisibility','off'); ylabel(ax,'Expected - observed (percentage points)');
    title(ax,sprintf('B  Alignment deficit | slope p = %.5g',o.deficitSlopeTest.p));
    log_style(ax,cfg); save_figure_bundle(f,'diagnostic_2_alignment_lambda',cfg);
    figs=dir(fullfile(cfg.plotsFigRoot,'*.fig'));
    assert(numel(figs)==5 && numel(dir(fullfile(cfg.plotsPngRoot,'*.png')))==5);
    for j=1:numel(figs)
        reopened=openfig(fullfile(figs(j).folder,figs(j).name),'invisible');
        axesList=findall(reopened,'Type','axes');
        assert(all(arrayfun(@(a)a.FontSize==16,axesList)));
        assert(~isempty(findall(reopened,'Type','line')));
        drawnow; close(reopened);
    end
end

function handle = band(ax,x,medianValue,se,color,name)
    lower=medianValue-se; upper=medianValue+se;
    fill(ax,[x fliplr(x)],[lower fliplr(upper)],color, ...
        'FaceAlpha',.15,'EdgeColor','none','HandleVisibility','off');
    handle=plot(ax,x,medianValue,'Color',color,'LineWidth',2,'DisplayName',name);
end

function network_lines(ax,x,y,color)
    pale=.72+[.28 .28 .28].*color;
    plot(ax,x,y.','Color',pale,'LineWidth',.7,'HandleVisibility','off');
end

function marks(ax)
    xline(ax,100,':','HandleVisibility','off');
    xline(ax,200,'--','HandleVisibility','off');
end

function log_style(ax,cfg)
    set(ax,'XScale','log'); xticks(ax,cfg.lambda); xlim(ax,[.08 130]);
    xlabel(ax,'Controller effort penalty \lambda');
    xline(ax,.1,':','Reference','HandleVisibility','off','LabelVerticalAlignment','bottom');
    apply_plot_style(ax,cfg);
end
