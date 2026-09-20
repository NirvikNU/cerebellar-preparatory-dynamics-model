function receipt = paper_figures(root,allowReviewedReplacement)
    % Cache-only paper figures a-d; deliberately no prediction or panel e.
    if nargin<2, allowReviewedReplacement=false; end
    addpath(fullfile(root,'analysis','paper_ready'),fullfile(root,'analysis','stage_2'),fullfile(root,'config'));
    dest=fullfile(root,'results','paper_ready');
    s=load(fullfile(dest,'geometry.mat'),'result'); grid=s.result;
    s=load(fullfile(dest,'controls.mat'),'result'); controls=s.result;
    s=load(fullfile(dest,'timing','timing.mat'),'result'); timing=s.result;
    s=load(fullfile(root,'results','stage_2','current','neural_geometry_r2','analysis.mat'),'out'); stage2=s.out;
    audit=jsondecode(fileread(fullfile(dest,'independent_audit.json'))); assert(strcmp(audit.status,'PASS'));
    target=grid.target; ix=grid.map.gridIndex==grid.selectedIndex; point=grid.map(ix,:);
    colors=[86 180 233;0 158 115;204 121 167;213 94 0]/255;
    figRoot=fullfile(root,'plots','paper_ready','fig'); pngRoot=fullfile(root,'plots','paper_ready','png');
    if ~isfolder(figRoot), mkdir(figRoot); end
    if ~isfolder(pngRoot), mkdir(pngRoot); end
    receipt.figures={}; receipt.sourceData='results/paper_ready'; receipt.panelE=false;
    receipt.allowReviewedReplacement=allowReviewedReplacement;
    f=newFigure([1800 1080]); tiledlayout(f,2,3,'TileSpacing','compact','Padding','compact');
    ax=nexttile; summaryLine(ax,stage2.cfg.lambda,stage2.pr,stage2.bootstrapIndices,colors(1,:),'PR');
    set(ax,'XScale','log'); xlabel(ax,'Effort penalty \lambda'); ylabel(ax,'Late-prep participation ratio'); title(ax,'a  Re-optimized feedback effort');
    ax=nexttile; summaryLine(ax,stage2.cfg.lambda,100*stage2.observed,stage2.bootstrapIndices,[.25 .25 .25],'Observed');
    summaryLine(ax,stage2.cfg.lambda,100*stage2.expected,stage2.bootstrapIndices,[.65 .65 .65],'Expected');
    set(ax,'XScale','log'); xlabel(ax,'Effort penalty \lambda'); ylabel(ax,'Control-to-\lambda alignment (%)');
    title(ax,'b  Alignment remains above null'); legend(ax,'Location','best');
    ax=nexttile; hold(ax,'on'); axis(ax,[0 1 0 1]); axis(ax,'off'); title(ax,'c  Two functions, one effective input');
    boxText(ax,[.03 .70 .39 .18],{'Residual preparation','u_0=-f(x_B)-\kappa_0(x-x_B)'},[.92 .92 .92]);
    boxText(ax,[.56 .70 .41 .18],{'Cerebellar input','State setting b','Feedback -L(x-x*)'},[.87 .94 1]);
    boxText(ax,[.25 .36 .50 .18],{'Frozen recurrent cortex','\tau dx/dt=f(x)+u_0+b-L(x-x*)'},[1 1 1]);
    boxText(ax,[.21 .02 .58 .17],{'Achieved GO state, no reset','Unchanged movement generator'},[.94 .94 .94]);
    text(ax,.01,.46,{'CB retained:','Intact: b + FB','-FB: b','-b: FB','Block: neither','Same u_0'}, ...
        'FontSize',10,'VerticalAlignment','middle');
    quiver(ax,[.23 .75 .50],[.68 .68 .34],[.17 -.17 0],[-.13 -.13 -.13],0,'k','LineWidth',1.5,'MaxHeadSize',.7);
    ax=nexttile; lossMap(ax,grid); title(ax,'d1  Geometry-only calibration');
    ax=nexttile; values=[point.prIntact point.prBlock]; ss=stage2_bootstrap(values,controls.indices);
    grouped(ax,[target.prep(1:2).';ss.median],[target.error(1:2).';ss.se],colors([1 4],:),{'Data','Model'},{'Control / Intact','Block'});
    ylabel(ax,'Late-prep participation ratio'); title(ax,'d2  Absolute PR: data vs model');
    ax=nexttile; ss=stage2_bootstrap(100*[point.observed point.expected],controls.indices);
    grouped(ax,[target.prep(3:4).';ss.median],[target.error(3:4).';ss.se],[.25 .25 .25;.75 .75 .75],{'Data','Model'},{'Observed','Expected'});
    ylabel(ax,'Alignment (%)'); title(ax,'d3  Absolute alignment');
    sgtitle(f,sprintf('Paper candidate a-d | calibrated λ=%g, α=%g, β_{norm}=%g | K=15 primary; scientific review pending',grid.lambda,point.alpha(1),point.betaNormalized(1)),'FontSize',19);
    receipt=savePair(f,'main_modelling',receipt,figRoot,pngRoot);

    f=newFigure([1800 1650]); tiledlayout(f,4,3,'TileSpacing','compact','Padding','compact');
    ax=nexttile; summaryLine(ax,timing.lambda,timing.networkMedian,controls.indices,colors(1,:),'Sustained Q readiness');
    set(ax,'XScale','log'); yline(ax,50,'--'); yline(ax,100,'--'); yline(ax,75,':');
    xlabel(ax,'\lambda'); ylabel(ax,'Readiness after cue (ms)'); title(ax,'Timing-only selection');
    ax=nexttile; summaryLine(ax,timing.lambda,median(timing.state90,3),controls.indices,[.4 .4 .4],'State 90%');
    set(ax,'XScale','log'); xlabel(ax,'\lambda'); ylabel(ax,'Sustained state 90% time (ms)'); title(ax,'State settling is a different metric');
    ax=nexttile; lossMap(ax,grid); title(ax,'All fixed-grid losses / feasibility');
    ax=nexttile; hold(ax,'on'); scatter(ax,grid.deltaPR,100*grid.deficit,50,[.6 .6 .6],'filled');
    scatter(ax,grid.deltaPR(grid.commonFeasible),100*grid.deficit(grid.commonFeasible),55,colors(1,:),'filled');
    plot(ax,target.deltaPR,target.alignmentDeficitPP,'kp','MarkerSize',14,'MarkerFaceColor','y');
    plot(ax,grid.deltaPR(grid.selectedIndex),100*grid.deficit(grid.selectedIndex),'kd','MarkerSize',11,'LineWidth',2);
    xlabel(ax,'Block-Intact PR'); ylabel(ax,'Expected-Observed (pp)'); title(ax,'Attainability; yellow=data, diamond=fit');
    ax=nexttile; lossMap(ax,grid,grid.deltaPR,'Block-Intact PR'); title(ax,'PR-effect map');
    ax=nexttile; lossMap(ax,grid,100*grid.deficit,'Expected-Observed (pp)'); title(ax,'Alignment-deficit map');
    labels={'Distance to x* (state units)','Distance to x_B (state units)','Q error / cue','Trailing-100-ms PR','Expected-Observed (pp)'};
    for metric=1:5
        ax=nexttile;
        for policy=1:4
            v=squeeze(controls.time(:,policy,:,metric)); if metric==5, v=100*v; end
            summaryLine(ax,controls.timeGO,v,controls.indices,colors(policy,:),controls.policyNames{policy},false);
        end
        xlim(ax,[-500 0]); xlabel(ax,'Time from GO (ms)'); ylabel(ax,labels{metric});
        if metric==1, legend(ax,'Location','best','FontSize',11); end
        if metric==3, set(ax,'YScale','log'); end
    end
    ax=nexttile; primary=stage2_bootstrap(100*[point.observed point.expected],controls.indices);
    adaptive=stage2_bootstrap(100*[point.observedAdaptive point.expectedAdaptive],controls.indices);
    grouped(ax,[primary.median;adaptive.median],[primary.se;adaptive.se],[.25 .25 .25;.75 .75 .75], ...
        {'K=15','K=7 (>95%)'},{'Observed','Expected'});
    ylabel(ax,'Alignment (%)'); title(ax,'PC-rule sensitivity: same selected geometry');
    sgtitle(f,'Supporting calibration and component-removal time courses | medians +/- network-bootstrap SE','FontSize',19);
    receipt=savePair(f,'support_calibration',receipt,figRoot,pngRoot);

    f=newFigure([1950 1000]); tiledlayout(f,2,4,'TileSpacing','compact','Padding','compact');
    names={'Late-prep PR','Alignment (%)','Expected-Observed (pp)','Residual variance (normalized)'};
    for kind=1:2
        for metric=1:4
            ax=nexttile; v=squeeze(controls.noise(:,kind,:,:));
            if metric==1, series=v(:,:,1); elseif metric==2, series=100*v(:,:,2); elseif metric==3, series=100*v(:,:,4); else, series=v(:,:,5); end
            summaryLine(ax,controls.levels,series,controls.indices,colors(1,:),'Intact, varied noise');
            failed=reshape(any(controls.noiseBounds(:,kind,:,4)==0,1),1,5);
            if any(failed)
                plot(ax,controls.levels(failed),median(series(:,failed),1),'kx','MarkerSize',10,'LineWidth',1.5,'HandleVisibility','off');
            end
            if metric==2, summaryLine(ax,controls.levels,100*v(:,:,3),controls.indices,[.65 .65 .65],'Expected',false); end
            if metric==1, ref=squeeze(controls.policy(:,4,1)); elseif metric==2, ref=100*squeeze(controls.policy(:,4,2)); elseif metric==3, ref=100*squeeze(controls.policy(:,4,4)); else, ref=squeeze(controls.policy(:,4,5)); end
            blockSummary=stage2_bootstrap(ref,controls.indices);
            ylo=blockSummary.median-blockSummary.se; yhi=blockSummary.median+blockSummary.se;
            patch(ax,[0 .4 .4 0],[ylo ylo yhi yhi],colors(4,:),'FaceAlpha',.10,'EdgeColor','none','HandleVisibility','off');
            yline(ax,median(ref),'--','Block (.10,.10)','Color',colors(4,:),'FontSize',11,'HandleVisibility','off');
            xline(ax,.1,':','Primary','FontSize',11,'HandleVisibility','off'); ylabel(ax,names{metric});
            if metric==2, legend(ax,'Location','best','FontSize',10); end
            xticks(ax,controls.levels);
            if kind==1, xlabel(ax,'Cue-state noise s_{init} (state units)'); else, xlabel(ax,'Temporal noise s_{temporal} (state units)'); end
        end
    end
    sgtitle(f,'Noise-only alternatives: separate one-factor sweeps, intact components unchanged','FontSize',19);
    receipt=savePair(f,'support_noise_controls',receipt,figRoot,pngRoot);

    s=load(fullfile(dest,'cache','controls_n01.mat'),'moves'); targetColors=lines(8);
    home=s.moves{1}.hand(1,[1 3],1); targetCfg=stage_1_gate1_config(root);
    targetXY=1000*targetCfg.gate1.radiusM*[cosd(targetCfg.gate1.targetAnglesDeg(:)) sind(targetCfg.gate1.targetAnglesDeg(:))];
    xymin=[Inf Inf]; xymax=[-Inf -Inf]; speedMax=0;
    for policy=1:4
        xy=(reshape(permute(s.moves{policy}.hand(:,[1 3],:),[1 3 2]),[],2)-home)*1000;
        xymin=min(xymin,min(xy,[],1)); xymax=max(xymax,max(xy,[],1));
        speedMax=max(speedMax,max(s.moves{policy}.speed,[],'all'));
    end
    xymin=min(xymin,min(targetXY,[],1)); xymax=max(xymax,max(targetXY,[],1));
    pad=.05*max(xymax-xymin,1); handLimits=[xymin-pad;xymax+pad];
    f=newFigure([1950 1850]); tiledlayout(f,5,3,'TileSpacing','compact','Padding','compact');
    allPeaks=zeros(2400,4);
    for policy=1:4
        move=s.moves{policy}; ax=nexttile; hold(ax,'on'); ax2=nexttile; hold(ax2,'on');
        speedHandles=gobjects(8,1);
        for q=1:8
            ix=(q-1)*30+(1:30); pale=.75+.25*targetColors(q,:);
            for tr=ix
                plot(ax,1000*(move.hand(:,1,tr)-home(1)),1000*(move.hand(:,3,tr)-home(2)),'Color',pale,'LineWidth',.35);
                plot(ax2,0:size(move.speed,1)-1,move.speed(:,tr),'Color',pale,'LineWidth',.35);
            end
            plot(ax,1000*(median(move.hand(:,1,ix),3)-home(1)),1000*(median(move.hand(:,3,ix),3)-home(2)),'Color',targetColors(q,:),'LineWidth',1.5);
            plot(ax,targetXY(q,1),targetXY(q,2),'o','Color',targetColors(q,:),'MarkerSize',7,'LineWidth',1.2);
            med=median(move.speed(:,ix),2); lo=prctile(move.speed(:,ix),25,2); hi=prctile(move.speed(:,ix),75,2); tt=(0:numel(med)-1).';
            fill(ax2,[tt;flipud(tt)],[lo;flipud(hi)],targetColors(q,:),'FaceAlpha',.12,'EdgeColor','none');
            speedHandles(q)=plot(ax2,tt,med,'Color',targetColors(q,:),'LineWidth',1.5,'DisplayName',sprintf('T%d',q));
        end
        plot(ax,0,0,'k+','MarkerSize',8,'LineWidth',1.5);
        axis(ax,'equal'); xlim(ax,handLimits(:,1)); ylim(ax,handLimits(:,2));
        xlabel(ax,'Hand displacement x (mm)'); ylabel(ax,'Hand displacement y (mm)'); title(ax,[controls.policyNames{policy} ': network 1, all targets']);
        xlim(ax2,[0 599]); ylim(ax2,[0 1.05*speedMax]);
        xlabel(ax2,'Time from GO (ms)'); ylabel(ax2,'Unsmoothed hand speed (m/s)'); title(ax2,'Thin trials; median and within-target IQR');
        if policy==1, legend(ax2,speedHandles,'Location','northoutside','NumColumns',4,'FontSize',10); end
        ax=nexttile; hold(ax,'on'); mo=[]; peak=[];
        flags=zeros(1,3);
        for n=1:10
            a=load(fullfile(dest,'cache',sprintf('controls_n%02d.mat',n)),'moves');
            mo=[mo a.moves{policy}.moMs]; peak=[peak a.moves{policy}.peakMs]; %#ok<AGROW>
            allPeaks((n-1)*240+(1:240),policy)=a.moves{policy}.peak(:);
            flags=flags+[sum(a.moves{policy}.nearZero) sum(a.moves{policy}.boundaryPeak) sum(a.moves{policy}.missingWindow)];
        end
        histogram(ax,mo,0:20:600,'DisplayName','MO','FaceColor',colors(policy,:),'FaceAlpha',.6);
        histogram(ax,peak,0:20:600,'DisplayName','Peak','FaceColor',[.4 .4 .4],'FaceAlpha',.4);
        xlabel(ax,'Time from GO (ms)'); ylabel(ax,'Trials (nested in 10 networks)'); legend(ax,'FontSize',11);
        title(ax,{'All 2,400 trials; no exclusions',sprintf('Near-zero / boundary / missing: %d / %d / %d',flags)},'FontSize',12);
    end
    ax=nexttile; hold(ax,'on'); edges=linspace(0,max(allPeaks,[],'all'),31);
    for policy=1:4
        histogram(ax,allPeaks(:,policy),edges,'DisplayStyle','stairs','EdgeColor',colors(policy,:), ...
            'LineWidth',1.5,'DisplayName',controls.policyNames{policy});
    end
    xlabel(ax,'Own-trial peak speed (m/s)'); ylabel(ax,'Trials (nested in 10 networks)');
    title(ax,'Peak-speed distributions: common bins'); legend(ax,'FontSize',10);
    ax=nexttile; policyBars(ax,squeeze(controls.policy(:,:,6)),controls.indices,colors,controls.policyNames);
    ylabel(ax,'Within-target endpoint RMS (mm)'); title(ax,'Endpoint dispersion; network median +/- SE');
    ax=nexttile; policyBars(ax,squeeze(controls.policy(:,:,10)),controls.indices,colors,controls.policyNames);
    ylabel(ax,'Centroid separation / within-target scatter'); title(ax,'Target separation; network median +/- SE');
    sgtitle(f,'Movement QC | native deterministic post-GO movement; target colors, never opposite-target averaging','FontSize',19);
    receipt=savePair(f,'support_movement_qc',receipt,figRoot,pngRoot);
    paper_json(fullfile(root,'artifacts','manifests','paper_ready','FIGURES.json'),receipt);
end

function f=newFigure(position)
    f=figure('Visible','off','Color','w','Position',[30 30 position]);
    set(f,'DefaultAxesFontSize',16,'DefaultAxesFontName','Arial','DefaultAxesTickDir','out', ...
        'DefaultAxesBox','off','DefaultLineLineWidth',1.5);
end

function summaryLine(ax,x,values,indices,color,name,individual)
    if nargin<7, individual=true; end
    hold(ax,'on'); ss=stage2_bootstrap(values,indices);
    if individual
        for n=1:10, plot(ax,x,values(n,:),'.','Color',.5+.5*color,'MarkerSize',6,'HandleVisibility','off'); end
    end
    h=errorbar(ax,x,ss.median,ss.se,'-o','Color',color,'MarkerFaceColor',color, ...
        'MarkerSize',4,'CapSize',4,'DisplayName',name);
    h.UserData=struct('x',x,'y',ss.median,'err',ss.se);
end

function grouped(ax,values,errors,colors,groups,names)
    hold(ax,'on');
    for j=1:2
        x=(1:size(values,1))+(j-1.5)*.3;
        h=bar(ax,x,values(:,j),.28,'FaceColor',colors(j,:),'DisplayName',names{j});
        h.UserData=struct('x',x,'y',values(:,j));
        h=errorbar(ax,x,values(:,j),errors(:,j),'k.','LineStyle','none','CapSize',7,'HandleVisibility','off');
        h.UserData=struct('x',x,'y',values(:,j),'err',errors(:,j));
    end
    xticks(ax,1:size(values,1)); xticklabels(ax,groups); legend(ax,'Location','best','FontSize',12);
end

function lossMap(ax,grid,values,label)
    if nargin<3, values=grid.loss; end
    if nargin<4, label='Effect-normalized squared loss'; end
    z=reshape(values,6,6); h=imagesc(ax,1:6,1:6,z); h.AlphaData=isfinite(z);
    set(ax,'YDir','normal','Color',[.92 .92 .92]); hold(ax,'on');
    [b,a]=find(~reshape(grid.commonFeasible,6,6)); plot(ax,a,b,'kx','MarkerSize',10,'LineWidth',1.5);
    [b,a]=ind2sub([6 6],grid.selectedIndex); plot(ax,a,b,'wp','MarkerFaceColor','k','MarkerSize',14);
    xticks(ax,1:6); xticklabels(ax,{'0.1','0.2','0.35','0.5','0.75','1'});
    yticks(ax,1:6); yticklabels(ax,{'0.1','0.25','0.5','0.75','1','1.25'});
    xlabel(ax,'Geometry \alpha'); ylabel(ax,'Normalized \beta'); cb=colorbar(ax); ylabel(cb,label);
end

function policyBars(ax,values,indices,colors,names)
    hold(ax,'on'); ss=stage2_bootstrap(values,indices);
    for j=1:size(values,2)
        h=bar(ax,j,ss.median(j),.65,'FaceColor',colors(j,:));
        h.UserData=struct('x',j,'y',ss.median(j));
        h=errorbar(ax,j,ss.median(j),ss.se(j),'k.','CapSize',6);
        h.UserData=struct('x',j,'y',ss.median(j),'err',ss.se(j));
        plot(ax,j+linspace(-.06,.06,10),values(:,j),'.','Color',[.35 .35 .35],'MarkerSize',7);
    end
    xticks(ax,1:size(values,2)); xticklabels(ax,names); xtickangle(ax,20);
end

function boxText(ax,pos,lines,color)
    rectangle(ax,'Position',pos,'FaceColor',color,'EdgeColor',[.4 .4 .4],'LineWidth',1);
    text(ax,pos(1)+pos(3)/2,pos(2)+pos(4)/2,lines,'HorizontalAlignment','center','FontSize',12);
end

function receipt=savePair(f,name,receipt,figRoot,pngRoot)
    figPath=fullfile(figRoot,[name '.fig']); pngPath=fullfile(pngRoot,[name '.png']);
    assert(receipt.allowReviewedReplacement || (~isfile(figPath) && ~isfile(pngPath)),'Refuse unreviewed figure replacement');
    savefig(f,figPath); exportgraphics(f,pngPath,'Resolution',160); close(f);
    reopened=openfig(figPath,'invisible'); hs=findall(reopened); checks=0;
    for j=1:numel(hs)
        h=hs(j);
        if isprop(h,'UserData') && isstruct(h.UserData) && isfield(h.UserData,'y')
            d=h.UserData; assert(isequal(h.YData(:),d.y(:)) && isequal(h.XData(:),d.x(:)));
            if isfield(d,'err')
                assert(isequal(h.YPositiveDelta(:),d.err(:)) && isequal(h.YNegativeDelta(:),d.err(:)));
            end
            checks=checks+1;
        end
    end
    close(reopened);
    receipt.figures{end+1}=struct('name',name,'fig',figPath,'png',pngPath,'reopenedArrayChecks',checks);
end
