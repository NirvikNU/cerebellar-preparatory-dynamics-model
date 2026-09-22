function result = pe_rrr_dimension(curves)
    % Repeat x rank, no selection/averaging of folds as independent units.
    result.mean=mean(curves,1); result.se=std(curves,0,1)/sqrt(size(curves,1));
    [result.peak,result.peakRank]=max(result.mean); result.threshold=result.peak-result.se(result.peakRank);
    j=find(result.mean>=result.threshold,1); assert(~isempty(j));
    if j==1, result.rank=1;
    else, result.rank=j-1+(result.threshold-result.mean(j-1))/(result.mean(j)-result.mean(j-1)); end
end
