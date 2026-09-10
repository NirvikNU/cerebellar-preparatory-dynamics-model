function paths = stage3_bio_figures(figureIndices)
    % Current biological-controller figures from audited saved outputs only.
    cfg=stage3_bio_paths;
    if nargin<1, figureIndices=1:4; end
    assert(all(ismember(figureIndices,1:4)));
    audit=jsondecode(fileread(fullfile(cfg.bioRoot,'independent_audit.json'))); assert(strcmp(audit.status,'PASS'));
    s=load(fullfile(cfg.bioRoot,'population.mat'),'result'); pop=s.result;
    s=load(fullfile(cfg.bioRoot,'movement.mat'),'result'); move=s.result;
    map=stage3_logical_flags(readtable(fullfile(cfg.bioRoot,'feasibility_map.csv')));
    names={'result_1_preparation_and_movement','result_2_preparatory_geometry', ...
        'diagnostic_1_feasible_solution_map','diagnostic_2_component_removal'};
    colors=[.1 .5 .7;.15 .55 .4;.55 .3 .7;.85 .325 .1];
    styles={'-','--',':','-.'}; indices=pop.bootstrapIndices; paths=cell(4,2);
    cfg.plot.fontSize=15;
    for j=1:4
        paths(j,:)={fullfile(cfg.plotsFigRoot,[names{j} '.fig']),fullfile(cfg.plotsPngRoot,[names{j} '.png'])};
    end
    for figureIndex=figureIndices
        f=figure('Visible','off','Color','w','Position',[30 30 1700 720]);
        if figureIndex<=2
            tiledlayout(f,1,3,'Padding','loose','TileSpacing','loose');
            if figureIndex==1
                ax=nexttile; hold(ax,'on');
                for policy=[1 4]
                    v=squeeze(pop.fullDistanceStar(:,policy,101:end));
                    plot(ax,-500:0,v.','Color',.7+.3*colors(policy,:),'LineWidth',.7,'HandleVisibility','off');
                    ribbon(ax,-500:0,v,colors(policy,:),styles{policy},cfg.policyNames{policy});
                end
                title(ax,'A  Finite-time preparation','FontWeight','normal');
                xlabel(ax,'Time from GO (ms)'); ylabel(ax,'Distance to x^* (state units)');
                legend(ax,'Location','northeast'); apply_plot_style(ax,cfg);
                ax=nexttile; hold(ax,'on'); style=stage_1_gate1_config(cfg.projectRoot);
                p=move.primary{1};
                for q=1:8
                    for condition=1:2
                        lineStyle='-'; if condition==2, lineStyle='--'; end
                        h=p.hand{condition};
                        plot(ax,1000*h(:,1,q),1000*h(:,3,q),lineStyle,'Color',style.plot.colors(q,:), ...
                            'LineWidth',1.8,'HandleVisibility','off');
                    end
                    target=squeeze(p.targetHand(end,[1 3],q));
                    plot(ax,1000*target(1),1000*target(2),'o','Color',style.plot.colors(q,:), ...
                        'MarkerSize',8,'LineWidth',1.5,'HandleVisibility','off');
                end
                plot(ax,NaN,NaN,'k-','LineWidth',1.8,'DisplayName','Intact');
                plot(ax,NaN,NaN,'k--','LineWidth',1.8,'DisplayName','Block');
                axis(ax,'equal'); xlabel(ax,'Hand x (mm)'); ylabel(ax,'Hand y (mm)');
                xlim(ax,xlim(ax)+[-8 8]); ylim(ax,ylim(ax)+[-8 8]);
                title(ax,'B  Network 1: eight targets','FontWeight','normal'); legend(ax,'Location','southoutside');
                apply_plot_style(ax,cfg);
                ax=nexttile; paired(ax,move.earlyErrorMM,{'Intact','Block'},colors([1 4],:));
                ylabel(ax,'Early trajectory RMS error (mm)'); title(ax,'C  Movement consequence','FontWeight','normal');
                sgtitle(f,'Fixed biological-controller candidate | actual GO states released unchanged','FontSize',18);
            else
                ax=nexttile; hold(ax,'on');
                for policy=[1 4]
                    v=zeros(10,15);
                    for n=1:10, g=pop.late{n}{policy}; v(n,:)=g.eigenvalues(1:15)/sum(g.eigenvalues); end
                    ribbon(ax,1:15,v,colors(policy,:),styles{policy},cfg.policyNames{policy});
                end
                xlabel(ax,'Principal component'); ylabel(ax,'Fraction of prep variance'); xlim(ax,[1 15]);
                title(ax,'A  Actual finite-window spectra','FontWeight','normal'); legend(ax,'Location','northeast'); apply_plot_style(ax,cfg);
                ax=nexttile; paired(ax,pop.primaryTable{:,{'prIntact','prBlock'}},{'Intact','Block'},colors([1 4],:));
                ylabel(ax,'Participation ratio'); title(ax,'B  Preparatory dimensionality','FontWeight','normal');
                ax=nexttile; paired(ax,100*pop.primaryTable{:,{'observed','expected'}},{'Observed','Expected'},[.2 .2 .2;.6 .6 .6]);
                ylabel(ax,'Intact projected onto Block (%)'); ylim(ax,[0 100]);
                title(ax,'C  Directed alignment','FontWeight','normal');
                sgtitle(f,'GO -100:10:0 ms | frozen normalization | common >95%-variance PC rule','FontSize',18);
            end
        elseif figureIndex==3
            f.Position=[30 30 1700 900]; tiledlayout(f,1,2,'Padding','loose','TileSpacing','loose');
            ax=nexttile; hold(ax,'on'); a=map(map.network==1 & map.direction==1,:);
            [xx,yy]=meshgrid(linspace(.06,1.04,140),linspace(0,1.32,140));
            [cs,ch]=contour(ax,xx,yy,xx.^2+yy.^2,[.25 .5 1 2],'Color',[.7 .7 .7],'ShowText','on');
            clabel(cs,ch,'FontSize',10); ch.HandleVisibility='off';
            [~,ch]=contour(ax,xx,yy,xx.^2+yy.^2,[1 1],'k-','LineWidth',1.2); ch.HandleVisibility='off';
            scatter(ax,a.alpha(~a.rateRealizable),a.betaNormalized(~a.rateRealizable),70,[.75 .2 .2],'x', ...
                'LineWidth',1.4,'DisplayName','Negative rate: untested');
            scatter(ax,a.alpha(~a.modulationOK),a.betaNormalized(~a.modulationOK),90,[.5 .5 .5],'+', ...
                'LineWidth',1.4,'DisplayName','Modulation bound: untested');
            scatter(ax,a.alpha(~a.endpointBoundsOK),a.betaNormalized(~a.endpointBoundsOK),95,'k','d', ...
                'LineWidth',1.3,'DisplayName','Endpoint bound: untested');
            scatter(ax,a.alpha(a.analytical),a.betaNormalized(a.analytical),140,colors(3,:),'^', ...
                'LineWidth',1.4,'DisplayName','Analytically sufficient');
            scatter(ax,a.alpha(a.physical),a.betaNormalized(a.physical),90,colors(1,:),'s', ...
                'LineWidth',1.7,'DisplayName','Retained dynamic bounds pass');
            outside=a.physical & a.finitePhenotype & ~a.analytical;
            scatter(ax,a.alpha(outside),a.betaNormalized(outside),55,colors(4,:),'filled','DisplayName','Empirical success outside bound');
            scatter(ax,a.alpha(a.feasible),a.betaNormalized(a.feasible),45,[.1 .6 .3],'filled','DisplayName','All criteria feasible');
            failed=a.tested & ~a.physical;
            scatter(ax,a.alpha(failed),a.betaNormalized(failed),110,[.75 .1 .1],'x','DisplayName','Retained dynamic-bound failure');
            s=load(fullfile(cfg.cacheRoot,'reference_01.mat'),'ref'); ref=s.ref;
            plot(ax,cfg.alpha,cfg.alpha*sqrt(ref.rhoBound*ref.d/ref.T),'--','Color',colors(3,:), ...
                'LineWidth',1.6,'DisplayName','Conservative sufficient boundary');
            scatter(ax,.1,1,250,'k','p','LineWidth',1.7,'DisplayName','Unchanged primary setting');
            xlabel(ax,'\alpha'); ylabel(ax,'\beta / \surd(T/d)'); xlim(ax,[.05 1.05]); ylim(ax,[0 1.35]);
            title(ax,{'A  Revised finite-time feasible map','Network 1, direction 1'},'FontWeight','normal');
            legend(ax,'Location','southoutside','FontSize',10,'NumColumns',2); apply_plot_style(ax,cfg);
            ax=nexttile; hold(ax,'on'); frequency=zeros(36,1);
            for j=1:36, frequency(j)=sum(map.feasible & map.gridIndex==j)/30; end
            scatter(ax,a.alpha,a.betaNormalized,270,frequency,'s','filled','MarkerEdgeColor',[.3 .3 .3]);
            scatter(ax,.1,1,270,'k','p','LineWidth',1.8);
            colormap(ax,parula(256)); clim(ax,[0 1]); cb=colorbar(ax); cb.Label.String='Fraction feasible (30 network/direction sets)';
            xlabel(ax,'\alpha'); ylabel(ax,'\beta / \surd(T/d)'); xlim(ax,[.05 1.05]); ylim(ax,[0 1.35]);
            title(ax,{'B  Generality across the unchanged grid','10 networks \times 3 directions'},'FontWeight','normal'); apply_plot_style(ax,cfg);
            sgtitle(f,sprintf('%d / 1080 points meet all criteria | incomplete 500-ms settling is an outcome, not a failure',sum(map.feasible)),'FontSize',17);
        else
            f.Position=[30 30 1700 1050]; tiledlayout(f,3,2,'Padding','loose','TileSpacing','loose');
            data={pop.fullDistanceStar,pop.fullDistanceBlock,pop.fullNormalizedEQ,pop.pr,100*pop.deficit};
            titles={'A  Distance to movement-valid state','B  Distance to alternative block state', ...
                'C  Prospective motor error','D  Trailing-100-ms PR','E  Trailing-100-ms alignment deficit'};
            labels={'Distance to x^* (state units)','Distance to x^B (state units)', ...
                'E_Q / E_Q at cue','Participation ratio','Expected - observed (pp)'};
            for panel=1:5
                ax=nexttile; hold(ax,'on'); time=pop.fullTimeGO;
                if panel>=4, time=pop.endpointGO; end
                for policy=1:4
                    ribbon(ax,time,squeeze(data{panel}(:,policy,:)),colors(policy,:),styles{policy},cfg.policyNames{policy});
                end
                xline(ax,-500,'k:','Cue','HandleVisibility','off','LabelOrientation','horizontal');
                xline(ax,0,'k:','HandleVisibility','off');
                text(ax,.985,.94,'GO','Units','normalized','HorizontalAlignment','right', ...
                    'VerticalAlignment','top','FontSize',10);
                xlim(ax,[-600 0]); xticks(ax,-600:100:0); xlabel(ax,'Time from GO (ms)'); ylabel(ax,labels{panel});
                title(ax,titles{panel},'FontWeight','normal'); apply_plot_style(ax,cfg);
                if panel>=4
                    limits=ylim(ax);
                    patch(ax,[-600 -500 -500 -600],[limits(1) limits(1) limits(2) limits(2)], ...
                        [.85 .85 .85],'FaceAlpha',.3,'EdgeColor','none','HandleVisibility','off');
                    ylim(ax,limits);
                end
            end
            ax=nexttile; axis(ax,'off'); hold(ax,'on'); handles=gobjects(4,1);
            for policy=1:4
                handles(policy)=plot(ax,NaN,NaN,styles{policy},'Color',colors(policy,:),'LineWidth',2.3);
            end
            legend(ax,handles,cfg.policyNames,'Location','north','FontSize',15,'Box','off');
            text(ax,.02,.45,{'Network median ± bootstrap SE (n = 10)', ...
                'Same residual cortical controller in every policy', ...
                'Full block removes b and prospective feedback', ...
                'Gray: target covariance is zero; PR/alignment undefined', ...
                'Incomplete convergence at GO is allowed'}, ...
                'Units','normalized','FontSize',13,'VerticalAlignment','top','Interpreter','none');
            sgtitle(f,'Fixed prospective feedback and state setting | no gain or timing fit','FontSize',19);
        end
        f.UserData=struct('task','STAGE3-BIOLOGICAL-CONTROLLER-RESUME-02','source','biological_revision/resume_02','figureIndex',figureIndex);
        [paths{figureIndex,1},paths{figureIndex,2}]=save_figure_bundle(f,names{figureIndex},cfg);
        reopened=openfig(paths{figureIndex,1},'invisible');
        assert(strcmp(reopened.UserData.task,'STAGE3-BIOLOGICAL-CONTROLLER-RESUME-02')); close(reopened);
        info=imfinfo(paths{figureIndex,2}); assert(info.Width>1000 && info.Height>400);
    end
    stage3_write_json(fullfile(cfg.bioRoot,'figure_paths.json'),paths);

    function ribbon(ax,x,values,color,lineStyle,label)
        s=stage2_bootstrap(values,indices); x=x(:).'; y=s.median; e=s.se;
        valid=isfinite(y) & isfinite(e);
        fill(ax,[x(valid) fliplr(x(valid))],[y(valid)-e(valid) fliplr(y(valid)+e(valid))], ...
            color,'FaceAlpha',.14,'EdgeColor','none','HandleVisibility','off');
        plot(ax,x,y,lineStyle,'Color',color,'LineWidth',2.2,'DisplayName',label);
    end

    function paired(ax,values,labels,c)
        hold(ax,'on'); plot(ax,1:2,values.','-','Color',[.8 .8 .8],'LineWidth',.8,'HandleVisibility','off');
        s=stage2_bootstrap(values,indices);
        for k=1:2
            scatter(ax,k*ones(10,1),values(:,k),24,c(k,:),'filled','HandleVisibility','off');
            errorbar(ax,k,s.median(k),s.se(k),'o','Color',c(k,:),'MarkerFaceColor','w', ...
                'MarkerSize',9,'LineWidth',2,'CapSize',12,'HandleVisibility','off');
        end
        xlim(ax,[.6 2.4]); xticks(ax,1:2); xticklabels(ax,labels); apply_plot_style(ax,cfg);
    end
end
