function fs21_render(d,panel,limits,folder)
    for sub={'fig','png'}, path=fullfile(folder,sub{1}); if ~isfolder(path), mkdir(path); end, end
    f=figure('Visible','off','Color','w','Position',[30 30 1450 760]);
    f.UserData=struct('network',8,'reviewOnly',true,'scatterMatched',true,'random',false,'contrastSelected',false);
    for p=1:2
        ax=axes(f,'Position',[.07+(p-1)*.49 .20 .40 .66]); hold(ax,'on');
        set(ax,'FontName','Arial','FontSize',15,'TickDir','out','Box','off'); c=d.condition{p};
        for q=1:8
            color=d.targetColors(q,:); ang=linspace(0,2*pi,101);
            plot(ax,100*d.targetXY(q,1)+1.5*cos(ang),100*d.targetXY(q,2)+1.5*sin(ang), ...
                'Color',color,'LineWidth',.7,'HandleVisibility','off','Tag',sprintf('zone_%d',q));
            for tr=panel.chosen(:,q,p).'
                xy=100*c.xy(:,:,tr); h=plot(ax,xy(:,1),xy(:,2),'-','Color',color,'LineWidth',.65);
                h.UserData=struct('kind','trajectory','condition',p,'target',q,'trial',tr);
            end
            xy=100*panel.means(:,:,q,p); h=plot(ax,xy(:,1),xy(:,2),'-','Color',color,'LineWidth',2.4);
            h.UserData=struct('kind','fourPhaseMean','condition',p,'target',q,'trials',panel.chosen(:,q,p));
            xy=100*c.peakXY(panel.chosen(:,q,p),:); h=scatter(ax,xy(:,1),xy(:,2),28,color,'filled','Marker','o','MarkerEdgeColor',color);
            h.UserData=struct('kind','peakPositions','condition',p,'target',q,'trials',panel.chosen(:,q,p));
        end
        xlabel(ax,'Hand x (cm)'); ylabel(ax,'Hand y (cm)'); axis(ax,'equal');
        xlim(ax,limits(:,1).'); ylim(ax,limits(:,2).');
        if p==1, label='Intact / Control'; else, label='Block'; end
        title(ax,{sprintf('%s | network 8',label),'4 successes matched to the full peak-position scatter'});
    end
    annotation(f,'textbox',[.04 .01 .92 .065],'String', ...
        {'SCATTER-MATCHED illustration - not random or contrast-selected.', ...
        'Circles: selected peak positions. Thick: 101-point phase mean of the same four paths.'}, ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',13);
    name='Fig6f_scatter_matched'; fig=fullfile(folder,'fig',[name '.fig']); png=fullfile(folder,'png',[name '.png']);
    assert(~isfile(fig) && ~isfile(png)); drawnow; savefig(f,fig); exportgraphics(f,png,'Resolution',160); close(f);
end
