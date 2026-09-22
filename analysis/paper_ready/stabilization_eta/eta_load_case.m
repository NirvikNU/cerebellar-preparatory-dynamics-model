function [prep,move,prior] = eta_load_case(cfg,n,e,p)
    prior=[];
    if e==1
        oldPolicy=cfg.previousPolicies(p);
        s=load(fullfile(cfg.paper,'cache','alignment95',sprintf('controls_n%02d.mat',n)),'policies','moves');
        prep=s.policies{oldPolicy}; move=s.moves{oldPolicy};
        s=load(fullfile(cfg.paper,'cache','prediction',sprintf('series_n%02d_p%d.mat',n,oldPolicy)), ...
            'prepStates','movement');
        prep.states=s.prepStates; move.states=s.movement;
        s=load(fullfile(cfg.paper,'cache','prediction',sprintf('primary_n%02d_p%d.mat',n,oldPolicy)),'result');
        prior=s.result;
    else
        s=load(fullfile(cfg.raw,sprintf('raw_n%02d_e%d_p%d.mat',n,e,p)),'raw');
        assert(s.raw.eta==cfg.eta(e) && s.raw.network==n && s.raw.condition==p);
        prep=s.raw.prep; move=s.raw.move;
    end
end
