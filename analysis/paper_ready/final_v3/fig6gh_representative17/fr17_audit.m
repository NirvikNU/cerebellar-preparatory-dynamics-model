function r=fr17_audit(root,d,old,dest,plots,figuresOnly)
    % Independent raw-hand/event arithmetic and source-object audit.
    q=d.selectedTarget; assert(q==6 && d.selectedNetwork==8);
    r=struct('status','PASS','maxPeakError',0,'maxMedianError',0,'maxGaussianError',0);
    if ~figuresOnly
        rows=readmatrix(fullfile(dest,'Fig6h_all30_inset.csv'));
        frozen=readmatrix(fullfile(dest,'selection_frozen_before_speed.csv'));
        medRows=readmatrix(fullfile(dest,'Fig6g_median_support.csv'));
        for p=1:2
            c=d.condition{p}; prior=old.condition{p}; ids=(q-1)*30+(1:30); chosen=d.displayIDs{p};
            for field={'hand','xy','phaseXY','alignedSpeed','order','attemptID','seed','pathRMS','moMs','endMs','peakXY','peakSpeed','distanceCM','medianPeakXY'}
                assert(isequaln(c.(field{1}),prior.(field{1})));
            end
            assert(numel(unique(chosen))==10 && all(ismember(chosen,ids)));
            % Independently build the spatial partition with an iterative queue.
            queue={(1:30).'}; leaves={};
            while ~isempty(queue)
                ix=queue{1}; queue(1)=[];
                if numel(ix)==3
                    leaves{end+1}=ix.'; %#ok<AGROW>
                else
                    pts=c.peakXY(ids(ix),:); span=max(pts)-min(pts); axisID=1+(span(2)>span(1));
                    ranked=sortrows([pts(:,axisID) c.attemptID(ids(ix)) ix],[1 2]); nLeft=3*floor(numel(ix)/6);
                    queue=[{ranked(1:nLeft,3),ranked(nLeft+1:end,3)} queue]; %#ok<AGROW>
                end
            end
            groups=vertcat(leaves{:}); assert(isequal(groups,d.groups{p}));
            random=RandStream('mt19937ar','Seed',d.selectionSeeds(p));
            for k=1:10
                pick=randi(random,3); assert(pick==d.draws{p}(k));
                assert(chosen(k)==ids(groups(k,pick)));
            end
            assert(isequal(frozen(frozen(:,3)==p,5),chosen));
            pts=zeros(30,2); aligned=nan(600,10);
            for j=1:30
                tr=ids(j); hand=c.hand(:,:,tr); xy=hand(:,[1 3])-hand(1,[1 3]); speed=hypot(hand(:,2),hand(:,4));
                first=find(speed>=.2*max(speed),1); last=find(sum((xy-d.targetXY(q,:)).^2,2)<=.015^2,1);
                assert(first==c.moMs(tr)+1 && last==c.endMs(tr)+1 && last<=600);
                [peak,at]=max(speed(1:last)); pts(j,:)=100*xy(at,:);
                r.maxPeakError=max(r.maxPeakError,abs(peak-c.peakSpeed(tr)));
                assert(max(abs(pts(j,:)-100*c.peakXY(tr,:)))<1e-12 && at==c.peakMs(tr)+1);
                rank=find(chosen==tr);
                if ~isempty(rank), aligned(1:last-first+1,rank)=speed(first:last); end
            end
            assert(isequal(isnan(aligned),isnan(c.alignedSpeed(:,chosen))) && max(abs(aligned-c.alignedSpeed(:,chosen)),[],'all','omitnan')<1e-14);
            counts=sum(isfinite(aligned),2); med=nan(600,1);
            for t=1:600
                a=sort(aligned(t,isfinite(aligned(t,:)))); n=numel(a);
                if n>0, med(t)=(a(floor((n+1)/2))+a(ceil((n+1)/2)))/2; end
            end
            assert(isequal(counts,c.nActive(:,q)) && max(counts)==10);
            r.maxMedianError=max(r.maxMedianError,max(abs(med-c.rawMedian(:,q)),[],'omitnan'));
            last=find(counts>0,1,'last'); cut=find(counts>=5,1,'last');
            assert(c.cutoffMs(q)==cut-1 && c.supportEndMs(q)==last-1 && last>cut);
            operator=smoothdata(eye(151),1,'gaussian',50); kernel=operator(76,:); offset=find(kernel>0)-76; weight=kernel(kernel>0);
            expected=zeros(last,1);
            for t=1:last
                loc=t+offset; keep=loc>=1 & loc<=last;
                expected(t)=sum(weight(keep).*med(loc(keep)).')/sum(weight(keep));
            end
            r.maxGaussianError=max(r.maxGaussianError,max(abs(expected-c.fullSmoothMedian(1:last,q))));
            assert(isequal(c.medianSpeed(1:cut,q),c.fullSmoothMedian(1:cut,q)) && all(isnan(c.medianSpeed(cut+1:end,q))));
            assert(all(isnan(c.fullSmoothMedian(last+1:end,q))));
            ordered=sort(pts,1); center=(ordered(15,:)+ordered(16,:))/2; dist=sqrt(sum((pts-center).^2,2));
            part=rows(rows(:,3)==p,:); assert(size(part,1)==30 && max(abs(part(:,9:10)-pts),[],'all')<1e-12 && max(abs(part(:,11)-dist))<1e-12);
            counts=zeros(numel(d.histEdgesCM)-1,1);
            for j=1:30
                bin=find(dist(j)>=d.histEdgesCM(1:end-1) & dist(j)<d.histEdgesCM(2:end),1);
                if isempty(bin) && dist(j)==d.histEdgesCM(end), bin=numel(counts); end
                assert(~isempty(bin)); counts(bin)=counts(bin)+1;
            end
            assert(isequal(counts,d.histCounts(:,p)) && sum(counts)==30);
            part=medRows(medRows(:,1)==p,:); assert(isequaln(part(:,3:6),[c.nActive(:,q) c.rawMedian(:,q) c.fullSmoothMedian(:,q) c.medianSpeed(:,q)]));
        end
        assert(r.maxPeakError<1e-14 && r.maxMedianError<1e-14 && r.maxGaussianError<1e-12);
        % All-30 h scientific display source is identical to the previous target6.
        priorRows=readmatrix(fullfile(root,'results/paper_ready/final_v3/fig6h_diffuse16/Fig6h_all30_inset.csv'));
        assert(isequal(rows(:,[1:11 13]),priorRows(:,[1:11 13])));
        r.histogramAll30Unchanged=true; r.uniformInclusionWithinStrata=true; return
    end
    r.objects=0; r.reopened=0;
    for panel='g':'h'
        f=openfig(fullfile(plots,'fig',['Fig6' panel '.fig']),'invisible'); closer=onCleanup(@()close(f));
        count=struct('selectedRawSpeed',0,'selected10MedianSpeed',0,'trajectory',0,'selectedUnsmoothedPeak',0,'histogramBin',0,'idealPath',0);
        for h=findall(f,'-property','UserData').'
            u=h.UserData; if ~isstruct(u)||~isfield(u,'kind'), continue; end
            c=d.condition{u.condition}; color=d.conditionColors(u.condition,:); chosen=d.displayIDs{u.condition}; assert(u.target==q);
            switch u.kind
                case 'selectedRawSpeed'
                    assert(ismember(u.trials,chosen) && isequaln(u.y,c.alignedSpeed(:,u.trials)));
                case 'selected10MedianSpeed'
                    assert(isequaln(u.y,c.medianSpeed(:,q)));
                case 'trajectory'
                    assert(ismember(u.trials,chosen)); xy=100*c.xy(:,:,u.trials);
                    assert(isequaln(h.XData,[xy(:,1) xy(:,1)]) && isequaln(h.YData,[xy(:,2) xy(:,2)]) && isequal(h.EdgeColor,color));
                case 'selectedUnsmoothedPeak'
                    assert(isequal(u.trials,chosen) && isequal(h.CData,color) && strcmp(h.MarkerFaceColor,'flat'));
                    xy=100*c.peakXY(chosen,:); assert(isequal(h.XData(:),xy(:,1)) && isequal(h.YData(:),xy(:,2)));
                case 'histogramBin'
                    assert(u.count==d.histCounts(u.bin,u.condition) && isequal(h.FaceColor,color) && isequal(h.EdgeColor,color));
                    e=[cosd(45) sind(45)]; a=.18*[cosd(-45) sind(-45)];
                    xy=[u.rangeCM(1) u.rangeCM(2) u.rangeCM(2) u.rangeCM(1)].'*e+[0 0 u.count u.count].'*a;
                    assert(isequal(h.XData(:),xy(:,1)) && isequal(h.YData(:),xy(:,2)));
                case 'idealPath'
                    assert(strcmp(h.LineStyle,'--') && isequal(h.Color,[0 0 0]));
                    assert(isequal(h.XData,100*[0 d.targetXY(q,1)]) && isequal(h.YData,100*[0 d.targetXY(q,2)]));
            end
            if ismember(u.kind,{'selectedRawSpeed','selected10MedianSpeed'})
                assert(isequal(h.Color,color) && isequaln(h.YData(:),u.y(:)) && isequal(h.XData(:),d.timesMs));
            end
            if ismember(u.kind,{'selectedRawSpeed','selected10MedianSpeed','trajectory'}), assert(strcmp(h.LineStyle,'-')); end
            count.(u.kind)=count.(u.kind)+1; r.objects=r.objects+1;
        end
        if panel=='g'
            assert(count.selectedRawSpeed==20 && count.selected10MedianSpeed==2);
            assert(isscalar(findall(f,'Type','legend')));
        else
            assert(count.trajectory==20 && count.selectedUnsmoothedPeak==2 && count.histogramBin==2*size(d.histCounts,1) && count.idealPath==1);
            assert(numel(findall(f,'Type','axes'))==3);
        end
        r.reopened=r.reopened+1; clear closer
    end
    r.sameTenGH=true; r.solidConditionColors=true; r.histogramAll30=true;
end
