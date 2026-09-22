function receipt = eta_figures(root)
    addpath(fullfile(root,'analysis','paper_ready','stabilization_eta')); cfg=eta_paths(root);
    a=jsondecode(fileread(fullfile(cfg.dest,'audit.json'))); assert(strcmp(a.status,'PASS'));
    s=load(fullfile(cfg.dest,'summary.mat'),'summary'); r=s.summary;
    colors=[86 180 233;213 94 0]/255; names={'Intact','Block'};
    figdir=fullfile(root,'plots','paper_ready','stabilization_eta','fig');
    pngdir=fullfile(root,'plots','paper_ready','stabilization_eta','png');
    if ~isfolder(figdir), mkdir(figdir); end
    if ~isfolder(pngdir), mkdir(pngdir); end
    f=newFigure([1950 1180]); positions=[.06 .59 .26 .29;.385 .59 .26 .29;.71 .59 .26 .29; ...
        .06 .13 .26 .29;.385 .32 .26 .10;.71 .13 .26 .29];
    fields={'spectral','bias','dispersion','convergence','pr','r2'};
    titles={'A  Local equilibrium stability','B  Mean GO equilibrium bias', ...
        'C  Within-target GO dispersion','D  Held-out cue-to-pre-go convergence', ...
        'E  Late-preparatory geometry','F  Prep-to-early-movement prediction'};
    labels={'Worst-target max Re eigenvalue (s^{-1})','GO / cue equilibrium distance', ...
        'RMS state distance (model units)','C = 1 - d_{pre-go} / d_{cue}', ...
        'Participation ratio','Pooled held-out R^2'};
    for j=1:6
        ax=axes(f,'Position',positions(j,:)); curves(ax,r.eta,r.(fields{j}),r.bootstrap.(fields{j}),colors,names,fields{j});
        title(ax,titles{j}); ylabel(ax,labels{j});
        if ismember(j,[1 4 6]), yline(ax,0,':','Color',[.35 .35 .35],'HandleVisibility','off'); end
        if j==1, legend(ax,'Location','southwest'); end
        if j==5, xlabel(ax,''); end
    end
    ax=axes(f,'Position',[.385 .13 .26 .10]); values=cat(3,100*r.observed,100*r.expected);
    curves(ax,r.eta,values,stage2_bootstrap(values,r.indices),[.2 .2 .2;.65 .65 .65], ...
        {'Observed: Intact onto Block','Covariance null'},'alignment'); ylabel(ax,'Alignment (%)');
    legend(ax,'Orientation','horizontal','Position',[.388 .247 .26 .03],'FontSize',10);
    sgtitle(f,{'Shared residual stabilization | frozen Intact versus full Block', ...
        '10 networks; median +/- fixed whole-network bootstrap SE; thin lines = networks'},'FontName','Arial','FontSize',20);
    annotation(f,'textbox',[.045 .015 .91 .055],'String',sprintf([ ...
        'Panel D: model-native analogue, reference-only PCA95; fixed 20/10 same-target folds. Panel F: PCA75 + nested ridge.\n', ...
        'No eta selected. %d / 100 network/eta/condition points exceed frozen preparation bounds; none excluded.'],sum(~r.prepAdmissible,'all')), ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',12);
    receipt=savePair(f,'stabilization_eta_six_panel',figdir,pngdir);

    f=newFigure([1800 1400]); tiledlayout(f,3,3,'TileSpacing','compact','Padding','compact');
    fields={'mo','peakTime','peakSpeed','endpoint','separation'};
    labels={'Movement onset (ms after GO)','Peak time (ms after GO)','Peak speed (m/s)', ...
        'Within-target endpoint RMS (mm)','Target separation / scatter'};
    for j=1:5
        ax=nexttile; curves(ax,r.eta,r.(fields{j}),r.bootstrap.(fields{j}),colors,names,fields{j}); ylabel(ax,labels{j});
        if j==1, legend(ax,'Location','best'); end
    end
    ax=nexttile; hold(ax,'on');
    for p=1:2
        for kind=1:2
            counts=zeros(10,5); fieldsQC={'boundaryPeak','multiPeak'}; styles={'-','--'};
            for n=1:10, for e=1:5, counts(n,e)=r.qc{n,e,p}.(fieldsQC{kind}); end, end
            y=sum(counts,1); plot(ax,r.eta,y,styles{kind},'Color',colors(p,:),'LineWidth',2, ...
                'DisplayName',[names{p} ' ' fieldsQC{kind}],'UserData',struct('source',y));
        end
    end
    xlabel(ax,'Residual stabilization eta'); ylabel(ax,'Flagged trials / 2400'); legend(ax,'Location','best','FontSize',10);
    set(ax,'XTick',[0 .25 .5 .75 1],'Box','off');
    % Pooled distributions are descriptive, not independent inferential samples.
    allMO=cell(5,2); allPeak=allMO; allSpeed=allMO;
    for e=1:5
        for p=1:2
            for n=1:10
                [~,move]=eta_load_case(cfg,n,e,p);
                allMO{e,p}=[allMO{e,p} move.moMs]; allPeak{e,p}=[allPeak{e,p} move.peakMs];
                allSpeed{e,p}=[allSpeed{e,p} move.peak];
            end
        end
    end
    distributions={allMO,allPeak,allSpeed}; titles={'MO trial distributions','Peak-time trial distributions','Peak-speed trial distributions'};
    for j=1:3
        ax=nexttile; hold(ax,'on'); data=distributions{j};
        for e=1:5
            for p=1:2
                x=r.eta(e)+(p-1.5)*.055; v=data{e,p}; q=prctile(v,[5 25 50 75 95]);
                plot(ax,[x x],q([1 5]),'-','Color',colors(p,:),'LineWidth',1,'UserData',struct('source',q([1 5])));
                plot(ax,[x x],q([2 4]),'-','Color',colors(p,:),'LineWidth',5,'UserData',struct('source',q([2 4])));
                plot(ax,x,q(3),'o','Color',colors(p,:),'MarkerFaceColor','w','MarkerSize',4,'UserData',struct('source',q(3)));
            end
        end
        title(ax,{titles{j},'5-95% whisker; 25-75% bar; median circle'}); ylabel(ax,labels{j});
        xlabel(ax,'Residual stabilization eta'); set(ax,'XTick',[0 .25 .5 .75 1],'Box','off'); xlim(ax,[-.09 1.09]);
    end
    sgtitle(f,{'Supporting movement QC | all trials retained','Top/middle: network median +/- bootstrap SE; bottom: pooled descriptive trial distributions'},'FontSize',18);
    receipt(2)=savePair(f,'stabilization_eta_movement_qc',figdir,pngdir);
    distributionPath=fullfile(cfg.dest,'movement_distributions.mat'); assert(~isfile(distributionPath));
    save(distributionPath,'allMO','allPeak','allSpeed');

    f=newFigure([2200 1400]); tiledlayout(f,4,5,'TileSpacing','compact','Padding','compact');
    targetColors=lines(8);
    for p=1:2
        for e=1:5
            [~,move]=eta_load_case(cfg,1,e,p);
            ax=nexttile((p-1)*10+e); hold(ax,'on'); set(ax,'Tag','KinHand');
            for q=1:8
                ids=(q-1)*30+(1:30); x=100*squeeze(move.hand(:,1,ids)); y=100*squeeze(move.hand(:,3,ids));
                plot(ax,x,y,'Color',.82+.18*targetColors(q,:),'LineWidth',.3,'HandleVisibility','off');
                plot(ax,mean(x,2),mean(y,2),'Color',targetColors(q,:),'LineWidth',1.6, ...
                    'DisplayName',sprintf('T%d',q),'UserData',struct('source',mean(y,2),'x',mean(x,2)));
            end
            axis(ax,'equal'); xlabel(ax,'Hand x (cm)'); ylabel(ax,'Hand y (cm)'); title(ax,sprintf('%s | eta %.2f',names{p},r.eta(e)));
            ax=nexttile((p-1)*10+5+e); hold(ax,'on'); set(ax,'Tag','KinSpeed');
            for q=1:8
                ids=(q-1)*30+(1:30); v=move.speed(:,ids); t=(0:size(v,1)-1).';
                plot(ax,t,v,'Color',.82+.18*targetColors(q,:),'LineWidth',.3,'HandleVisibility','off');
                plot(ax,t,mean(v,2),'Color',targetColors(q,:),'LineWidth',1.5, ...
                    'DisplayName',sprintf('T%d',q),'UserData',struct('source',mean(v,2),'x',t));
            end
            xlabel(ax,'Time after GO (ms)'); ylabel(ax,'Speed (m/s)');
            if p==1 && e==1, legend(ax,'Location','northeast','FontSize',8,'NumColumns',2); end
        end
    end
    handAxes=findall(f,'Type','axes','Tag','KinHand'); speedAxes=findall(f,'Type','axes','Tag','KinSpeed');
    xl=cell2mat(get(handAxes,'XLim')); yl=cell2mat(get(handAxes,'YLim')); speedLimits=cell2mat(get(speedAxes,'YLim'));
    set(handAxes,'XLim',[min(xl(:,1)) max(xl(:,2))],'YLim',[min(yl(:,1)) max(yl(:,2))]);
    set(speedAxes,'YLim',[0 max(speedLimits(:,2))]);
    sgtitle(f,{'Supporting kinematics | predeclared network 1, all eight targets and all trials', ...
        'Unsmoothed deterministic post-GO movement; thin traces = trials; thick traces = target means'},'FontSize',18);
    receipt(3)=savePair(f,'stabilization_eta_kinematics',figdir,pngdir);
    paper_json(fullfile(cfg.manifest,'FIGURES.json'),struct('status','PASS','figures',receipt));
end

function f=newFigure(sz)
    f=figure('Visible','off','Color','w','Position',[40 40 sz]);
    set(f,'DefaultAxesFontName','Arial','DefaultAxesFontSize',12,'DefaultAxesLineWidth',1.1,'DefaultLineLineWidth',1.5);
end

function curves(ax,x,v,b,colors,names,tag)
    hold(ax,'on'); mu=reshape(b.median,5,2); se=reshape(b.se,5,2);
    for p=1:2
        for n=1:10
            y=reshape(v(n,:,p),1,5);
            plot(ax,x,y,'-','Color',.68+.32*colors(p,:),'LineWidth',.6,'HandleVisibility','off', ...
                'UserData',struct('source',y));
        end
        errorbar(ax,x,mu(:,p),se(:,p),'-o','Color',colors(p,:),'MarkerFaceColor',colors(p,:), ...
            'LineWidth',2,'MarkerSize',5,'CapSize',7,'DisplayName',names{p}, ...
            'Tag',[tag num2str(p)],'UserData',struct('source',mu(:,p),'se',se(:,p),'x',x));
    end
    xlim(ax,[-.04 1.04]); set(ax,'XTick',[0 .25 .5 .75 1],'Box','off','TickDir','out'); xlabel(ax,'Residual stabilization eta');
end

function receipt=savePair(f,name,figdir,pngdir)
    figpath=fullfile(figdir,[name '.fig']); pngpath=fullfile(pngdir,[name '.png']);
    assert(~isfile(figpath) && ~isfile(pngpath)); savefig(f,figpath); exportgraphics(f,pngpath,'Resolution',160); close(f);
    f=openfig(figpath,'invisible'); hs=findall(f); checks=0;
    for j=1:numel(hs)
        if ~isprop(hs(j),'UserData'), continue; end
        u=hs(j).UserData; if ~isstruct(u) || ~isfield(u,'source'), continue; end
        assert(isequaln(hs(j).YData(:),u.source(:)));
        if isfield(u,'x'), assert(isequaln(hs(j).XData(:),u.x(:))); end
        if isfield(u,'se'), assert(isequaln(hs(j).YNegativeDelta(:),u.se(:)) && isequaln(hs(j).YPositiveDelta(:),u.se(:))); end
        checks=checks+1;
    end
    close(f); assert(checks>0); receipt=struct('name',name,'fig',figpath,'png',pngpath,'reopenedSourceChecks',checks);
end
