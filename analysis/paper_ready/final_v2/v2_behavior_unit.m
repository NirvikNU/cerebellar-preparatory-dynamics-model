function receipt=v2_behavior_unit(root)
    cfg=v2_paths(root); path=fullfile(cfg.dest,'behavior_unit.json'); assert(~isfile(path));
    a.movement.peak=zeros(1,240); b=a;
    a.peakPosition=[(1:240).' 2*(1:240).']; b.peakPosition=a.peakPosition+1000;
    for q=1:8
        ids=(q-1)*30+(1:30); a.movement.peak(ids)=100*q+(1:30); b.movement.peak(ids)=100*q+(30:-1:1);
    end
    result=v2_behavior(a,b);
    for q=1:8
        assert(isequal(result.indices{q,1},(q-1)*30+(30:-1:1)) && isequal(result.indices{q,2},(q-1)*30+(1:30)));
    end
    expected=sqrt(5)*7.5; assert(max(abs(result.network-expected))<1e-12 && all(result.count==30));
    b.movement.peak(121:end)=0; insufficient=v2_behavior(a,b);
    assert(numel(insufficient.validTargets)==4 && all(isnan(insufficient.network)));
    receipt=struct('status','PASS','exactGreedyPairs',240,'coordinateMedianMeanDistanceError',max(abs(result.network-expected)), ...
        'insufficientCoverageRetainedUndefined',true,'syntheticOnly',true);
    paper_json(path,receipt);
end
