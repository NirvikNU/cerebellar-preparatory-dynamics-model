function c=sp10_measure(raw,targets)
    % Display-only end mask; ranking interval begins at frozen kinematic MO.
    xy=raw.hand(:,[1 3],:)-raw.hand(1,[1 3],1); times=(0:599).';
    c=struct('xy',xy,'speed',raw.speed,'meanXY',nan(600,2,8), ...
        'score5',zeros(1,8),'score10',zeros(1,8),'successCount',zeros(1,8), ...
        'pathRMS',zeros(240,1),'endIndex',zeros(240,1),'endMs',zeros(240,1), ...
        'moMs',raw.moMs,'entered',false(240,1),'order',zeros(30,8), ...
        'smoothSpeed',nan(600,240),'medianSpeed',nan(600,8), ...
        'peakMs',zeros(240,1),'peakSpeed',zeros(240,1),'peakXY',zeros(240,2),'distanceCM',zeros(30,8));
    for tr=1:240
        q=ceil(tr/30); stop=find(sum((xy(:,:,tr)-targets(q,:)).^2,2)<=.015^2,1);
        if isempty(stop), stop=600; c.endMs(tr)=600;
        else, c.entered(tr)=true; c.endMs(tr)=times(stop); end
        onset=raw.moMs(tr)+1;
        assert(onset<=stop,'Undefined ranking interval: MO after first entry.');
        path=xy(onset:stop,:,tr); target=targets(q,:);
        projection=max(0,min(1,(path*target.')/sum(target.^2)));
        residual=path-projection.*target;
        c.pathRMS(tr)=sqrt(mean(sum(residual.^2,2)));
        c.endIndex(tr)=stop; c.xy(stop+1:end,:,tr)=NaN; c.speed(stop+1:end,tr)=NaN;
        c.smoothSpeed(1:stop,tr)=smoothdata(c.speed(1:stop,tr),'gaussian',50);
        [c.peakSpeed(tr),ix]=max(c.speed(1:stop,tr));
        c.peakMs(tr)=times(ix); c.peakXY(tr,:)=xy(ix,:,tr);
    end
    for q=1:8
        ids=(q-1)*30+(1:30);
        ranks=sortrows([~c.entered(ids) c.pathRMS(ids) ids.'],[1 2 3]); c.order(:,q)=ranks(:,3);
        c.score5(q)=mean(c.pathRMS(c.order(1:5,q))); c.score10(q)=mean(c.pathRMS(c.order(1:10,q)));
        c.successCount(q)=sum(c.entered(ids)); c.meanXY(:,:,q)=mean(c.xy(:,:,ids),3,'omitnan');
        med=median(c.speed(:,ids),2,'omitnan'); last=find(isfinite(med),1,'last');
        c.medianSpeed(1:last,q)=smoothdata(med(1:last),'gaussian',50);
        points=c.peakXY(ids,:); c.distanceCM(:,q)=100*sqrt(sum((points-median(points,1)).^2,2));
    end
end
