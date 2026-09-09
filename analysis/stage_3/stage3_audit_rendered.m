function audit = stage3_audit_rendered(cfg)
    % Check exported FIG objects against independent sorted-bootstrap summaries.
    s=load(fullfile(cfg.resultsRoot,'consequences.mat'),'result'); r=s.result;
    audit=struct('status','PASS','maxAbsoluteError',0,'comparisons',0);
    names={'result_1_preparation_and_movement','result_2_preparatory_geometry','diagnostic_2_component_removal'};
    for figureIndex=1:3
        if figureIndex==3 && isfile(fullfile(cfg.resultsRoot,'gain_time','gain_time.mat'))
            current=stage3_gain_time_check_figure(cfg);
            audit.comparisons=audit.comparisons+current.heatmaps;
            audit.maxAbsoluteError=max(audit.maxAbsoluteError,current.maxAbsoluteError);
            continue;
        end
        f=openfig(fullfile(cfg.plotsFigRoot,[names{figureIndex} '.fig']),'invisible');
        cleaner=onCleanup(@()close(f));
        axesList=findall(f,'Type','axes');
        if figureIndex==1
            ax=pick(axesList,'C  Movement consequence'); checkBars(ax,r.metrics.earlyErrorMM);
            I=zeros(10,501); B=I;
            for n=1:10, I(n,:)=r.primary{n}.intactDistance; B(n,:)=r.primary{n}.block.distance; end
            ax=pick(axesList,'A  Cortical preparation'); checkLine(ax,'Intact',I); checkLine(ax,'Block',B);
        elseif figureIndex==2
            checkBars(pick(axesList,'B  Preparatory dimensionality'),r.metrics.pr);
            checkBars(pick(axesList,'C  Directed alignment'),r.metrics.alignmentObservedExpected);
            I=zeros(10,15); B=I;
            for n=1:10
                p=r.primary{n}; I(n,:)=p.intactGeometry.eigenvalues(1:15)/sum(p.intactGeometry.eigenvalues);
                B(n,:)=p.block.geometry.eigenvalues(1:15)/sum(p.block.geometry.eigenvalues);
            end
            ax=pick(axesList,'A  Measured finite-window spectra'); checkLine(ax,'Intact',I); checkLine(ax,'Block',B);
        else
            values=zeros(10,4,3);
            for n=1:10
                for p=1:4
                    a=r.primary{n}.policies{p}; values(n,p,:)=[a.stateError,a.pr,a.expected-a.observed];
                end
            end
            titles={'A  Prepared-state error','B  Prep dimensionality','C  Below-null alignment'};
            for panel=1:3, checkBars(pick(axesList,titles{panel}),values(:,:,panel)); end
        end
        clear cleaner;
    end
    receipt='RENDERED_VALUE_AUDIT.json';
    if isfile(fullfile(cfg.resultsRoot,'gain_time','gain_time.mat'))
        receipt='GAIN_TIME_ALL_FIGURES_AUDIT.json';
    end
    stage3_write_json(fullfile(cfg.manifestRoot,receipt),audit);

    function checkBars(ax,values)
        [med,se]=independent(values,r.bootstrapIndices); objects=findall(ax,'Type','errorbar');
        assert(numel(objects)==size(values,2));
        for object=objects(:).'
            column=object.XData; assert(isscalar(column) && column==round(column));
            compare(object.YData,med(column)); compare(object.YNegativeDelta,se(column)); compare(object.YPositiveDelta,se(column));
        end
    end
    function checkLine(ax,label,values)
        [med,se]=independent(values,r.bootstrapIndices); object=findall(ax,'Type','line','DisplayName',label);
        assert(isscalar(object)); compare(object.YData,med);
        patches=findall(ax,'Type','patch'); found=false;
        expected=[med-se fliplr(med+se)];
        for patch=patches(:).'
            if numel(patch.YData)==numel(expected) && max(abs(patch.YData(:)-expected(:)))<1e-9, found=true; end
        end
        assert(found,'Rendered:Band','Independent bootstrap band not found for %s.',label);
    end
    function compare(actual,expected)
        assert(numel(actual)==numel(expected)); delta=max(abs(actual(:)-expected(:)));
        assert(delta<1e-9,'Rendered:Mismatch','Figure object differs from independent summary.');
        audit.maxAbsoluteError=max(audit.maxAbsoluteError,delta); audit.comparisons=audit.comparisons+1;
    end
end

function ax=pick(axesList,titleText)
    match=arrayfun(@(a)isequal(a.Title.String,titleText),axesList); assert(sum(match)==1); ax=axesList(match);
end

function [med,se]=independent(values,indices)
    ordered=sort(values,1); med=(ordered(5,:)+ordered(6,:))/2;
    draws=zeros(size(indices,1),size(values,2));
    for column=1:size(values,2)
        v=values(:,column); samples=sort(reshape(v(indices),size(indices)),2);
        draws(:,column)=(samples(:,5)+samples(:,6))/2;
    end
    average=sum(draws,1)/size(draws,1); se=sqrt(sum((draws-average).^2,1)/(size(draws,1)-1));
end
