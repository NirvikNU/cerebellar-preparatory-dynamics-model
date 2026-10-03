function receipt=fd14_display_repair(root)
    % Pure graphical repair of this task's provisional h only; preserve source arrays.
    addpath(fullfile(root,'analysis/paper_ready'),fullfile(root,'analysis/paper_ready/prospective_variability'));
    base='fig6fgh_highrms14'; docs=fullfile(root,'docs/paper_ready/final_v3',base);
    files=dir(fullfile(root,'analysis/paper_ready/final_v3',base,'*.m')); issues={};
    for file=files.'
        found=checkcode(fullfile(file.folder,file.name),'-id');
        if ~isempty(found), issues{end+1}=struct('file',file.name,'issues',found); end %#ok<AGROW> Bounded files.
    end
    paper_json(fullfile(docs,'code_analyzer_final.json'),struct('files',numel(files),'issues',{issues})); assert(isempty(issues));
    cache=fullfile(root,'results/paper_ready/cache',base); backup=fullfile(cache,'provisional_h'); assert(~isfolder(backup)); mkdir(backup);
    plots=fullfile(root,'plots/paper_ready/final_v3',base);
    fig=fullfile(plots,'fig','Fig6h.fig'); png=fullfile(plots,'png','Fig6h.png');
    copyfile(fig,fullfile(backup,'Fig6h.fig')); copyfile(png,fullfile(backup,'Fig6h.png'));
    f=openfig(fig,'invisible'); cleanup=onCleanup(@()close(f)); ax=findall(f,'Tag','empiricalOverlay');
    for h=findall(ax,'Type','patch').'
        u=h.UserData; assert(strcmp(u.kind,'trajectory')); color=h.EdgeColor;
        s=surface(ax,[u.x u.x],[u.y u.y],zeros(numel(u.x),2),'FaceColor','none','EdgeColor',color,'EdgeAlpha',.35,'LineWidth',.8,'LineStyle','-');
        s.UserData=u; delete(h);
    end
    % Put filled position markers above faint paths; no data-coordinate changes.
    uistack(findall(ax,'Type','scatter'),'top');
    key=findall(f,'Tag','targetDirectionKey'); ylim(key,[-1.6 1.4]);
    drawnow; savefig(f,fig); exportgraphics(f,png,'Resolution',160); clear cleanup
    z=load(fullfile(cache,'display_sources.mat'),'d');
    receipt=fd14_figcheck(root,z.d,plots);
    paper_json(fullfile(root,'results/paper_ready/final_v3',base,'final_figure_validation.json'),receipt); disp(receipt);
end
