function receipt=ns_figures(root)
    addpath(fullfile(root,'analysis','paper_ready','noise_sensitivity')); cfg=ns_paths(root);
    a=jsondecode(fileread(fullfile(cfg.dest,'audit.json'))); assert(strcmp(a.status,'PASS'));
    s=load(fullfile(cfg.dest,'summary.mat'),'summary'); r=s.summary;
    figdir=fullfile(root,'plots','paper_ready','noise_sensitivity','fig'); pngdir=fullfile(root,'plots','paper_ready','noise_sensitivity','png');
    if ~isfolder(figdir), mkdir(figdir); end
    if ~isfolder(pngdir), mkdir(pngdir); end
    ids={[1 2 3],[4 2 5]}; colors=[86 180 233;213 94 0]/255; styles={'-','--'}; x=[.05 .1 .2];
    pos=[.08 .57 .39 .31;.57 .57 .39 .31;.08 .14 .39 .31;.57 .14 .39 .31];
    axesTitles={'A  Initial noise: temporal fixed at 0.10','B  Temporal noise: initial fixed at 0.10', ...
        'C  Initial noise: temporal fixed at 0.10','D  Temporal noise: initial fixed at 0.10'};
    xlabels={'Initial cue-noise scale (model-state units)','Temporal noise scale (model-state units)'};
    for kind=1:2
        f=figure('Visible','off','Color','w','Position',[40 40 1800 1100]);
        set(f,'DefaultAxesFontName','Arial','DefaultAxesFontSize',16,'DefaultAxesLineWidth',1.1);
        if kind==1, fields={'r2','convergence'}; labels={'Pooled held-out R^2','C = 1 - d_{pre-go} / d_{cue}'};
        else, fields={'lossPct','deltaC'}; labels={'Paired Block R^2 loss (%)','Paired C_{Block} - C_{Intact}'}; end
        for row=1:2
            field=fields{row}; mu=reshape(r.bootstrap.(field).median,2,5,[]); se=reshape(r.bootstrap.(field).se,2,5,[]);
            values=reshape(r.(field),10,2,5,[]);
            for col=1:2
                tile=(row-1)*2+col; ax=axes(f,'Position',pos(tile,:)); hold(ax,'on');
                for e=1:2
                    for p=1:size(values,4)
                        color=colors(p,:); name=sprintf('%s | eta %g',cfg.names{p},cfg.eta(e));
                        if kind==2, color=[.2 .2 .2]; if e==2, color=[.55 .55 .55]; end, name=sprintf('eta %g',cfg.eta(e)); end
                        for n=1:10
                            y=reshape(values(n,e,ids{col},p),1,3);
                            plot(ax,x,y,styles{e},'Color',.76+.24*color,'LineWidth',.6,'HandleVisibility','off', ...
                                'UserData',struct('source',y,'x',x,'field',field,'network',n,'etaIndex',e,'pairIndices',ids{col},'condition',p));
                        end
                        y=reshape(mu(e,ids{col},p),1,3); err=reshape(se(e,ids{col},p),1,3);
                        errorbar(ax,x,y,err,[styles{e} 'o'],'Color',color,'MarkerFaceColor',color,'MarkerSize',7,'LineWidth',2.4,'CapSize',9, ...
                            'DisplayName',name,'Tag','Summary','UserData',struct('source',y,'se',err,'x',x,'field',field,'etaIndex',e,'pairIndices',ids{col},'condition',p));
                    end
                end
                xline(ax,.1,':','Color',[.45 .45 .45],'LineWidth',1,'HandleVisibility','off');
                if row==2 || kind==2, yline(ax,0,':','Color',[.3 .3 .3],'HandleVisibility','off'); end
                xlim(ax,[.035 .215]); set(ax,'XTick',x,'XTickLabel',{'0.05','0.10','0.20'},'Box','off','TickDir','out','FontSize',16);
                xlabel(ax,xlabels{col}); ylabel(ax,labels{row}); title(ax,axesTitles{tile},'FontSize',17,'FontWeight','normal');
                if tile==1, legend(ax,'Location','best','FontSize',12,'NumColumns',2); end
            end
        end
        titles={'Final preparation-noise sensitivity | Intact and full Block','Final preparation-noise sensitivity | within-network condition effects'};
        sgtitle(f,{titles{kind},'10 networks; median +/- fixed whole-network bootstrap SE; pale lines = networks'},'FontName','Arial','FontSize',21);
        annotation(f,'textbox',[.06 .015 .90 .055],'String',{ ...
            'Solid: eta 0; dashed: eta 1. Dotted vertical: reused 0.10/0.10 anchor. No noise or eta selected.', ...
            'C is a model-native held-out cue-to-pre-go analogue, not equilibrium stability. No post-GO noise.'}, ...
            'EdgeColor','none','HorizontalAlignment','center','FontSize',13);
        names={'noise_sensitivity_absolute','noise_sensitivity_paired'}; receipt(kind)=savePair(f,names{kind},figdir,pngdir,r); %#ok<AGROW>
    end
    paper_json(fullfile(cfg.manifest,'FIGURES.json'),struct('status','PASS','figures',receipt));
end

function receipt=savePair(f,name,figdir,pngdir,r)
    fp=fullfile(figdir,[name '.fig']); pp=fullfile(pngdir,[name '.png']); assert(~isfile(fp)&&~isfile(pp));
    savefig(f,fp); exportgraphics(f,pp,'Resolution',160); close(f); f=openfig(fp,'invisible'); hs=findall(f); checks=0;
    for j=1:numel(hs)
        if ~isprop(hs(j),'UserData'), continue; end
        u=hs(j).UserData; if ~isstruct(u)||~isfield(u,'source'), continue; end
        assert(isequaln(hs(j).YData(:),u.source(:)) && isequaln(hs(j).XData(:),u.x(:)));
        if isfield(u,'se')
            mu=reshape(r.bootstrap.(u.field).median,2,5,[]); se=reshape(r.bootstrap.(u.field).se,2,5,[]);
            assert(isequaln(u.source(:),reshape(mu(u.etaIndex,u.pairIndices,u.condition),[],1)));
            assert(isequaln(u.se(:),reshape(se(u.etaIndex,u.pairIndices,u.condition),[],1)));
            assert(isequaln(hs(j).YNegativeDelta(:),u.se(:)) && isequaln(hs(j).YPositiveDelta(:),u.se(:)));
        else
            v=reshape(r.(u.field),10,2,5,[]); assert(isequaln(u.source(:),reshape(v(u.network,u.etaIndex,u.pairIndices,u.condition),[],1)));
        end
        checks=checks+1;
    end
    close(f); assert(checks>0); receipt=struct('name',name,'fig',fp,'png',pp,'sourceObjectChecks',checks,'reopened',true);
end
