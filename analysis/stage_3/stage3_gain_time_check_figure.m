function audit = stage3_gain_time_check_figure(cfg)
    % Read-only independent medians and saved heatmap/layout verification.
    s=load(fullfile(cfg.resultsRoot,'gain_time','gain_time.mat'),'result'); r=s.result;
    assert(strcmp(r.status,'PASS'));
    names={'stateError','pr','deficit'}; errors=zeros(3,2);
    f=openfig(fullfile(cfg.plotsFigRoot,'diagnostic_2_component_removal.fig'),'invisible');
    cleaner=onCleanup(@()close(f)); axesList=findall(f,'Type','axes'); count=0;
    for row=1:3
        sorted=sort(r.(names{row}),1); med=squeeze((sorted(5,:,:,:)+sorted(6,:,:,:))/2);
        limits=[min(med,[],'all'),max(med,[],'all')];
        for family=1:2
            match=arrayfun(@(a)isstruct(a.UserData) && isfield(a.UserData,'metric') && ...
                strcmp(a.UserData.metric,names{row}) && a.UserData.policy==family,axesList);
            assert(sum(match)==1); ax=axesList(match); h=findobj(ax,'Type','image');
            assert(isscalar(h)); expected=squeeze(med(:,family,:));
            errors(row,family)=max(abs(h.CData-expected),[],'all');
            assert(errors(row,family)==0 && isequal(ax.CLim,limits));
            assert(strcmp(ax.YDir,'normal'));
            assert(isequal(h.XData([1 end]),[-400 0]) && isequal(h.YData([1 end]),[0 6]));
            assert(isequal(linspace(h.XData(1),h.XData(end),size(h.CData,2)),r.endpointGO));
            assert(isequal(linspace(h.YData(1),h.YData(end),size(h.CData,1)),r.nu));
            count=count+1;
        end
    end
    assert(count==6); audit=struct('status','PASS','heatmaps',count,'maxAbsoluteError',max(errors,[],'all'));
    im=imread(fullfile(cfg.plotsPngRoot,'diagnostic_2_component_removal.png'));
    assert(size(im,2)>1000 && size(im,1)>1000);
end
