function receipt = pe_figures(root,mode)
    addpath(fullfile(root,'analysis','paper_ready','prediction')); cfg=pe_paths(root);
    colors=[86 180 233;0 158 115;204 121 167;213 94 0]/255;
    names={'Intact','Remove FB','Remove b','Block'};
    figdir=fullfile(root,'plots','paper_ready','prediction','fig'); pngdir=fullfile(root,'plots','paper_ready','prediction','png');
    if ~isfolder(figdir), mkdir(figdir); end
    if ~isfolder(pngdir), mkdir(pngdir); end
    if strcmp(mode,'primary')
        a=jsondecode(fileread(fullfile(cfg.dest,'primary_audit.json'))); assert(strcmp(a.status,'PASS'));
        s=load(fullfile(cfg.dest,'primary.mat'),'summary'); r=s.summary;
        f=newFigure([900 760]); ax=axes(f,'Position',[.12 .29 .83 .60]);
        paired(ax,r.r2,r.bootstrap,colors,names,'primary'); ylabel(ax,'Cross-validated R^2');
        yline(ax,0,':','Color',[.4 .4 .4],'HandleVisibility','off'); title(ax,'e  Prep-to-early-movement prediction');
        caption=sprintf(['Frozen paper geometry | 10 networks, 30 trials / target\n', ...
            'PCA >=75%%; nested 3-fold ridge; no post-GO noise\n', ...
            'Model Block change: %.2f +/- %.2f%% (paired median +/- bootstrap SE)\n', ...
            'Empirical reductions: 43.6%% (N), 29.6%% (T); descriptive context only\n', ...
            'Policy vs Intact BH q: %.5g, %.5g, %.5g'], ...
            r.relativeBootstrap.median,r.relativeBootstrap.se,r.q);
        annotation(f,'textbox',[.07 .025 .88 .20],'String',caption,'EdgeColor','none','FontSize',12,'HorizontalAlignment','center');
        receipt=savePair(f,'panel_e_pca_ridge',figdir,pngdir);
        f=newFigure([1550 1000]); tiledlayout(f,2,3,'TileSpacing','compact','Padding','compact');
        for j=1:3
            ax=nexttile; values=squeeze(r.matched(:,j,:)); b=stage2_bootstrap(values,r.indices);
            paired(ax,values,b,colors([1 j+1],:),names([1 j+1]),sprintf('matched%d',j));
            ylabel(ax,'Matched-PC R^2'); title(ax,sprintf('Intact versus %s',names{j+1})); yline(ax,0,':','HandleVisibility','off');
        end
        ax=nexttile; paired(ax,r.chanceMedian,r.chanceBootstrap,colors,names,'shuffle'); ylabel(ax,'Median shuffled R^2'); title(ax,'100 fixed global shuffles');
        for e=1:2
            ax=nexttile; values=squeeze(r.K(:,:,e)); paired(ax,values,stage2_bootstrap(values,r.indices),colors,names,sprintf('K%d',e));
            ylabel(ax,'PC count (>=75% variance)'); epochs={'Prep','Early movement'}; title(ax,epochs{e});
        end
        sgtitle(f,'Panel-e controls | matched PCs, fixed shuffle floor and retained dimensionality','FontSize',19);
        receipt(2)=savePair(f,'panel_e_controls',figdir,pngdir);
    elseif strcmp(mode,'rrr')
        a=jsondecode(fileread(fullfile(cfg.dest,'rrr_audit.json'))); assert(strcmp(a.status,'PASS'));
        s=load(fullfile(cfg.dest,'rrr.mat'),'summary'); r=s.summary;
        f=newFigure([1900 750]); tiledlayout(f,1,3,'TileSpacing','compact','Padding','compact');
        ax=nexttile; hold(ax,'on'); ranks=1:200;
        for p=1:4
            mu=squeeze(r.mean(1,p,:)).'; se=squeeze(r.se(1,p,:)).';
            patch(ax,[ranks fliplr(ranks)],[mu-se fliplr(mu+se)],colors(p,:),'FaceAlpha',.13,'EdgeColor','none','HandleVisibility','off', ...
                'Tag',sprintf('repeatSEband%d',p),'UserData',struct('source',[mu-se fliplr(mu+se)]));
            plot(ax,ranks,mu,'Color',colors(p,:),'LineWidth',1.8,'DisplayName',names{p},'Tag',sprintf('curve%d',p),'UserData',struct('source',mu));
            [pk,k]=max(mu); plot(ax,k,pk,'o','Color',colors(p,:),'MarkerFaceColor',colors(p,:),'HandleVisibility','off', ...
                'Tag',sprintf('peakMarker%d',p),'UserData',struct('source',pk,'x',k));
            plot(ax,r.rank(1,p),r.threshold(1,p),'s','Color',colors(p,:),'MarkerFaceColor','w','HandleVisibility','off', ...
                'Tag',sprintf('rankMarker%d',p),'UserData',struct('source',r.threshold(1,p),'x',r.rank(1,p)));
            line(ax,[1 200],repmat(r.threshold(1,p),1,2),'Color',colors(p,:),'LineStyle',':','HandleVisibility','off');
            line(ax,repmat(r.rank(1,p),1,2),[min(mu-se) r.threshold(1,p)],'Color',colors(p,:),'LineStyle','--','HandleVisibility','off');
        end
        set(ax,'XScale','log','XTick',[1 2 5 10 20 50 100 200]); xlim(ax,[1 200]); xlabel(ax,'RRR rank (log scale)'); ylabel(ax,'Cross-validated R^2');
        title(ax,{'a  Predeclared network 1','Bands: SE across 10 fold repeats'}); legend(ax,'Location','southeast');
        ax=nexttile; paired(ax,r.rank,r.rankBootstrap,colors,names,'rrrRank'); ylabel(ax,'Predictive dimensionality');
        title(ax,{'b  One-SE predictive rank',sprintf('BH q: %.4g, %.4g, %.4g',r.q(1,:))});
        ax=nexttile; paired(ax,r.peak,r.peakBootstrap,colors,names,'rrrPeak');
        hold(ax,'on');
        for p=1:4
            plot(ax,p+.16+zeros(10,1),r.shuffleMedian(:,p),'v','Color',colors(p,:),'MarkerSize',4,'LineStyle','none','HandleVisibility','off', ...
                'Tag',sprintf('shuffleNetworks%d',p),'UserData',struct('source',r.shuffleMedian(:,p)));
        end
        errorbar(ax,(1:4)+.16,r.shuffleBootstrap.median,r.shuffleBootstrap.se,'kv','LineStyle','none','LineWidth',1.3, ...
            'Tag','shufflePeakSE','UserData',struct('source',r.shuffleBootstrap.median,'se',r.shuffleBootstrap.se));
        yline(ax,0,':','HandleVisibility','off'); ylabel(ax,'Peak cross-validated R^2');
        title(ax,{'c  Peak R^2 and shuffled floor (triangles)',sprintf('BH q: %.4g, %.4g, %.4g',r.q(2,:))});
        sgtitle(f,{'Full-space ridge-RRR | 200 neurons, no preceding PCA','10 networks; medians +/- whole-network bootstrap SE; no balancing resampling'},'FontSize',18);
        receipt=savePair(f,'extended_data_rrr',figdir,pngdir);
    else
        error('Unknown figure mode');
    end
    paper_json(fullfile(cfg.manifest,['FIGURES_' mode '.json']),struct('status','PASS','figures',receipt));
end

function f=newFigure(sz)
    f=figure('Visible','off','Color','w','Position',[40 40 sz]);
    set(f,'DefaultAxesFontName','Arial','DefaultAxesFontSize',12,'DefaultAxesLineWidth',1.1,'DefaultLineLineWidth',1.5);
end

function paired(ax,values,b,colors,names,tag)
    hold(ax,'on'); count=size(values,2);
    for n=1:10, plot(ax,1:count,values(n,:),'-','Color',[.78 .78 .78],'LineWidth',.6,'HandleVisibility','off'); end
    for p=1:count
        plot(ax,p+zeros(10,1),values(:,p),'o','Color',colors(p,:),'MarkerFaceColor',colors(p,:),'MarkerSize',5, ...
            'LineStyle','none','Tag',sprintf('%s_values%d',tag,p),'UserData',struct('source',values(:,p)));
    end
    errorbar(ax,1:count,b.median,b.se,'ks','MarkerFaceColor','w','MarkerSize',8,'LineStyle','none','LineWidth',1.8,'CapSize',12, ...
        'Tag',[tag '_SE'],'UserData',struct('source',b.median,'se',b.se));
    xlim(ax,[.6 count+.4]); set(ax,'XTick',1:count,'XTickLabel',names,'Box','off','TickDir','out');
end

function receipt=savePair(f,name,figdir,pngdir)
    figpath=fullfile(figdir,[name '.fig']); pngpath=fullfile(pngdir,[name '.png']);
    assert(~isfile(figpath) && ~isfile(pngpath),'Refuse to overwrite figure evidence.');
    savefig(f,figpath); exportgraphics(f,pngpath,'Resolution',160); close(f);
    f=openfig(figpath,'invisible'); hs=findall(f); checks=0;
    for j=1:numel(hs)
        if ~isprop(hs(j),'UserData'), continue; end
        u=hs(j).UserData;
        if ~isstruct(u) || ~isfield(u,'source'), continue; end
        assert(isequal(hs(j).YData(:),u.source(:)));
        if isfield(u,'x'), assert(isequal(hs(j).XData(:),u.x(:))); end
        if isfield(u,'se'), assert(isequal(hs(j).YNegativeDelta(:),u.se(:)) && isequal(hs(j).YPositiveDelta(:),u.se(:))); end
        checks=checks+1;
    end
    close(f); assert(checks>0); receipt=struct('name',name,'fig',figpath,'png',pngpath,'reopenedSourceChecks',checks);
end
