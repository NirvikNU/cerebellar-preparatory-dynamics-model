function target = paper_empirical_audit(root)
    % Independent reopen and exact cross-check of all bars/errorbar graphics.
    dest=fullfile(root,'results','paper_ready','empirical');
    s=load(fullfile(dest,'graphics_inventory.mat'),'receipt');
    f=openfig(fullfile(dest,'dimensionality_alignment_epochs_raw_data.fig'),'invisible');
    closer=onCleanup(@()close(f)); names={'Control','Block','Observed','Expected'};
    values=zeros(4,4); errors=zeros(4,4); checks=0;
    for j=1:4
        bar=findall(f,'Type','bar','DisplayName',names{j}); assert(isscalar(bar));
        ax=ancestor(bar,'axes'); assert(strcmp(ax.XTickLabel{2},'Prep'));
        eb=findall(ax,'Type','errorbar');
        match=arrayfun(@(h)isequal(h.XData,bar.XData)&&isequal(h.YData,bar.YData),eb);
        assert(nnz(match)==1); eb=eb(match);
        assert(isequal(eb.YNegativeDelta,eb.YPositiveDelta));
        values(j,:)=bar.YData; errors(j,:)=eb.YPositiveDelta;
        old=s.receipt.objects;
        found=cellfun(@(r)isfield(r,'DisplayName') && strcmp(r.Type,'bar') && strcmp(r.DisplayName,names{j}),old);
        assert(nnz(found)==1 && isequal(old{found}.YData,bar.YData)); checks=checks+4;
    end
    target.names=names; target.allEpochValues=values; target.allEpochErrors=errors;
    target.prep=values(:,2); target.error=errors(:,2);
    target.deltaPR=values(2,2)-values(1,2);
    target.alignmentDeficitPP=values(4,2)-values(3,2);
    target.alignmentDeficit=target.alignmentDeficitPP/100;
    target.errorDefinition='SD across1000 trial-balanced pooled-neuron resamples; Main_text_v8 Supplementary Fig3';
    target.pairedEffectError='Not identifiable from marginal FIG; not used as loss weights';
    target.checks=checks; target.status='PASS';
    assert(target.deltaPR~=0 && target.alignmentDeficit~=0);
    paper_json(fullfile(dest,'targets.json'),target);
    save(fullfile(dest,'targets.mat'),'target');
    disp(target);
end
