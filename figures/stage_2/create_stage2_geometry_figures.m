function create_stage2_geometry_figures(cfg)
    % R2 regenerates exactly three pairs; never writes Results Figures 1 or 2.
    saved=load(fullfile(cfg.resultsRoot,'analysis.mat'),'out'); o=saved.out;
    assert(isequal(o.cfg,cfg));
    control=[.1 .5 .7]; expected=[.55 .55 .55]; orange=[.85 .325 .1];
    f=figure('Visible','off','Color','w','Position',[100 100 720 650]);
    ax=axes(f); hold(ax,'on');
    plot(ax,[1 2],100*[o.prepMoveObserved o.prepMoveExpected].','-o', ...
        'Color',[.75 .75 .75],'MarkerSize',4,'LineWidth',.8);
    errorbar(ax,1,100*o.summary.prepMoveObserved.median,100*o.summary.prepMoveObserved.se,'o', ...
        'Color',control,'MarkerFaceColor',control,'MarkerSize',9,'LineWidth',2,'CapSize',12);
    errorbar(ax,2,100*o.summary.prepMoveExpected.median,100*o.summary.prepMoveExpected.se,'o', ...
        'Color',expected,'MarkerFaceColor',expected,'MarkerSize',9,'LineWidth',2,'CapSize',12);
    xlim(ax,[.6 2.4]); xticks(ax,[1 2]); xticklabels(ax,{'Observed','Expected'});
    ylabel(ax,'Prep variance alignment (%)');
    title(ax,{'Reference Prep projected onto Move', ...
        sprintf('Common K = %s | exact paired p = %.5g',klabel(o.prepMoveCommonK),o.prepMoveTest.p), ...
        'Prep: cue +150:+450 ms | Move: MO -50:+350 ms'},'FontSize',16);
    apply_plot_style(ax,cfg); save_figure_bundle(f,'result_3_prep_move_alignment',cfg);
    f=figure('Visible','off','Color','w','Position',[80 80 900 620]); ax=axes(f); hold(ax,'on');
    networks(ax,cfg.lambda,o.pr,control);
    errorbar(ax,cfg.lambda,o.summary.pr.median,o.summary.pr.se,'-o','Color',control, ...
        'MarkerFaceColor',control,'MarkerSize',7,'LineWidth',2,'CapSize',8);
    ylabel(ax,'Preparatory participation ratio');
    title(ax,{sprintf('Prep PR | slope exact p = %.5g',o.prSlopeTest.p), ...
        'GO -100:0 ms | reference SD normalization, no floor'},'FontSize',16);
    log_style(ax,cfg); save_figure_bundle(f,'diagnostic_1_pr_lambda',cfg);
    f=figure('Visible','off','Color','w','Position',[60 60 1400 610]);
    tl=tiledlayout(f,1,2,'TileSpacing','compact','Padding','compact');
    ax=nexttile(tl); hold(ax,'on');
    networks(ax,cfg.lambda,100*o.observed,control);
    networks(ax,cfg.lambda,100*o.expected,expected);
    h1=errorbar(ax,cfg.lambda,100*o.summary.observed.median,100*o.summary.observed.se,'-o', ...
        'Color',control,'MarkerFaceColor',control,'LineWidth',2,'MarkerSize',6,'CapSize',8);
    h2=errorbar(ax,cfg.lambda,100*o.summary.expected.median,100*o.summary.expected.se,'--s', ...
        'Color',expected,'LineWidth',2,'MarkerSize',5,'CapSize',8);
    title(ax,{'A  Reference Prep projected onto each \lambda', ...
        sprintf('Common K = %s; each space >95%% variance',klabel(o.commonK))});
    ylabel(ax,'Alignment (%)');
    legend(ax,[h1 h2],{'Observed','Expected'},'Location','best','FontSize',13); log_style(ax,cfg);
    ax=nexttile(tl); hold(ax,'on'); networks(ax,cfg.lambda,100*o.deficit,orange);
    errorbar(ax,cfg.lambda,100*o.summary.deficit.median,100*o.summary.deficit.se,'-o', ...
        'Color',orange,'MarkerFaceColor',orange,'LineWidth',2,'MarkerSize',6,'CapSize',8);
    yline(ax,0,':','HandleVisibility','off'); ylabel(ax,'Expected - observed (percentage points)');
    title(ax,{'B  Alignment deficit',sprintf('Slope exact p = %.5g',o.deficitSlopeTest.p)});
    log_style(ax,cfg); save_figure_bundle(f,'diagnostic_2_alignment_lambda',cfg);
end

function label = klabel(values)
    low=min(values,[],'all'); high=max(values,[],'all');
    if low==high, label=sprintf('%d',low); else, label=sprintf('%d-%d',low,high); end
end

function networks(ax,x,y,color)
    plot(ax,x,y.','Color',.72+.28*color,'LineWidth',.7,'HandleVisibility','off');
end

function log_style(ax,cfg)
    set(ax,'XScale','log'); xticks(ax,cfg.lambda); xlim(ax,[.08 130]);
    xlabel(ax,'Controller effort penalty \lambda');
    xline(ax,.1,':','Reference','HandleVisibility','off','LabelVerticalAlignment','bottom');
    apply_plot_style(ax,cfg);
end
