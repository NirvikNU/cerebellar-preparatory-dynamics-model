function raw=mv09_load(root,n,condition)
    % Direct saved-array reader; never constructs or simulates a model.
    if condition==1
        rel=sprintf('results/paper_ready/cache/stabilization_eta/raw_n%02d_e5_p1.mat',n);
        policy=1;
    else
        assert(condition==2);
        rel=sprintf('results/paper_ready/cache/final_v2/raw_n%02d_v2_p4.mat',n); policy=4;
    end
    file=fullfile(root,rel); assert(isfile(file));
    assert(h5read(file,'/raw/network')==n && h5read(file,'/raw/condition')==policy);
    assert(h5read(file,'/raw/eta')==0);
    raw=struct('path',rel,'hand',h5read(file,'/raw/move/hand'), ...
        'speed',h5read(file,'/raw/move/speed'),'network',n,'condition',condition);
    assert(isequal(size(raw.hand),[600 4 240]) && isequal(size(raw.speed),[600 240]));
    assert(all(isfinite(raw.hand),'all') && all(isfinite(raw.speed),'all'));
    assert(max(abs(raw.speed-squeeze(hypot(raw.hand(:,2,:),raw.hand(:,4,:)))),[],'all')<1e-14);
    if condition==2
        pair=h5read(file,'/raw/pair'); assert(isequal(pair(:),[.1;.1]));
        assert(h5read(file,'/raw/alpha')==.5 && h5read(file,'/raw/betaNormalized')==1.25);
    end
end
