function s=landscape_summarize(root)
    c=landscape_paths(root); assert(~isfile(fullfile(c.land,'summary.mat')));
    s=struct('fraction',c.fractions,'values',zeros(10,3,2,6,7),'distance',zeros(10,599),'speed',zeros(10,599));
    s.metricNames={'Native maximum neural amplification','Early hand RMS (mm)','Final position deviation (mm)', ...
        'Signed peak-speed change (m/s)','Intended-target endpoint error (mm)','Endpoint-error change (mm)','Torque RMS (source units)'};
    s.classes={'Potent','Null','Random'}; s.signs=[-1 1];
    rows=cell(10,1); rootsRows=cell(10,1);
    for n=1:10
        data=load(fullfile(c.land,sprintf('network_%02d.mat',n)));
        for g=1:3
            for sign=1:2
                perTarget=zeros(8,6,7);
                for q=1:8
                    ids=data.targetIds==q & data.classes(data.directionIds)==g & data.signs==s.signs(sign);
                    perTarget(q,:,:)=mean(data.metric(ids,:,:),1);
                end
                s.values(n,g,sign,:,:)=reshape(mean(perTarget,1),1,1,1,6,7);
            end
        end
        loaded=load(fullfile(c.cache,sprintf('landscape_%02d.mat',n)),'result'); r=loaded.result;
        s.distance(n,:)=mean(r.distance,2).'; s.speed(n,:)=mean(r.speed,2).';
        s.time=r.time; s.drive=r.drive; s.scales(n)=data.scale;
        minimum=min(r.distance,[],1); final=r.distance(end,:); near=any(r.near,1);
        rows{n}=table(repmat(n,8,1),(1:8)',minimum',minimum'/data.scale,final',near', ...
            sum(isfinite(r.distance),1)'/size(r.distance,1),min(r.speed,[],1)', ...
            'VariableNames',{'network','target','minimumDistance','minimumNormalizedDistance','finalDistance','everWithinOnePercent','stableRootCoverage','minimumFieldSpeed'});
        count=cellfun(@(x)size(x,2),r.roots); stable=cellfun(@(p,k)sum(p< -1e-7 & ~k),r.poles,r.kinks);
        unstable=cellfun(@(p)sum(p>1e-7),r.poles);
        attempts=vertcat(r.attempts{:});
        rootsRows{n}=table(n,min(count),max(count),min(stable),max(stable),max(unstable), ...
            size(attempts,1),nnz(attempts(:,1)==0),max(attempts(attempts(:,1)==1,2)), ...
            nnz(r.links(:,4)==0),nnz(r.links(:,4)==1 & r.links(:,5)==0),nnz(r.links(:,6)==0), ...
            'VariableNames',{'network','minRoots','maxRoots','minStable','maxStable','maxUnstable','attempts','failedAttempts','maxConvergedResidual','unmatchedForwardLinks','nonreciprocalLinks','activeSetLinkGaps'});
    end
    s.targetLandscape=vertcat(rows{:}); s.rootSummary=vertcat(rootsRows{:});
    v=reshape(s.values,10,[]); valid=all(isfinite(v),1); s.validColumns=valid;
    s.bootstrap=bootstrap_network_median(v(:,valid),10000,c.bootstrapSeed);
    s.distanceCoverage=mean(isfinite(s.distance),1);
    complete=all(isfinite(s.distance),1); s.distanceMedian=nan(1,599); s.distanceSE=s.distanceMedian;
    if any(complete)
        boot=bootstrap_network_median(s.distance(:,complete),10000,c.bootstrapSeed);
        s.distanceMedian(complete)=boot.median; s.distanceSE(complete)=boot.standardError;
    end
    s.speedBootstrap=bootstrap_network_median(s.speed,10000,c.bootstrapSeed);
    save(fullfile(c.land,'summary.mat'),'s');
    writetable(s.targetLandscape,fullfile(c.land,'landscape_targets.csv'));
    writetable(s.rootSummary,fullfile(c.land,'equilibrium_search.csv'));
    medianAll=nan(1,size(v,2)); seAll=medianAll; medianAll(valid)=s.bootstrap.median; seAll(valid)=s.bootstrap.standardError;
    s.median=reshape(medianAll,3,2,6,7); s.se=reshape(seAll,3,2,6,7);
    save(fullfile(c.land,'summary.mat'),'s');
    rows=cell(3*2*6*7,1); k=0;
    for metric=1:7
      for a=1:6
        for sign=1:2
          for g=1:3
        k=k+1; rows{k}=table(string(s.metricNames{metric}),string(s.classes{g}),s.signs(sign),c.fractions(a), ...
            s.median(g,sign,a,metric),s.se(g,sign,a,metric), ...
            'VariableNames',{'metric','directionClass','sign','fraction','median','bootstrapSE'});
          end
        end
      end
    end
    writetable(vertcat(rows{:}),fullfile(c.land,'sensitivity_summary.csv'));
    landscape_json(fullfile(c.manifest,'SUMMARY.json'),struct('rootSummary',table2struct(s.rootSummary), ...
        'targetLandscape',table2struct(s.targetLandscape),'fraction',s.fraction,'metricNames',{s.metricNames},'median',s.median,'se',s.se));
end
