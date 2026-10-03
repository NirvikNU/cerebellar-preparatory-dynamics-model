function fb22_render(d,records,panel,version,limits,folder)
    for sub={'fig','png'}, path=fullfile(folder,sub{1}); if ~isfolder(path), mkdir(path); end, end
    f=figure('Visible','off','Color','w','Position',[30 30 1450 760]);
    f.UserData=struct('network',8,'seed',panel.seed,'version',version,'reviewOnly',true,'balancedSuccessFailure',true);
    for p=1:2
        ax=axes(f,'Position',[.07+(p-1)*.49 .20 .40 .66]); hold(ax,'on');
        set(ax,'FontName','Arial','FontSize',15,'TickDir','out','Box','off');
        for q=1:8
            color=d.targetColors(q,:); ang=linspace(0,2*pi,101);
            plot(ax,100*d.targetXY(q,1)+1.5*cos(ang),100*d.targetXY(q,2)+1.5*sin(ang), ...
                'Color',color,'LineWidth',.7,'HandleVisibility','off','Tag',sprintf('zone_%d',q));
            for at=panel.chosen(:,q,p).'
                xy=100*records(at).xy; h=plot(ax,xy(:,1),xy(:,2),'-','Color',color,'LineWidth',.65);
                h.UserData=struct('kind','trajectory','condition',p,'target',q,'record',at,'success',records(at).row(6));
            end
            xy=100*panel.means(:,:,q,p); h=plot(ax,xy(:,1),xy(:,2),'-','Color',color,'LineWidth',2.4);
            h.UserData=struct('kind','sixPhaseMean','condition',p,'target',q,'records',panel.chosen(:,q,p));
        end
        xlabel(ax,'Hand x (cm)'); ylabel(ax,'Hand y (cm)'); axis(ax,'equal');
        xlim(ax,limits(:,1).'); ylim(ax,limits(:,2).');
        title(ax,{sprintf('Option %d | %s | network 8',version,d.names{p}),sprintf('Seed %d: 3 random successes + 3 random failures',panel.seed)});
    end
    annotation(f,'textbox',[.035 .01 .93 .08],'String', ...
        {'Balanced illustration, not the actual success rate. No ranking or rerolls.', ...
        'Thin: entry-truncated successes / failures to 599 ms. Thick: 101-point phase mean of the same six.'}, ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',13);
    name=sprintf('Fig6f_balanced_option%d_seed%d',version,panel.seed);
    fig=fullfile(folder,'fig',[name '.fig']); png=fullfile(folder,'png',[name '.png']);
    assert(~isfile(fig) && ~isfile(png)); drawnow; savefig(f,fig); exportgraphics(f,png,'Resolution',160); close(f);
end
