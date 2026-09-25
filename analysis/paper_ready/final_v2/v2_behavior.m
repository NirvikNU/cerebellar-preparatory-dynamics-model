function b=v2_behavior(intact,block)
    % Faithful active empirical greedy matcher: denominator is Block speed.
    b.indices=cell(8,2); b.targetDispersion=nan(8,2); b.unmatchedDispersion=nan(8,2);
    b.count=zeros(8,1); b.cutoff=.05; cases={intact,block};
    for q=1:8
        ids=(q-1)*30+(1:30); vi=intact.movement.peak(ids).'; vb=block.movement.peak(ids).';
        errors=abs(vi-vb.')./abs(vb.'); [sorted,order]=sort(errors(:),'ascend'); order=order(sorted<=.05);
        usedI=false(30,1); usedB=usedI; matchedI=[]; matchedB=[];
        for j=order.'
            [i,k]=ind2sub([30 30],j);
            if usedI(i)||usedB(k), continue; end
            matchedI(end+1)=ids(i); matchedB(end+1)=ids(k); %#ok<AGROW>
            usedI(i)=true; usedB(k)=true;
            if all(usedI)||all(usedB), break; end
        end
        b.indices(q,:)={matchedI,matchedB}; b.count(q)=numel(matchedI);
        for p=1:2
            allPositions=cases{p}.peakPosition(ids,:);
            b.unmatchedDispersion(q,p)=mean(vecnorm(allPositions-median(allPositions,1),2,2));
            matched=cases{p}.peakPosition(b.indices{q,p},:);
            if b.count(q)>=5, b.targetDispersion(q,p)=mean(vecnorm(matched-median(matched,1),2,2)); end
        end
    end
    b.validTargets=find(b.count>=5); b.network=nan(1,2);
    if numel(b.validTargets)>=5, b.network=mean(b.targetDispersion(b.validTargets,:),1); end
    b.unmatchedNetwork=mean(b.unmatchedDispersion,1);
    b.rule='Within-target greedy abs(vI-vB)/abs(vB)<=.05; >=5 pairs/target, >=5 targets/network; no resampling of already balanced model trials';
end
