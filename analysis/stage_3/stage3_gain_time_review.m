function review = stage3_gain_time_review(cfg)
    % Descriptive export only; no new tests, resampling, or dynamics.
    s=load(fullfile(cfg.resultsRoot,'gain_time','gain_time.mat'),'result'); r=s.result;
    audit=jsondecode(fileread(fullfile(cfg.manifestRoot,'GAIN_TIME_AUDIT.json')));
    review=struct('status',r.status,'networkCount',10,'cellCount',numel(r.pr), ...
        'newProtocols',r.newProtocols,'reusedProtocols',r.reusedProtocols, ...
        'elapsedSeconds',r.elapsedSeconds,'auditComparisons',numel(audit.checks), ...
        'maxAuditError',max([audit.checks.error]),'KRange',[min(r.K,[],'all') max(r.K,[],'all')]);
    mask=contains({audit.checks.id},'preserved');
    review.preservedComparisons=sum(mask); review.maxPreservedError=max([audit.checks(mask).error]);
    rows=cell(12,1); index=0;
    for family=1:2
        for gainIndex=[1 7 13]
            for timeIndex=[1 41]
                index=index+1;
                rows{index}=struct('bPresent',r.sustained(family),'nu',r.nu(gainIndex), ...
                    'endpointGO',r.endpointGO(timeIndex),'stateError',r.median.stateError(gainIndex,family,timeIndex), ...
                    'pr',r.median.pr(gainIndex,family,timeIndex), ...
                    'deficit',r.median.deficit(gainIndex,family,timeIndex), ...
                    'observed',r.median.observed(gainIndex,family,timeIndex), ...
                    'expected',r.median.expected(gainIndex,family,timeIndex));
            end
        end
    end
    review.anchorRows=vertcat(rows{:});
    names={'stateError','pr','deficit'};
    for j=1:numel(names)
        data=r.median.(names{j}); review.medianRanges.(names{j})=[min(data,[],'all'),max(data,[],'all')];
        for family=1:2
            review.timeRangeAtFixedGain.(names{j})(family)=max(range(squeeze(data(:,family,:)),2));
        end
    end
    stage3_write_json(fullfile(cfg.manifestRoot,'GAIN_TIME_REVIEW.json'),review);
    writetable(struct2table(review.anchorRows),fullfile(cfg.resultsRoot,'gain_time','review_anchors.csv'));
end
