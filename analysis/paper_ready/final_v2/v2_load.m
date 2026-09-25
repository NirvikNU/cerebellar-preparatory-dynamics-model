function [prep,move,prior]=v2_load(cfg,n,v,p)
    selection=jsondecode(fileread(fullfile(cfg.dest,'geometry_selection.json')));
    assert(strcmp(selection.status,'FROZEN')); prior=[];
    if v2_reuse(selection,p)
        op=1+(p==4); [prep,move]=ns_load(cfg.previous,n,1,v,op);
        s=load(fullfile(cfg.previous.raw,sprintf('analysis_n%02d_e1_v%d_p%d.mat',n,v,op)),'result'); prior=s.result;
    else
        s=load(fullfile(cfg.raw,sprintf('raw_n%02d_v%d_p%d.mat',n,v,p)),'raw');
        assert(s.raw.eta==0 && s.raw.network==n && s.raw.condition==p && isequal(s.raw.pair,cfg.pairs(v,:)));
        assert(s.raw.alpha==selection.alpha && s.raw.betaNormalized==selection.betaNormalized);
        prep=s.raw.prep; move=s.raw.move;
    end
end
