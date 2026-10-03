function f518_render(d,panel,version,limits,folder)
    for sub={'fig','png'}, path=fullfile(folder,sub{1}); if ~isfolder(path), mkdir(path); end, end
    f=figure('Visible','off','Color','w','Position',[30 30 1450 760]);
    f.UserData=struct('network',8,'seed',panel.seed,'version',version,'reviewOnly',true);
    for p=1:2
        ax=axes(f,'Position',[.07+(p-1)*.49 .15 .40 .70]); hold(ax,'on');
        set(ax,'FontName','Arial','FontSize',15,'TickDir','out','Box','off');
        c=d.condition{p};
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
        end
        xlabel(ax,'Hand x (cm)'); ylabel(ax,'Hand y (cm)'); axis(ax,'equal');
        xlim(ax,limits(:,1).'); ylim(ax,limits(:,2).');
        title(ax,{sprintf('Option %d | %s | network 8',version,d.names{p}),sprintf('Seed %d: 4 random successes + same-four mean',panel.seed)});
    end
    annotation(f,'textbox',[.05 .015 .9 .06],'String','Review candidate: one uniform draw per target/condition; 101-point phase means of the same four shown.', ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',13);
    name=sprintf('Fig6f_option%d_seed%d',version,panel.seed); fig=fullfile(folder,'fig',[name '.fig']); png=fullfile(folder,'png',[name '.png']);
    assert(~isfile(fig) && ~isfile(png)); drawnow; savefig(f,fig); exportgraphics(f,png,'Resolution',160); close(f);
end
