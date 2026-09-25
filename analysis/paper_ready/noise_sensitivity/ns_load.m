function [prep,move]=ns_load(cfg,n,e,v,p)
    if v==2
        [prep,move]=eta_load_case(cfg.old,n,cfg.oldEta(e),p);
    else
        s=load(fullfile(cfg.raw,sprintf('raw_n%02d_e%d_v%d_p%d.mat',n,e,v,p)),'raw');
        assert(s.raw.network==n && s.raw.eta==cfg.eta(e) && s.raw.condition==p && isequal(s.raw.pair,cfg.pairs(v,:)));
        prep=s.raw.prep; move=s.raw.move;
    end
end
