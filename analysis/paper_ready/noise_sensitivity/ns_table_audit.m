function receipt=ns_table_audit(root)
    %#ok<*ALIGN> Compact nested loops enumerate all saved table cases.
    cfg=ns_paths(root); path=fullfile(cfg.dest,'table_audit.json'); assert(~isfile(path));
    T=readtable(fullfile(cfg.dest,'trial_metrics.csv')); N=readtable(fullfile(cfg.dest,'network_metrics.csv'));
    P=readtable(fullfile(cfg.dest,'paired_metrics.csv')); C=readtable(fullfile(cfg.dest,'shuffle_controls.csv'));
    s=load(fullfile(cfg.dest,'summary.mat'),'summary'); r=s.summary; checks=0;
    assert(height(T)==48000 && height(N)==200 && height(P)==100);
    for n=1:10, for e=1:2, for v=1:5
        pair=P.network==n & P.eta==cfg.eta(e) & P.s_init==cfg.pairs(v,1) & P.s_temporal==cfg.pairs(v,2); assert(nnz(pair)==1);
        assert(isequaln(P.deltaC(pair),r.deltaC(n,e,v)) && isequaln(P.deltaR2(pair),r.deltaR2(n,e,v)) && isequaln(P.lossPct(pair),r.lossPct(n,e,v)));
        for p=1:2
            s=load(fullfile(cfg.raw,sprintf('analysis_n%02d_e%d_v%d_p%d.mat',n,e,v,p)),'result'); z=s.result;
            select=T.network==n & T.eta==cfg.eta(e) & T.s_init==cfg.pairs(v,1) & T.s_temporal==cfg.pairs(v,2) & T.condition==p; assert(nnz(select)==240);
            assert(isequaln(T.d_cue(select),z.convergence.cue) && isequaln(T.d_prego(select),z.convergence.prego) && isequaln(T.C(select),z.convergence.c));
            assert(isequaln(T.distanceRatio(select),z.convergence.prego./z.convergence.cue));
            ix=N.network==n & N.eta==cfg.eta(e) & N.s_init==cfg.pairs(v,1) & N.s_temporal==cfg.pairs(v,2) & N.condition==p; assert(nnz(ix)==1);
            assert(isequaln(N.r2(ix),r.r2(n,e,v,p)) && isequaln(N.convergence(ix),r.convergence(n,e,v,p)));
            if z.predictionEvaluable
                ix=C.network==n & C.eta==cfg.eta(e) & C.s_init==cfg.pairs(v,1) & C.s_temporal==cfg.pairs(v,2) & C.condition==p;
                assert(nnz(ix)==100); pred=z.prediction;
                if pred.reusedShuffles, sf=pred.fit; values=sf.r2(2:end); else, sf=pred.shuffleFit; values=sf.r2; end
                assert(isequaln(C.r2(ix),values(:)));
            end
            checks=checks+1;
        end
    end, end, end
    receipt=struct('status','PASS','cases',checks,'trials',height(T),'pairedRows',height(P),'fullPrecisionRoundTrip',true);
    paper_json(path,receipt);
end
