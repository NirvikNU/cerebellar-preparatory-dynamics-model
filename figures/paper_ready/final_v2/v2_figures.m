function receipt=v2_figures(root)
    addpath(fullfile(root,'analysis','paper_ready','final_v2')); cfg=v2_paths(root);
    s=load(fullfile(cfg.dest,'figure_sources.mat'),'data'); d=s.data; r=d.summary; colors=d.colors;
    receipt=struct('status','PENDING_VISUAL_REVIEW','pairs',{{}},'objectChecks',0);
    f=newFigure([2200 2700],r.indices); f.UserData.legacyIndices=d.stage2.bootstrapIndices;
    tiledlayout(f,5,4,'TileSpacing','compact','Padding','compact');
    ax=nexttile([1 2]); curve(ax,d.stage2.cfg.lambda,d.stage2.deltaPR,d.stage2.bootstrapIndices,colors(1,:),'-','Feedback restriction',false,'legacy');
    yline(ax,d.selection.targets(1),'k:','Empirical calibration effect','LabelHorizontalAlignment','left');
    set(ax,'XScale','log'); xlabel(ax,'Feedback effort penalty \lambda'); ylabel(ax,'PR change from \lambda=0.1'); title(ax,'A  Prospective feedback alone: PR');
    ax=nexttile([1 2]); curve(ax,d.stage2.cfg.lambda,d.stage2.deficitPP,d.stage2.bootstrapIndices,[.2 .2 .2],'-','Alignment deficit',false,'legacy');
    yline(ax,d.selection.targets(2),'k:','Empirical calibration effect','LabelHorizontalAlignment','left'); yline(ax,0,':');
    set(ax,'XScale','log'); xlabel(ax,'Feedback effort penalty \lambda'); ylabel(ax,'Expected - observed alignment (pp)'); title(ax,'B  Prospective feedback alone: alignment');
    ax=nexttile([1 2]); schematic(ax);
    axesD=gobjects(1,2); limits=[Inf -Inf Inf -Inf]; home=d.representative{1}.hand(1,[1 3],1);
    for p=1:2
        axesD(p)=nexttile; lim=trajectories(axesD(p),d.representative{p}.hand,home,d.targetXY,d.targetColors,p);
        limits=[min(limits(1),lim(1)) max(limits(2),lim(2)) min(limits(3),lim(3)) max(limits(4),lim(4))];
    end
    for ax=axesD, xlim(ax,limits(1:2)); ylim(ax,limits(3:4)); end
    ax=nexttile([1 2]); paired(ax,100*r.dispersion,r.indices,colors([1 4],:),{'Intact','Block'});
    ylabel(ax,'Peak-speed position dispersion (cm)'); title(ax,{'E  Speed-matched dispersion',testLabel(d.tests.dispersion)});
    ax=nexttile; hold(ax,'on');
    for p=1:2
        v=d.representative{p}.speed(:,31:60); color=colors(1+3*(p-1),:); t=(0:size(v,1)-1).';
        plot(ax,t,v,'Color',.8+.2*color,'LineWidth',.4,'HandleVisibility','off');
        med=smoothdata(median(v,2),'gaussian',50); h=plot(ax,t,med,'Color',color,'LineWidth',2.5,'DisplayName',r.names{1+3*(p-1)});
        h.UserData=struct('x',t,'y',med,'kind','display50ms');
    end
    xlim(ax,[0 600]); xlabel(ax,'Time from GO (ms)'); ylabel(ax,'Speed (m/s)'); title(ax,{'F  Speed profiles','Network 1, target 2'}); legend(ax,'Location','best');
    ax=nexttile; paired(ax,squeeze(r.peakSpeed(:,2,[1 4])),r.indices,colors([1 4],:),{'Intact','Block'});
    ylabel(ax,'Target-averaged peak speed (m/s)'); title(ax,{'F  Peak speed',testLabel(d.tests.peakSpeed)});
    ax=nexttile([1 2]); empiricalModel(ax,d.empirical.prep(1:2),d.empirical.error(1:2),squeeze(r.pr(:,2,[1 4])),r.indices,colors([1 4],:),{'Control / Intact','Block'});
    ylabel(ax,'Late-preparation PR'); title(ax,{'G  Experiment versus model','Geometry calibration target'});
    ax=nexttile([1 2]); empiricalModel(ax,d.empirical.prep(3:4),d.empirical.error(3:4),[r.observed(:,2,4) r.expected(:,2,4)],r.indices,[.25 .25 .25;.7 .7 .7],{'Observed','Expected'});
    ylabel(ax,'Alignment (%)'); title(ax,{'H  Experiment versus model','Geometry calibration target'});
    ax=nexttile([1 2]); noiseCurves(ax,r.lossPct,r.indices,[0 0 0],false); yline(ax,0,':');
    ylabel(ax,{'Relative Block prep-to-move R^2 loss','(% within network)'}); title(ax,'I  Prediction vulnerability');
    ax=nexttile([1 2]); noiseCurves(ax,r.deltaC,r.indices,[0 0 0],false); yline(ax,0,':');
    ylabel(ax,'Block - Intact convergence score (\DeltaC)'); title(ax,'J  Corrected pre-cue convergence');
    sgtitle(f,sprintf('Parsimonious \\eta=0 model | shared \\alpha=%g, \\beta_{norm}=%g | primary noise 0.10 / 0.10',d.selection.alpha,d.selection.betaNormalized),'FontSize',22);
    receipt=savePair(f,root,'main','MainFig_Modelling_v2',receipt);

    f=newFigure([1500 650],r.indices); tiledlayout(f,1,2,'TileSpacing','compact','Padding','compact');
    ax=nexttile; noiseCurves(ax,r.r2(:,:,1),r.indices,colors(1,:),true); yline(ax,0,':'); ylabel(ax,'Intact prep-to-move R^2'); title(ax,'A  Intact prediction');
    ax=nexttile; noiseCurves(ax,r.convergence(:,:,1),r.indices,colors(1,:),true); yline(ax,0,':'); ylabel(ax,'Intact convergence C'); title(ax,'B  Intact single-pre-cue convergence');
    sgtitle(f,'Extended Data 1 | Noise sensitivity in the intact model | network n=10; median +/- bootstrap SE');
    receipt=savePair(f,root,'ED1_noise_intact','ED1_Noise_Intact_v2',receipt);

    f=newFigure([2100 650],r.indices); tiledlayout(f,1,4,'TileSpacing','compact','Padding','compact');
    fields={'pr','deficit','convergence','r2'}; labels={'Preparatory PR','Expected - observed (pp)','Convergence C','Prep-to-move R^2'};
    names={'Intact','b only','L only','Block'};
    for j=1:4
        ax=nexttile; paired(ax,squeeze(r.(fields{j})(:,2,:)),r.indices,colors,names); ylabel(ax,labels{j});
        title(ax,sprintf('%c  Component removal','A'+j-1)); if j>1, yline(ax,0,':'); end
    end
    sgtitle(f,'Extended Data 2 | State setting + prospective feedback | primary noise; descriptive paired network effects');
    receipt=savePair(f,root,'ED2_components','ED2_Components_v2',receipt);

    f=newFigure([2000 650],r.indices); tiledlayout(f,1,3,'TileSpacing','compact','Padding','compact');
    ax=nexttile; curve(ax,d.readiness.lambda,d.readiness.networkMedian,r.indices,colors(1,:),'-','Final \eta=0',true);
    curve(ax,d.historicalTiming.lambda,d.historicalTiming.networkMedian,r.indices,[.6 .6 .6],'--','Historical \eta=1',false);
    set(ax,'XScale','log'); xline(ax,10,':','Frozen \lambda=10'); yline(ax,75,':','Original timing target');
    xlabel(ax,'Effort penalty \lambda'); ylabel(ax,'Sustained Q-error readiness (ms)'); title(ax,'A  Timing provenance, no reselection'); legend(ax,'Location','best');
    ax=nexttile; values=squeeze(median(d.readinessCurves(1:5:end,:,d.readiness.lambda==10,:),2)).';
    curve(ax,0:500,values,r.indices,colors(1,:),'-','Q error / cue',false); yline(ax,.1,':','10% criterion');
    set(ax,'YScale','log'); xlabel(ax,'Time after cue (ms)'); ylabel(ax,'Target-median Q error / cue'); title(ax,'B  Frozen \lambda=10, \eta=0');
    ax=nexttile; curve(ax,d.readiness.lambda,d.readiness.gain,r.indices,[.2 .2 .2],'-','||L||_F',true);
    set(ax,'XScale','log','YScale','log'); xline(ax,10,':','Frozen'); xlabel(ax,'Effort penalty \lambda'); ylabel(ax,'Prospective feedback gain ||L||_F'); title(ax,'C  Effort / gain relation');
    sgtitle(f,'Extended Data 3 | Noiseless prospective-readiness provenance; unchanged lambda choice');
    receipt=savePair(f,root,'ED3_readiness','ED3_Readiness_v2',receipt);

    f=newFigure([1900 1200],r.indices); tiledlayout(f,2,3,'TileSpacing','compact','Padding','compact');
    values=cell(1,6); values{1}=100*r.endpoint(:,:,[1 4]); values{2}=r.separation(:,:,[1 4]);
    fields={'nearZero','missingWindow','boundaryPeak','multiPeak'};
    for j=1:4
        x=zeros(10,5,2); for n=1:10, for v=1:5, for p=1:2, x(n,v,p)=r.qc{n,v,1+3*(p-1)}.(fields{j}); end, end, end
        values{j+2}=x;
    end
    labels={'Endpoint RMS (cm)','Target separation / scatter','Near-zero trials / 240','Missing-window trials / 240','Boundary-peak trials / 240','Multiple-large-peak trials / 240'};
    for j=1:6
        ax=nexttile;
        for p=1:2, curve(ax,1:5,values{j}(:,:,p),r.indices,colors(1+3*(p-1),:),'-',r.names{1+3*(p-1)},true); end
        xticks(ax,1:5); xticklabels(ax,{'I .05','Primary','I .20','T .05','T .20'}); ylabel(ax,labels{j}); title(ax,sprintf('%c  Supporting QC','A'+j-1));
        if j==1, legend(ax,'Location','best'); end
    end
    sgtitle(f,'Extended Data 4 | All prespecified noise pairs; all trials retained | I=initial, T=temporal; other source .10');
    receipt=savePair(f,root,'ED4_movement_qc','ED4_Movement_QC_v2',receipt);

    f=newFigure([1900 1200],r.indices); tiledlayout(f,2,3,'TileSpacing','compact','Padding','compact');
    for j=1:3
        ax=nexttile; fields={'loss','deltaPR','deficitPP'}; labels={'Relative squared loss','Block - Intact PR','Expected - observed (pp)'};
        lossMap(ax,d.geometry.ensemble.(fields{j}),d.selection.gridIndex,labels{j}); title(ax,sprintf('%c  Full fixed 6 x 6 grid','A'+j-1));
    end
    ax=nexttile; vals=d.geometry.map(d.geometry.map.gridIndex==d.selection.gridIndex,:);
    h=plot(ax,1:10,vals.kControl,'ko','MarkerFaceColor','k'); h.UserData=struct('x',1:10,'y',vals.kControl,'kind','source');
    xlabel(ax,'Network'); ylabel(ax,'Intact-derived K (>=95%)'); title(ax,'D  Same K in Block basis and null');
    ax=nexttile; values=[r.r2(:,2,1) r.r2(:,2,4) r.matched(:,2,1) r.matched(:,2,4) r.shuffle(:,2,1) r.shuffle(:,2,4)];
    paired(ax,values,r.indices,repmat(colors([1 4],:),3,1),{'I','B','I match','B match','I shuffle','B shuffle'});
    ylabel(ax,'Held-out prep-to-move R^2'); yline(ax,0,':'); title(ax,'E  Primary matched-PC / shuffle controls');
    ax=nexttile; axis(ax,'off'); text(ax,0,1,{'FIT: one shared alpha / beta pair','36 candidates; ten networks each','Only paired DeltaPR + alignment deficit','Control-only >=95% K','', ...
        'NOT FIT: movement, convergence, R^2','Noise levels fixed; no QC selection','No network-specific geometry fitting','PCA75 features: full balanced ensemble','Nested ridge: fixed folds / penalties'}, ...
        'VerticalAlignment','top','FontSize',16,'Interpreter','none');
    sgtitle(f,'Extended Data 5 | Geometry calibration disclosed separately from predicted outcomes');
    receipt=savePair(f,root,'ED5_calibration_controls','ED5_Calibration_Controls_v2',receipt);
    paper_json(fullfile(cfg.manifest,'figures.json'),receipt);
end

function f=newFigure(dimensions,indices)
    f=figure('Visible','off','Color','w','Position',[20 20 dimensions]);
    set(f,'DefaultAxesFontSize',16,'DefaultAxesFontName','Arial','DefaultAxesTickDir','out','DefaultAxesBox','off','DefaultLineLineWidth',1.5);
    f.UserData=struct('indices',indices);
end

function curve(ax,x,values,indices,color,style,name,individual,indexKind)
    if nargin<9, indexKind='current'; end
    hold(ax,'on'); ss=stage2_bootstrap(values,indices);
    if individual, plot(ax,x,values.','Color',.8+.2*color,'LineWidth',.4,'HandleVisibility','off'); end
    h=errorbar(ax,x,ss.median,ss.se,[style 'o'],'Color',color,'MarkerFaceColor',color,'MarkerSize',5,'CapSize',5,'DisplayName',name);
    h.UserData=struct('x',x,'y',ss.median,'err',ss.se,'raw',values,'indexKind',indexKind,'kind','networkBootstrap');
end

function noiseCurves(ax,values,indices,color,individual)
    curve(ax,[.05 .1 .2],values(:,[1 2 3]),indices,color,'--','Initial noise; temporal=.10',individual);
    curve(ax,[.05 .1 .2],values(:,[4 2 5]),indices,color,'-','Temporal noise; initial=.10',individual);
    xline(ax,.1,':','Primary','LabelVerticalAlignment','bottom'); xticks(ax,[.05 .1 .2]); xlim(ax,[.04 .21]);
    xlabel(ax,'Preparation noise amplitude (state units)'); legend(ax,'Location','best','FontSize',12);
end

function paired(ax,values,indices,colors,names)
    hold(ax,'on'); ss=stage2_bootstrap(values,indices); count=size(values,2);
    plot(ax,1:count,values.','Color',[.84 .84 .84],'LineWidth',.6,'HandleVisibility','off');
    for j=1:count
        scatter(ax,repmat(j,10,1),values(:,j),25,colors(j,:),'filled','MarkerFaceAlpha',.3,'HandleVisibility','off');
        h=errorbar(ax,j,ss.median(j),ss.se(j),'o','Color',colors(j,:),'MarkerFaceColor',colors(j,:),'MarkerSize',8,'LineWidth',2,'CapSize',10);
        h.UserData=struct('x',j,'y',ss.median(j),'err',ss.se(j),'raw',values(:,j),'indexKind','current','kind','networkBootstrap');
    end
    xticks(ax,1:count); xticklabels(ax,names); xlim(ax,[.6 count+.4]);
end

function empiricalModel(ax,estimates,errors,values,indices,colors,names)
    hold(ax,'on'); ss=stage2_bootstrap(values,indices);
    for j=1:2
        x=[1 2]+(j-1.5)*.3; y=[estimates(j) ss.median(j)]; err=[errors(j) ss.se(j)];
        h=bar(ax,x,y,.25,'FaceColor',colors(j,:),'DisplayName',names{j}); h.UserData=struct('x',x,'y',y,'kind','source');
        h=errorbar(ax,x,y,err,'k.','LineStyle','none','CapSize',8,'HandleVisibility','off'); h.UserData=struct('x',x,'y',y,'err',err,'kind','source');
        scatter(ax,repmat(x(2),10,1),values(:,j),18,colors(j,:),'filled','MarkerFaceAlpha',.3,'HandleVisibility','off');
    end
    plot(ax,[1.85 2.15],values.','Color',[.8 .8 .8],'LineWidth',.5,'HandleVisibility','off');
    xticks(ax,[1 2]); xticklabels(ax,{'Experiment (resample SD)','Model (network-median SE)'}); legend(ax,'Location','best');
end

function schematic(ax)
    axis(ax,[0 1 0 1]); axis(ax,'off'); hold(ax,'on'); title(ax,'C  Effective state setting + prospective stabilization');
    text(ax,.03,.84,{'Base input','u_{base} = -f(x_B)'},'BackgroundColor',[.94 .94 .94],'Margin',12,'FontSize',17);
    text(ax,.56,.84,{'Cerebellar-dependent terms','b = f(x_B) - f(x*)','-L(x - x*)'},'BackgroundColor',[.87 .95 1],'Margin',12,'FontSize',17);
    text(ax,.5,.42,{'Recurrent cortex','\tau dx/dt = f(x) + u','Intact: base + b - L(x-x*)','Block: base only'},'HorizontalAlignment','center','FontSize',18);
    text(ax,.5,.05,'Achieved GO state -> frozen movement generator','HorizontalAlignment','center','FontSize',16);
    quiver(ax,[.2 .75 .5],[.69 .66 .27],[.18 -.15 0],[-.16 -.14 -.12],0,'k','LineWidth',1.5,'MaxHeadSize',.6);
end

function limits=trajectories(ax,hand,home,targets,colors,condition)
    hold(ax,'on'); theta=linspace(0,2*pi,100); allXY=[];
    for q=1:8
        target=targets(q,:); patch(ax,100*(target(1)+.015*cos(theta)),100*(target(2)+.015*sin(theta)),colors(q,:),'FaceAlpha',.12,'EdgeColor',colors(q,:));
        ids=(q-1)*30+(1:30);
        for tr=ids
            xy=reshape(hand(:,[1 3],tr),[],2)-home;
            stop=find(vecnorm(xy-target,2,2)<=.015,1); if isempty(stop), stop=size(xy,1); end
            h=plot(ax,100*xy(1:stop,1),100*xy(1:stop,2),'Color',.8+.2*colors(q,:),'LineWidth',.45);
            h.UserData=struct('x',100*xy(1:stop,1),'y',100*xy(1:stop,2),'kind','trajectory','trial',tr,'condition',condition,'stop',stop);
            allXY=[allXY;xy(1:stop,:)]; %#ok<AGROW>
        end
        xy=mean(hand(:,[1 3],ids),3)-home; stop=find(vecnorm(xy-target,2,2)<=.015,1); if isempty(stop), stop=size(xy,1); end
        h=plot(ax,100*xy(1:stop,1),100*xy(1:stop,2),'Color',colors(q,:),'LineWidth',2);
        h.UserData=struct('x',100*xy(1:stop,1),'y',100*xy(1:stop,2),'kind','targetMean','target',q,'condition',condition,'stop',stop);
        allXY=[allXY;xy(1:stop,:)]; %#ok<AGROW>
    end
    allXY=100*[allXY;targets-.015;targets+.015]; pad=1;
    limits=[min(allXY(:,1))-pad max(allXY(:,1))+pad min(allXY(:,2))-pad max(allXY(:,2))+pad];
    axis(ax,'equal'); xlabel(ax,'Hand x (cm)'); ylabel(ax,'Hand y (cm)'); names={'Intact','Block'}; title(ax,['D  ' names{condition} ' | network 1']);
end

function lossMap(ax,values,selected,label)
    h=imagesc(ax,1:6,1:6,reshape(values,6,6)); h.UserData=struct('image',reshape(values,6,6));
    set(ax,'YDir','normal'); hold(ax,'on'); [b,a]=ind2sub([6 6],selected); plot(ax,a,b,'wp','MarkerFaceColor','k','MarkerSize',15);
    xticks(ax,1:6); xticklabels(ax,{'0.1','0.2','0.35','0.5','0.75','1'}); yticks(ax,1:6); yticklabels(ax,{'0.1','0.25','0.5','0.75','1','1.25'});
    xlabel(ax,'Shared \alpha'); ylabel(ax,'Shared \beta_{norm}'); cb=colorbar(ax); ylabel(cb,label);
end

function label=testLabel(test)
    label=sprintf('n=%d networks; p=%.3g',test.n,test.p);
end

function receipt=savePair(f,root,folder,name,receipt)
    base=fullfile(root,'plots','paper_ready','final_v2',folder); figDir=fullfile(base,'fig'); pngDir=fullfile(base,'png');
    if ~isfolder(figDir), mkdir(figDir); end
    if ~isfolder(pngDir), mkdir(pngDir); end
    fig=fullfile(figDir,[name '.fig']); png=fullfile(pngDir,[name '.png']); assert(~isfile(fig)&&~isfile(png));
    drawnow; savefig(f,fig); exportgraphics(f,png,'Resolution',160); close(f);
    reopened=openfig(fig,'invisible'); closer=onCleanup(@()close(reopened)); objects=findall(reopened,'-property','UserData'); checks=0;
    for h=objects.'
        u=h.UserData; if ~isstruct(u), continue; end
        if isfield(u,'x'), assert(isequaln(h.XData(:),u.x(:)) && isequaln(h.YData(:),u.y(:))); checks=checks+1; end
        if isfield(u,'err'), assert(isequaln(h.YPositiveDelta(:),u.err(:)) && isequaln(h.YNegativeDelta(:),u.err(:))); end
        if isfield(u,'image'), assert(isequaln(h.CData,u.image)); checks=checks+1; end
        if isfield(u,'raw')
            indices=reopened.UserData.indices; if strcmp(u.indexKind,'legacy'), indices=reopened.UserData.legacyIndices; end
            for j=1:size(u.raw,2)
                v=u.raw(:,j); draws=median(reshape(v(indices),size(indices)),2); se=sqrt(sum((draws-mean(draws)).^2)/(size(indices,1)-1));
                assert(isequaln(median(v),u.y(j))); assert(isequal(isnan(se),isnan(u.err(j))));
                if isfinite(se), assert(abs(se-u.err(j))<1e-10); end
            end
        end
    end
    receipt.pairs{end+1}=struct('fig',fig,'png',png,'objectChecks',checks); receipt.objectChecks=receipt.objectChecks+checks;
end
