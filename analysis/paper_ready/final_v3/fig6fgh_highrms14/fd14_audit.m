function a=fd14_audit(d,dest)
    a=struct('status','PASS','successes',0,'maxPathError',0,'maxPhaseError',0,'maxGaussianError',0,'prematureCutoffEndpointDifference',zeros(1,2));
    assert(d.selectedNetwork==8); scores=nan(8,1);
    for p=1:2
        c=d.condition{p};
        for q=1:8
            ids=(q-1)*30+(1:c.counts(q)); independent=zeros(numel(ids),1);
            phase=zeros(101,2,numel(ids));
            for j=1:numel(ids)
                tr=ids(j); hand=c.hand(:,:,tr); xy=hand(:,[1 3])-hand(1,[1 3]); v=hypot(hand(:,2),hand(:,4));
                last=find(hypot(xy(:,1)-d.targetXY(q,1),xy(:,2)-d.targetXY(q,2))<=.015,1);
                first=find(v>=max(v)/5,1); assert(c.moMs(tr)==first-1 && c.endMs(tr)==last-1);
                ss=0; target=d.targetXY(q,:);
                for t=first:last
                    dotValue=dot(xy(t,:),target); norm2=dot(target,target);
                    if dotValue<0
                        dist2=sum(xy(t,:).^2);
                    elseif dotValue>norm2
                        dist2=sum((xy(t,:)-target).^2);
                    else
                        dist2=(xy(t,1)*target(2)-xy(t,2)*target(1))^2/norm2;
                    end
                    ss=ss+dist2;
                end
                independent(j)=sqrt(ss/(last-first+1));
                aligned=nan(600,1); aligned(1:last-first+1)=v(first:last); assert(isequaln(aligned,c.alignedSpeed(:,tr)));
                assert(isequal(c.xy(1:last,:,tr),xy(1:last,:)) && all(isnan(c.xy(last+1:end,:,tr)),'all'));
                [peak,ix]=max(v(1:last)); assert(c.peakSpeed(tr)==peak && c.peakMs(tr)==ix-1 && isequal(c.peakXY(tr,:),xy(ix,:)));
                for k=0:100
                    pos=first+(last-first)*k/100; lo=floor(pos); hi=ceil(pos); w=pos-lo;
                    phase(k+1,:,j)=(1-w)*xy(lo,:)+w*xy(hi,:);
                end
                a.maxPhaseError=max(a.maxPhaseError,max(abs(phase(:,:,j)-c.phaseXY(:,:,tr)),[],'all'));
            end
            a.maxPathError=max(a.maxPathError,max(abs(independent-c.pathRMS(ids))));
            rank=sortrows([independent c.attemptID(ids) ids.'],[-1 2]); assert(isequal(rank(:,3),c.order(1:numel(ids),q)));
            low=sortrows([independent c.attemptID(ids) ids.'],[1 2]); assert(isequal(low(:,3),c.lowOrder(1:numel(ids),q)));
            chosen=c.order(1:4,q)-(q-1)*30;
            assert(max(abs(sum(phase(:,:,chosen),3)/4-c.meanXY(:,:,q)),[],'all')<1e-13);
            if p==1 && d.eligible(q), scores(q)=sum(independent(c.lowOrder(1:10,q)-(q-1)*30))/10; end
            a.successes=a.successes+numel(ids);
        end
        q=d.selectedTarget; ids=(q-1)*30+(1:30); aligned=c.alignedSpeed(:,ids); med=nan(600,1); counts=zeros(600,1);
        for t=1:600
            active=sort(aligned(t,isfinite(aligned(t,:)))); count=numel(active); counts(t)=count;
            if count>0, med(t)=(active(floor((count+1)/2))+active(ceil((count+1)/2)))/2; end
        end
        assert(isequal(counts,c.nActive(:,q)) && isequaln(med,c.rawMedian(:,q)));
        last=find(counts>0,1,'last'); cutoff=find(counts>=15,1,'last');
        assert(c.cutoffMs(q)==cutoff-1 && c.supportEndMs(q)==last-1 && last>cutoff);
        % Recover the established fixed Gaussian kernel from an interior impulse.
        % Independently truncate/renormalize it at TRUE data boundaries, never at the display cutoff.
        operator=smoothdata(eye(151),1,'gaussian',50); kernel=operator(76,:); offsets=find(kernel>0)-76; weights=kernel(kernel>0);
        expected=zeros(last,1);
        for t=1:last
            index=t+offsets; valid=index>=1 & index<=last; w=weights(valid);
            expected(t)=sum(w.*med(index(valid)).')/sum(w);
        end
        a.maxGaussianError=max(a.maxGaussianError,max(abs(expected-c.fullSmoothMedian(1:last,q))));
        assert(all(isnan(c.fullSmoothMedian(last+1:end,q))) && all(isnan(c.medianSpeed(cutoff+1:end,q))));
        assert(isequal(c.medianSpeed(1:cutoff,q),c.fullSmoothMedian(1:cutoff,q)));
        bad=smoothdata(med(1:cutoff),'gaussian',50); a.prematureCutoffEndpointDifference(p)=c.medianSpeed(cutoff,q)-bad(end);
        constant=smoothdata(ones(last,1),'gaussian',50); assert(max(abs(constant-1))<1e-14);
        sorted=sort(c.peakXY(ids,:),1); center=(sorted(15,:)+sorted(16,:))/2;
        distances=100*hypot(c.peakXY(ids,1)-center(1),c.peakXY(ids,2)-center(2));
        assert(max(abs(distances-c.distanceCM(:,q)))<1e-12);
    end
    eligible=find(all(d.attempt30<=500,2)); rank=sortrows([scores(eligible) eligible],[1 2]);
    assert(isequal(eligible,find(d.eligible)) && rank(1,2)==d.selectedTarget && max(abs(scores-d.targetScores),[],'omitnan')<1e-14);
    assert(a.successes==453 && a.maxPathError<1e-14 && a.maxPhaseError<1e-13 && a.maxGaussianError<1e-12);
    table=readmatrix(fullfile(dest,'Fig6g_median_support.csv'));
    for p=1:2
        c=d.condition{p}; q=d.selectedTarget; rows=table(table(:,1)==p,:);
        assert(isequal(rows(:,3),c.nActive(:,q)) && isequaln(rows(:,4:6),[c.rawMedian(:,q) c.fullSmoothMedian(:,q) c.medianSpeed(:,q)]));
    end
    prior=load(fullfile(fileparts(fileparts(dest)),'cache','fig6fgh_final13','display_sources.mat'),'d');
    assert(isequal(d.eligible,prior.d.eligible) && isequaln(d.targetScores,prior.d.targetScores) && d.selectedTarget==prior.d.selectedTarget);
    for p=1:2
        c=d.condition{p}; old=prior.d.condition{p};
        for field={'xy','hand','phaseXY','alignedSpeed','attemptID','seed','pathRMS','moMs','endMs','peakXY','peakSpeed','peakMs','distanceCM','medianPeakXY','nActive','rawMedian','fullSmoothMedian','medianSpeed','cutoffMs','supportEndMs'}
            assert(isequaln(c.(field{1}),old.(field{1})));
        end
        assert(isequaln(c.lowOrder,old.order));
        values=c.distanceCM(:,d.selectedTarget); counts=zeros(12,1);
        for j=1:30
            bin=find(values(j)>=d.histEdgesCM(1:end-1) & values(j)<d.histEdgesCM(2:end),1);
            if values(j)==d.histEdgesCM(end), bin=12; end
            assert(~isempty(bin)); counts(bin)=counts(bin)+1;
        end
        assert(isequal(counts,d.histCounts(:,p)) && sum(counts)==30);
    end
    assert(isequaln(readmatrix(fullfile(dest,'Fig6g_median_support.csv')),readmatrix(fullfile(fileparts(dest),'fig6fgh_final13','Fig6g_median_support.csv'))));
    a.all30SummariesBitIdentical=true; a.histogramCounts30Each=true; a.descendingDisplayAscendingTargetScore=true;
    a.eligibleTargets=eligible; a.fullSupportBeforeCutoff=true; a.noZeroPadding=true; a.thinTracesRaw=true; a.sameFourMean=true;
end
