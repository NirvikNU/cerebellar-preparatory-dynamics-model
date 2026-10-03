function [raw,smoothed,nActive,cutoffMs,supportEndMs,displayed]=fd14_median(aligned)
    assert(size(aligned,2)==30 && all(isfinite(aligned(1,:))));
    nActive=sum(isfinite(aligned),2); raw=median(aligned,2,'omitnan');
    last=find(nActive>0,1,'last'); cutoff=find(nActive>=15,1,'last');
    assert(all(nActive(1:last)>0) && all(diff(nActive)<=0) && cutoff<=last);
    smoothed=nan(size(raw)); smoothed(1:last)=smoothdata(raw(1:last),'gaussian',50);
    displayed=smoothed; displayed(cutoff+1:end)=NaN;
    cutoffMs=cutoff-1; supportEndMs=last-1;
end
