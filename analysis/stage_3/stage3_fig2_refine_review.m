function review = stage3_fig2_refine_review(cfg)
    % Saved-output reporting and support/mask checks, no model simulation.
    target=fullfile(cfg.resultsRoot,'gain_time','refined');
    s=load(fullfile(target,'gain_time.mat'),'result'); r=s.result;
    s=load(fullfile(cfg.resultsRoot,'gain_time','gain_time.mat'),'result'); old=s.result;
    assert(strcmp(r.status,'PASS'));
    assert(all(isfinite(r.stateError),'all'));
    keys={'pr','observed','expected','deficit','K','referenceK','policyK','referenceCapture','policyCapture'};
    for j=1:numel(keys)
        values=r.(keys{j}); assert(all(isnan(values(:,:,:,1:11)),'all'));
        assert(all(isfinite(values(:,:,:,12:end)),'all'));
        assert(isequal(values(:,:,:,21:end),old.(keys{j})));
    end
    assert(isequal(r.stateError(:,:,:,21:end),old.stateError));
    assert(all(r.referenceCapture(:,:,:,12:end)>.95,'all'));
    assert(all(r.policyCapture(:,:,:,12:end)>.95,'all'));
    review=struct('status','PASS','dimensionOrder',r.dimensionOrder, ...
        'stateCells',numel(r.stateError),'definedPopulationCells',nnz(isfinite(r.pr)), ...
        'maskedPopulationCellsPerMetric',nnz(isnan(r.pr)), ...
        'oldIntervalBitwiseUnchanged',true,'checks',r.checkCount, ...
        'maxError',r.maxCheckError,'Krange',r.Krange,'newNullK',{r.newNullK}, ...
        'reusedPreparations',r.reusedPreparations,'newPreparations',r.newPreparations);
    metrics={'stateError','pr','deficit'}; review.panelLimits=zeros(3,2,2);
    for j=1:3
        for b=1:2
            v=r.median.(metrics{j})(:,b,:); v=v(isfinite(v));
            review.panelLimits(j,b,:)=[min(v) max(v)];
        end
    end
    rows=[];
    for b=1:2
        for gi=[1 7 13]
            for endpoint=[-600 -500 -490 -480 -460 -450 -400 0]
                ti=find(r.endpointGO==endpoint);
                rows(end+1,:)=[r.sustained(b),r.nu(gi),endpoint, ...
                    r.median.stateError(gi,b,ti),r.median.pr(gi,b,ti), ...
                    r.median.observed(gi,b,ti),r.median.expected(gi,b,ti),r.median.deficit(gi,b,ti)]; %#ok<AGROW>
            end
        end
    end
    table=array2table(rows,'VariableNames',{'bPresent','nu','endpointGOms','stateError','PR','observed','expected','deficit'});
    writetable(table,fullfile(target,'review_anchors.csv'));
    review.anchors=table2struct(table);
    review.redundantNullFiles={};
    for n=1:10
        file=fullfile(cfg.cacheRoot,'gain_time','refined',sprintf('null_n%02d.mat',n));
        if isfile(file)
            a=load(file,'nulls');
            oldFile=fullfile(cfg.cacheRoot,'gain_time',sprintf('null_n%02d.mat',n));
            b=load(oldFile,'nullEvidence');
            if isequal(a.nulls,b.nullEvidence)
                review.redundantNullFiles{end+1}=struct('path',file,'sha256',sha256_file(file), ...
                    'preservedSource',oldFile,'preservedSourceSHA256',sha256_file(oldFile));
            end
        end
    end
    stage3_write_json(fullfile(cfg.manifestRoot,'FIG2_REFINE_REVIEW.json'),review);
    disp(rmfield(review,'anchors'));
end
