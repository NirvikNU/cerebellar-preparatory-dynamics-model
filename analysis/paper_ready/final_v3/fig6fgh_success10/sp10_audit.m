function r=sp10_audit(root,d)
    % Separate scalar, piecewise segment geometry and two-pass success sorting.
    r=struct('status','PASS','trials',0,'maxPathRMSError',0,'maxSummaryError',0,'savedMOChecks',0);
    independentScores=zeros(10,8);
    for p=1:2
        for n=1:10
            raw=sp10_load(root,n,p); xy=raw.hand(:,[1 3],:)-raw.hand(1,[1 3],1);
            pathRMS=zeros(240,1); ends=zeros(240,1); success=false(240,1); peaks=zeros(240,2);
            speed=raw.speed;
            for tr=1:240
                q=ceil(tr/30); last=600;
                for t=1:600
                    if hypot(xy(t,1,tr)-d.targetXY(q,1),xy(t,2,tr)-d.targetXY(q,2))<=.015
                        last=t; success(tr)=true; break
                    end
                end
                ends(tr)=last;
                savedOnset=find(raw.speed(:,tr)>=.2*max(raw.speed(:,tr)),1)-1;
                assert(savedOnset==raw.moMs(tr)); r.savedMOChecks=r.savedMOChecks+1;
                first=raw.moMs(tr)+1; assert(first<=last); ss=0;
                for t=first:last
                    ss=ss+distanceSquared(xy(t,:,tr),d.targetXY(q,:));
                end
                pathRMS(tr)=sqrt(ss/(last-first+1));
                [~,peak]=max(speed(1:last,tr)); peaks(tr,:)=xy(peak,:,tr);
                xy(last+1:end,:,tr)=NaN; speed(last+1:end,tr)=NaN;
            end
            order=zeros(30,8);
            for q=1:8
                ids=((q-1)*30+(1:30)).'; good=ids(success(ids)); bad=ids(~success(ids));
                a=sortrows([pathRMS(good) good],[1 2]); b=sortrows([pathRMS(bad) bad],[1 2]);
                order(:,q)=[a(:,2);b(:,2)];
                if p==1, independentScores(n,q)=sum(pathRMS(order(1:5,q)))/5; end
            end
            rows=d.allTrialRankings(d.allTrialRankings(:,1)==n & d.allTrialRankings(:,2)==p,:);
            assert(isequal(rows(:,6),order(:)));
            assert(isequal(rows(:,7),double(success(rows(:,6)))) && isequal(rows(:,11),ends(rows(:,6))));
            assert(isequal(rows(:,9),raw.moMs(rows(:,6))));
            endMs=ends-1; endMs(~success)=600; assert(isequal(rows(:,10),endMs(rows(:,6))));
            err=max(abs(rows(:,8)-pathRMS(rows(:,6)))); r.maxPathRMSError=max(r.maxPathRMSError,err);
            r.trials=r.trials+240;
            if n==d.selectedNetwork
                c=d.condition{p}; assert(isequaln(xy,c.xy) && isequaln(speed,c.speed));
                assert(isequal(peaks,c.peakXY) && isequal(order,c.order));
                for q=1:8
                    ids=(q-1)*30+(1:30); means=nan(600,2); med=nan(600,1);
                    for t=1:600
                        active=ids(ends(ids)>=t);
                        if ~isempty(active)
                            means(t,:)=sum(xy(t,:,active),3)/numel(active);
                            v=sort(speed(t,active)); count=numel(v);
                            med(t)=(v(floor((count+1)/2))+v(ceil((count+1)/2)))/2;
                        end
                    end
                    r.maxSummaryError=max(r.maxSummaryError,max(abs(means-c.meanXY(:,:,q)),[],'all','omitnan'));
                    last=find(isfinite(med),1,'last'); sm=nan(600,1); sm(1:last)=smoothdata(med(1:last),'gaussian',50);
                    assert(isequaln(sm,c.medianSpeed(:,q)));
                    a=sort(peaks(ids,:),1); center=(a(15,:)+a(16,:))/2;
                    distances=100*hypot(peaks(ids,1)-center(1),peaks(ids,2)-center(2));
                    assert(max(abs(distances-c.distanceCM(:,q)))<1e-12);
                    assert(c.successCount(q)==sum(success(ids)));
                end
                % Poison every discarded sample, then rerun display-only computation.
                poison=raw;
                for tr=1:240
                    poison.hand(ends(tr)+1:end,:,tr)=1e100;
                    poison.speed(ends(tr)+1:end,tr)=1e100;
                end
                check=sp10_measure(poison,d.targetXY); assert(isequaln(c,check));
            end
        end
    end
    assert(r.maxPathRMSError<1e-14 && r.maxSummaryError<1e-14);
    rank=sortrows([sum(independentScores,2)/8 (1:10).'],[1 2]);
    assert(isequal(rank(:,2),d.networkRanking(:,1)) && rank(1,2)==d.selectedNetwork);
    assert(max(abs(independentScores-d.targetScores5),[],'all')<1e-14);
    ci=d.condition{1}; cb=d.condition{2}; eligible=find(ci.successCount>=10 & cb.successCount>=10);
    if isempty(eligible)
        joint=min(ci.successCount,cb.successCount); eligible=find(joint==max(joint));
    end
    qscore=zeros(numel(eligible),1);
    for j=1:numel(eligible), qscore(j)=sum(ci.pathRMS(ci.order(1:10,eligible(j))))/10; end
    targets=sortrows([qscore eligible(:)],[1 2]); assert(targets(1,2)==d.selectedTarget);
    r.networkSelectionIntactOnly=true; r.targetBlockEligibilityOnly=true;
    r.postEndSentinelPassed=true; r.all30SummariesPassed=true; r.testFixtures=fixtures();
end

function d2=distanceSquared(point,target)
    along=point(1)*target(1)+point(2)*target(2); length2=target(1)^2+target(2)^2;
    if along<0
        d2=point(1)^2+point(2)^2;
    elseif along>length2
        d2=(point(1)-target(1))^2+(point(2)-target(2))^2;
    else
        d2=(point(1)*target(2)-point(2)*target(1))^2/length2;
    end
end

function count=fixtures()
    assert(distanceSquared([-1 2],[1 0])==5);
    assert(distanceSquared([2 2],[1 0])==5);
    assert(distanceSquared([.5 2],[1 0])==4);
    [q,~,rule]=sp10_choose_target([9 10 11 0 0 0 0 0],[30 10 11 0 0 0 0 0],[0 2 2 0 0 0 0 0]);
    assert(q==2 && startsWith(rule,'primary'));
    [q,~,rule]=sp10_choose_target([9 10 7 0 0 0 0 0],[8 8 9 0 0 0 0 0],[2 1 0 0 0 0 0 0]);
    assert(q==2 && startsWith(rule,'fallback'));
    % Exact score ties use ID; unsuccessful low-RMS trials cannot outrank successes.
    a=sortrows([1 .001 1;0 .5 2;0 .5 3],[1 2 3]); assert(isequal(a(:,3),[2;3;1]));
    count=6;
end
