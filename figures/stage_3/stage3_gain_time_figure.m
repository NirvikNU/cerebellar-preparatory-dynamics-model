function receipt = stage3_gain_time_figure(cfg)
    assert(~isfile(fullfile(cfg.resultsRoot,'biological_revision','resume_02','independent_audit.json')), ...
        'Stage3:Historical','Isotropic gain heatmaps are historical and cannot overwrite current biological-controller figures.');
    s=load(fullfile(cfg.resultsRoot,'gain_time','refined','gain_time.mat'),'result'); r=s.result;
    assert(strcmp(r.status,'PASS'));
    f=figure('Visible','off','Color','w','Position',[60 40 1500 1200]);
    layout=tiledlayout(f,3,2,'Padding','loose','TileSpacing','loose');
    layout.OuterPosition=[0 .065 1 .935];
    names={'stateError','pr','deficit'};
    labels={'A  Full-200D state error','B  Preparatory PR','C  Expected - observed alignment'};
    units={'Model-state units','Participation ratio','Alignment fraction'};
    for row=1:3
        data=r.median.(names{row});
        for family=1:2
            ax=nexttile(layout); values=squeeze(data(:,family,:));
            finite=values(isfinite(values)); limits=[min(finite) max(finite)];
            assert(limits(2)>limits(1),'A constant panel requires explicit linear-scale handling.');
            h=imagesc(ax,r.endpointGO,r.nu,values); h.AlphaData=double(isfinite(values));
            set(ax,'YDir','normal','Color',[.86 .86 .86]);
            clim(ax,limits); colormap(ax,parula(256)); hold(ax,'on');
            yline(ax,3,'w--','LineWidth',1.4,'Tag','primary_gain');
            xline(ax,-500,'k:','LineWidth',1.5,'Tag','cue');
            xline(ax,0,'k-','LineWidth',1.4,'Tag','go');
            plot(ax,[0 0],[0 3],'ks','MarkerSize',9,'LineStyle','none','LineWidth',1.5);
            ax.XLim=[-600 0]; ax.YLim=[-.25 6.25]; ax.XTick=-600:100:0; ax.YTick=0:1:6;
            ax.XTickLabel={'-600','-500\newlineCue','-400','-300','-200','-100','0\newlineGO'};
            title(ax,sprintf('%s | b %s',labels{row},pick(family==1,'present','absent')),'FontWeight','normal');
            xlabel(ax,'Preparation time relative to GO (ms)'); ylabel(ax,'Feedback gain \nu');
            cb=colorbar(ax); cb.Label.String=units{row}; cb.FontSize=13;
            if row==1 && max(abs(finite))<1e-10
                cb.Ticks=linspace(limits(1),limits(2),4);
                cb.TickLabels=compose('%.2e',cb.Ticks);
                title(ax,[ax.Title.String ' (numerically zero)'],'FontWeight','normal');
            end
            apply_plot_style(ax,cfg); ax.FontSize=14;
            ax.UserData=struct('metric',names{row},'policy',family);
        end
    end
    title(layout,{'Fixed cortical policy: gain and preparation time', ...
        'n=10 medians | \alpha=0.1, \beta_{norm}=1 | 100-ms PR/alignment windows | independent panel scales'},'FontWeight','normal','FontSize',18);
    annotation(f,'textbox',[.04 .004 .94 .043],'String', ...
        {'Gray: zero target covariance; PR/alignment undefined. Colors are not quantitatively comparable across panels.', ...
        'GO squares: b present, \nu=0 / 3 = remove feedback / intact; b absent, \nu=0 / 3 = remove both / remove b.'}, ...
        'EdgeColor','none','HorizontalAlignment','center','FontSize',12);
    [fig,png]=save_figure_bundle(f,'diagnostic_2_component_removal',cfg);
    f=openfig(fig,'invisible'); axes=findall(f,'Type','axes'); count=0;
    for j=1:numel(axes)
        ax=axes(j); if ~isstruct(ax.UserData) || ~isfield(ax.UserData,'metric'), continue; end
        h=findobj(ax,'Type','image');
        expected=squeeze(r.median.(ax.UserData.metric)(:,ax.UserData.policy,:));
        assert(isequaln(h.CData,expected),'Plotted values differ.'); count=count+1;
    end
    assert(count==6); close(f); im=imread(png); assert(size(im,2)>1000);
    receipt=struct('status','PASS','heatmapsChecked',count,'fig',fig,'png',png, ...
        'figureSHA256',sha256_file(fig),'pngSHA256',sha256_file(png));
    stage3_write_json(fullfile(cfg.manifestRoot,'FIG2_REFINE_FIGURE.json'),receipt);
end

function out=pick(test,a,b)
    if test, out=a; else, out=b; end
end
