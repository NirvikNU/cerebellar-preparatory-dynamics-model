function receipt=fr23_render_g(d,folder)
    for sub={'fig','png'}, p=fullfile(folder,sub{1}); if ~isfolder(p), mkdir(p); end, end
    receipt=struct('figures',{{}},'network',d.selectedNetwork,'target',d.selectedTarget);
    q=d.selectedTarget; styles={'-','-'};
    f=canvas([1100 750],d); ax=axes(f,'Position',[.12 .17 .83 .65]); style(ax); handles=gobjects(1,2);
    for p=1:2
        c=d.condition{p}; color=d.conditionColors(p,:);
        for tr=d.displayIDs{p}.'
            y=c.alignedSpeed(:,tr); h=plot(ax,d.timesMs,y,styles{p},'Color',color,'LineWidth',.5,'HandleVisibility','off');
            h.UserData=record('selectedRawSpeed',p,q,tr,d.timesMs,y);
        end
        y=c.medianSpeed(:,q); handles(p)=plot(ax,d.timesMs,y,styles{p},'Color',color,'LineWidth',2.8,'DisplayName',d.names{p});
        handles(p).UserData=record('selected15MedianSpeed',p,q,0,d.timesMs,y);
    end
    xlabel(ax,'Time from movement onset (ms)'); ylabel(ax,'Speed (m/s)'); xlim(ax,[0 600]);
    title(ax,{sprintf('6g  Hand speed | network %d, target %d',d.selectedNetwork,q), ...
        '15 successes (original 10 + 5 added) + selected-15 median'});
    legend(ax,handles,'Location','northeast','AutoUpdate','off');
    annotation(f,'textbox',[.05 .015 .9 .07],'String','Median only: full-support Gaussian 50 ms, then nActive >= 8 display cutoff. Thin traces unsmoothed.', ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',12);
    receipt=savePanel(receipt,f,folder,'Fig6g');

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
