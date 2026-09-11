function audit = stage3_prediction_figure_audit(root)
    cfg=stage3_prediction_paths(root);
    loaded=load(fullfile(cfg.predRoot,'summary.mat'),'summary'); s=loaded.summary;
    loaded=load(fullfile(cfg.predRoot,'figure_paths.mat'),'paths'); paths=loaded.paths;
    labels={'Intact','Remove FB','Remove b','Block'};
    audit=struct('status','running','errorbarSeries',0,'maxError',0,'figuresReopened',0);
    for number=1:3
        f=openfig(paths{number,1},'invisible'); cleanup=onCleanup(@()close(f));
        assert(strcmp(f.UserData.task,cfg.task) && strcmp(f.UserData.modelCheckpoint,cfg.checkpoint));
        axs=findall(f,'Type','axes');
        for j=1:numel(axs)
            ax=axs(j); heading=ax.Title.String;
            if isempty(heading), continue; end
            panel=double(heading(1))-double('A')+1;
            if number==1
                if panel>5, continue; end
                values=reshape(s.metrics(:,2,:,panel),10,4);
            elseif number==2
                if panel<=3
                    for policy=1:4
                        bars=findall(ax,'Type','errorbar','DisplayName',labels{policy}); assert(isscalar(bars));
                        assert(isequal(bars.XData(:).',cfg.noiseLevels));
                        values=reshape(s.metrics(:,:,policy,panel),10,3);
                        audit=check(bars,values,s.bootstrapIndices,audit);
                    end
                    continue;
                else
                    values=reshape(s.matched(:,2,panel-3,:),10,2);
                end
            else
                switch panel
                    case 1, values=reshape(s.chanceMedian(:,2,:),10,4);
                    case 2, values=reshape(s.metrics(:,2,:,6),10,4);
                    case 3, values=reshape(s.metrics(:,2,:,7),10,4);
                    case 4, values=reshape(s.metrics(:,2,:,10),10,4);
                    case 5, values=100*reshape(s.orientationDeficit(:,2,:,1),10,3);
                    case 6, values=100*reshape(s.orientationDeficit(:,2,:,2),10,3);
                    otherwise, error('Unexpected prediction figure panel.');
                end
            end
            for column=1:size(values,2)
                bars=findall(ax,'Type','errorbar','Tag',sprintf('summary_%d',column)); assert(isscalar(bars));
                audit=check(bars,values(:,column),s.bootstrapIndices,audit);
            end
        end
        clear cleanup
        audit.figuresReopened=audit.figuresReopened+1;
    end
    audit.status='PASS';
    stage3_write_json(fullfile(cfg.predRoot,'figure_audit.json'),audit); disp(audit);
end

function audit = check(bar,values,indices,audit)
    expected=median(values,1); se=zeros(1,size(values,2));
    for j=1:size(values,2)
        v=values(:,j); med=median(reshape(v(indices),10000,10),2);
        se(j)=sqrt(sum((med-mean(med)).^2)/9999);
    end
    err=max([abs(bar.YData(:).'-expected),abs(bar.YNegativeDelta(:).'-se),abs(bar.YPositiveDelta(:).'-se)]);
    assert(err<1e-12); audit.maxError=max(audit.maxError,err); audit.errorbarSeries=audit.errorbarSeries+1;
end
