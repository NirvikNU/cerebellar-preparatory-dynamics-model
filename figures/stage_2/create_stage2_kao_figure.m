function create_stage2_kao_figure(out)
    % Add only Figure 4; manuscript-matched Figure 3 remains unchanged.
    cfg=out.cfg;
    f=figure('Visible','off','Color','w','Position',[100 100 900 720]);
    ax=axes(f,'Position',[.13 .12 .8 .66]); hold(ax,'on');
    plot(ax,[1 2],100*[out.observed out.expected].','-o', ...
        'Color',[.75 .75 .75],'MarkerSize',4,'LineWidth',.8);
    colors=[.1 .5 .7; .55 .55 .55];
    summaries={out.summary.observed,out.summary.expected};
    for j=1:2
        errorbar(ax,j,100*summaries{j}.median,100*summaries{j}.se,'o', ...
            'Color',colors(j,:),'MarkerFaceColor',colors(j,:),'MarkerSize',9, ...
            'LineWidth',2,'CapSize',12);
    end
    xlim(ax,[.6 2.4]); ylim(ax,[0 100]); xticks(ax,[1 2]); xticklabels(ax,{'Observed','Expected'});
    ylabel(ax,'Prep variance alignment (%)');
    title(ax,{'Kao-method Prep-to-Move alignment validation', ...
        sprintf('\\lambda = 0.1 | Prep 80%% K = %d-%d | p = %.5g', ...
        min(out.k),max(out.k),out.summary.test.p), ...
        'Prep: cue +150:+450 | Move: MO -50:+250 ms', ...
        'Kao MO = GO +100 ms | range+5 normalization'},'FontSize',16);
    apply_plot_style(ax,cfg);
    save_figure_bundle(f,'result_4_kao_prep_move_alignment',cfg);
end
