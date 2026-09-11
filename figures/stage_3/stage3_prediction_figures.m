function paths = stage3_prediction_figures(root)
    addpath(fullfile(root,'analysis','stage_3'));
    cfg=stage3_prediction_paths(root);
    audit=jsondecode(fileread(fullfile(cfg.predRoot,'independent_audit.json'))); assert(strcmp(audit.status,'PASS'));
    loaded=load(fullfile(cfg.predRoot,'summary.mat'),'summary'); s=loaded.summary;
    colors=[.1 .5 .7;.15 .55 .4;.55 .3 .7;.85 .325 .1];
    styles={'-','--',':','-.'};
    labels={'Intact','Remove FB','Remove b','Block'};
    names={'result_3_prediction_validation','diagnostic_3_prediction_noise','diagnostic_4_prediction_specificity'};
    cfg.plot.fontSize=14; paths=cell(3,2);
    for number=1:3
        assert(~isfile(fullfile(cfg.plotsFigRoot,[names{number} '.fig'])) && ~isfile(fullfile(cfg.plotsPngRoot,[names{number} '.png'])), ...
            'Refuse to overwrite a prediction figure bundle.');
        f=figure('Visible','off','Color','w','Position',[30 30 1700 1000]);
        f.UserData=struct('task',cfg.task,'modelCheckpoint',cfg.checkpoint, ...
            'primaryNoise',.10,'independentN',10,'figureIndex',number, ...
            'sourceSummary','results/stage_3/current/prediction_validation/summary.mat');
        tiles=tiledlayout(f,2,3,'Padding','loose','TileSpacing','loose');
        if number==1
            headings={'A  Prep to early-movement activity','B  Prep to hand position at peak speed', ...
                'C  Prep to peak speed','D  Within-target hand position (supporting)', ...
                'E  Within-target peak speed (supporting)'};
            for metric=1:5
                ax=nexttile(tiles); values=reshape(s.metrics(:,2,:,metric),10,4);
                dots(ax,values,labels,colors,s.bootstrapIndices); title(ax,headings{metric},'FontWeight','normal');
                ylabel(ax,'Cross-validated R^2'); apply_plot_style(ax,cfg);
            end
            ax=nexttile(tiles); axis(ax,'off');
            text(ax,0,1,{'Primary noise s = 0.10; 30 trials / target', ...
                '10 frozen networks; 8 targets each','Points: networks; bars: median +/- bootstrap SE', ...
                'Primary: three-fold outer / nested three-fold ridge', ...
                'Neural PCs: separate epochs, >=75% variance', ...
                'Hand: fixed task plane, cross-validated OLS', ...
                'Supporting: fixed full-ensemble features + within-target LOO', ...
                'Feature learning follows manuscript full-ensemble scope', ...
                'Nine primary contrasts: exact sign-flip + one BH family', ...
                'Negative R^2 values are retained; no tuning'}, ...
                'Units','normalized','VerticalAlignment','top','FontSize',13,'Interpreter','none');
            title(tiles,'Stage 3 | Fixed-controller prediction validation | s = 0.10 primary','FontSize',19);
        elseif number==2
            headings={'A  Prep to early-movement activity','B  Prep to hand position','C  Prep to peak speed'};
            for metric=1:3
                ax=nexttile(tiles); hold(ax,'on');
                for policy=1:4
                    values=reshape(s.metrics(:,:,policy,metric),10,3); b=stage2_bootstrap(values,s.bootstrapIndices);
                    errorbar(ax,cfg.noiseLevels,b.median,b.se,[styles{policy} 'o'],'Color',colors(policy,:),'LineWidth',1.6, ...
                        'MarkerSize',6,'CapSize',9,'DisplayName',labels{policy});
                end
                xlim(ax,[.035 .215]); xticks(ax,cfg.noiseLevels); xticklabels(ax,{'0.05','0.10 primary','0.20'});
                xlabel(ax,'Noise state scale s'); ylabel(ax,'Cross-validated R^2'); yline(ax,0,':','HandleVisibility','off');
                title(ax,headings{metric},'FontWeight','normal'); apply_plot_style(ax,cfg);
                if metric==1, legend(ax,'Location','best','FontSize',11); end
            end
            for lesion=1:3
                ax=nexttile(tiles); values=reshape(s.matched(:,2,lesion,:),10,2);
                dots(ax,values,labels([1 lesion+1]),colors([1 lesion+1],:),s.bootstrapIndices);
                title(ax,sprintf('%c  Matched-PC: Intact vs %s','D'+lesion-1,labels{lesion+1}),'FontWeight','normal');
                ylabel(ax,'Prep to early-movement R^2'); apply_plot_style(ax,cfg);
            end
            title(tiles,'Stage 3 | Noise sensitivity (no level selected) and matched-PC control','FontSize',19);
        else
            ax=nexttile(tiles); dots(ax,reshape(s.chanceMedian(:,2,:),10,4),labels,colors,s.bootstrapIndices);
            title(ax,'A  Shuffled neural prediction','FontWeight','normal'); ylabel(ax,'Median shuffled R^2'); apply_plot_style(ax,cfg);
            for metric=6:7
                ax=nexttile(tiles); dots(ax,reshape(s.metrics(:,2,:,metric),10,4),labels,colors,s.bootstrapIndices);
                heading={'B  Pre-peak activity to hand position','C  Pre-peak activity to peak speed'};
                title(ax,heading{metric-5},'FontWeight','normal'); ylabel(ax,'Cross-validated R^2'); apply_plot_style(ax,cfg);
            end
            ax=nexttile(tiles); dots(ax,reshape(s.metrics(:,2,:,10),10,4),labels,colors,s.bootstrapIndices);
            title(ax,'D  Held-out prep variance on speed axis','FontWeight','normal'); ylabel(ax,'Fraction of population variance'); apply_plot_style(ax,cfg);
            for epoch=1:2
                ax=nexttile(tiles); values=100*reshape(s.orientationDeficit(:,2,:,epoch),10,3);
                dots(ax,values,labels(2:4),colors(2:4,:),s.bootstrapIndices);
                heading={'E  Prep speed-axis reorientation','F  Pre-peak speed-axis reorientation'};
                title(ax,heading{epoch},'FontWeight','normal'); ylabel(ax,'Expected - observed alignment (pp)'); apply_plot_style(ax,cfg);
            end
            title(tiles,'Stage 3 | Chance, temporal specificity and speed axes | s = 0.10 primary','FontSize',19);
        end
        [paths{number,1},paths{number,2}]=save_figure_bundle(f,names{number},cfg);
        reopened=openfig(paths{number,1},'invisible');
        assert(~isempty(findall(reopened,'Type','axes'))); close(reopened);
    end
    save(fullfile(cfg.predRoot,'figure_paths.mat'),'paths');
end

function dots(ax,values,labels,colors,indices)
    hold(ax,'on'); count=size(values,2); b=stage2_bootstrap(values,indices);
    jitter=linspace(-.12,.12,10).';
    for j=1:count
        plot(ax,j+jitter,values(:,j),'o','Color',colors(j,:),'MarkerFaceColor',.75+.25*colors(j,:), ...
            'MarkerSize',5,'LineWidth',.7,'HandleVisibility','off');
        errorbar(ax,j,b.median(j),b.se(j),'s','Color',colors(j,:),'MarkerFaceColor',colors(j,:), ...
            'MarkerSize',8,'LineWidth',2,'CapSize',12,'Tag',sprintf('summary_%d',j));
    end
    yline(ax,0,':','Color',[.5 .5 .5],'HandleVisibility','off');
    xlim(ax,[.55 count+.45]); xticks(ax,1:count); xticklabels(ax,labels);
    xtickangle(ax,15);
end
