function values=landscape_metrics(m,out,base,targetIds,desired)
    count=numel(targetIds); values=zeros(count,7);
    for j=1:count
        q=targetIds(j); speed=hypot(out.hand(:,2,j),out.hand(:,4,j));
        baselineSpeed=hypot(base.hand(:,2,q),base.hand(:,4,q));
        mo=find(baselineSpeed>=.2*max(baselineSpeed),1); ii=mo+(0:200);
        assert(ii(end)<=size(base.hand,1));
        delta=out.hand(ii,[1 3],j)-base.hand(ii,[1 3],q);
        final=out.hand(end,[1 3],j); original=base.hand(end,[1 3],q);
        values(j,:)=[out.maxAmplification(j),1000*sqrt(mean(sum(delta.^2,2))), ...
            1000*norm(final-original),max(speed)-max(baselineSpeed), ...
            1000*norm(final-desired(q,:)),1000*(norm(final-desired(q,:))-norm(original-desired(q,:))), ...
            sqrt(mean((out.torque(:,:,j)-base.torque(:,:,q)).^2,'all'))];
    end
    assert(m.samplingDt==.001 && all(isfinite(values),'all'));
end
