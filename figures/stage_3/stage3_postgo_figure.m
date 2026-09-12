function paths = stage3_postgo_figure(root)
    addpath(fullfile(root,'analysis','stage_3')); cfg=stage3_postgo_paths(root);
    audit=jsondecode(fileread(fullfile(cfg.postRoot,'independent_audit.json'))); assert(strcmp(audit.status,'PASS'));
    loaded=load(fullfile(cfg.postRoot,'summary.mat'),'summary'); s=loaded.summary;
    name='diagnostic_5_postgo_noise_causal';
    assert(~isfile(fullfile(cfg.plotsFigRoot,[name '.fig'])) && ~isfile(fullfile(cfg.plotsPngRoot,[name '.png'])));
    colors=[.1 .5 .7;.15 .55 .4;.55 .3 .7;.85 .325 .1];
    labels={'Intact','Remove FB','Remove b','Block'}; markers={'o','s','^'};
    f=figure('Visible','off','Color','w','Position',[30 30 1850 1080]);
    f.UserData=struct('task',cfg.task,'checkpoint',cfg.checkpoint,'sourceSummary', ...
        'results/stage_3/current/postgo_noise_diagnostic/summary.mat','independentN',10);
    tiles=tiledlayout(f,2,3,'Padding','loose','TileSpacing','loose'); cfg.plot.fontSize=14;
    headings={'A  Prep to hand position','B  Prep to peak speed','C  Within-target hand position', ...
        'D  Within-target peak speed','E  Within-target peak-speed variance','F  Within-target hand-position variance'};
    for panel=1:6
        ax=nexttile(tiles); hold(ax,'on');
        if panel<=4, values=reshape(s.metrics(:,:,:,panel),10,4,2);
        else, values=1e6*reshape(s.variance(:,:,1:3,panel-4),10,4,3); end
        count=size(values,3); offsets=linspace(-.22,.22,count);
        for policy=1:4
            for c=1:count
                v=values(:,policy,c); b=stage2_bootstrap(v,s.bootstrapIndices); x=policy+offsets(c);
                face='none'; if c==2, face=colors(policy,:); end
                plot(ax,x+linspace(-.05,.05,10).',v,markers{c},'Color',colors(policy,:), ...
                    'MarkerFaceColor',face,'MarkerSize',4,'LineWidth',.8,'HandleVisibility','off');
                e=errorbar(ax,x,b.median,b.se,markers{c},'Color',colors(policy,:), ...
                    'MarkerFaceColor',face,'MarkerSize',9,'LineWidth',1.8,'CapSize',10, ...
                    'Tag',sprintf('panel%d_policy%d_condition%d',panel,policy,c),'HandleVisibility','off');
                e.UserData=struct('panel',panel,'policy',policy,'condition',c);
            end
        end
        xlim(ax,[.5 4.5]); xticks(ax,1:4); xticklabels(ax,labels); xtickangle(ax,12);
        title(ax,headings{panel},'FontWeight','normal');
        if panel<=4
            ylabel(ax,'Cross-validated R^2'); yline(ax,0,':','Color',[.5 .5 .5],'HandleVisibility','off');
        elseif panel==5
            ylabel(ax,'Peak-speed variance ((mm/s)^2)');
        else
            ylabel(ax,'Hand-position covariance trace (mm^2)');
        end
        apply_plot_style(ax,cfg);
        if panel==1 || panel==5
            handles=gobjects(count,1);
            for c=1:count
                face='none'; if c==2, face=[.3 .3 .3]; end
                handles(c)=plot(ax,nan,nan,markers{c},'Color',[.3 .3 .3],'MarkerFaceColor',face, ...
                    'MarkerSize',7,'LineWidth',1.3);
            end
            legend(ax,handles,s.conditionNames(1:count),'Location','best','FontSize',11);
        end
    end
    title(tiles,{'Stage 3 | Post-GO-noise counterfactual | s = 0.10', ...
        'Full and Prep-only share the exact achieved GO state; small points: 10 networks; large markers: median +/- fixed bootstrap SE'}, ...
        'FontSize',18,'FontWeight','normal');
    paths=cell(1,2); [paths{1},paths{2}]=save_figure_bundle(f,name,cfg);
    reopened=openfig(paths{1},'invisible'); bars=findall(reopened,'Type','errorbar'); assert(numel(bars)==56);
    maxError=0;
    for j=1:numel(bars)
        u=bars(j).UserData;
        if u.panel<=4, v=s.metrics(:,u.policy,u.condition,u.panel);
        else, v=1e6*s.variance(:,u.policy,u.condition,u.panel-4); end
        samples=median(reshape(v(s.bootstrapIndices),10000,10),2);
        se=sqrt(sum((samples-mean(samples)).^2)/9999);
        err=max(abs([bars(j).YData-median(v),bars(j).YNegativeDelta-se,bars(j).YPositiveDelta-se]));
        maxError=max(maxError,err); assert(err<1e-9);
    end
    close(reopened); im=imread(paths{2}); assert(size(im,1)>1000 && size(im,2)>1500);
    stage3_write_json(fullfile(cfg.postRoot,'figure_audit.json'), ...
        struct('status','PASS','errorbarSeries',56,'maxAbsoluteError',maxError,'paths',{paths}));
end
