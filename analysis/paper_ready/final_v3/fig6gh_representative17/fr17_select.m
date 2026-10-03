function [chosen,groups,draws]=fr17_select(points,attemptID,seed)
    % Equal-probability stratified draw using positions only, never speed or RMS.
    assert(isequal(size(points),[30 2]) && numel(attemptID)==30);
    cells=split((1:30).'); groups=vertcat(cells{:});
    assert(isequal(sort(groups(:)),(1:30).'));
    stream=RandStream('mt19937ar','Seed',seed);
    draws=randi(stream,3,10,1); chosen=groups(sub2ind([10 3],(1:10).',draws));
    function leaves=split(ids)
        if numel(ids)==3, leaves={ids.'}; return; end
        ranges=max(points(ids,:),[],1)-min(points(ids,:),[],1);
        [~,axisID]=max(ranges);
        rows=sortrows([points(ids,axisID) attemptID(ids) ids],[1 2]);
        cut=3*floor(numel(ids)/6);
        leaves=[split(rows(1:cut,3));split(rows(cut+1:end,3))];
    end
end
