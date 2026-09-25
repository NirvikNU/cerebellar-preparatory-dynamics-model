function receipt=v2_control_tables(root)
    cfg=v2_paths(root); output=fullfile(cfg.dest,'control_tables.json'); assert(~isfile(output));
    s=load(fullfile(cfg.dest,'figure_sources.mat'),'data'); d=s.data; rows=[];
    for n=1:10
        for v=1:5
            policies=[1 4]; if v==2, policies=1:4; end
            for p=policies
                s=load(fullfile(cfg.raw,sprintf('analysis_n%02d_v%d_p%d.mat',n,v,p)),'result'); r=s.result;
                if ~r.predictionEvaluable, continue; end
                pred=r.prediction;
                if pred.reusedShuffles, fit=pred.fit; offset=1; else, fit=pred.shuffleFit; offset=0; end
                for j=1:100
                    rows(end+1,:)=[n cfg.pairs(v,:) p j fit.r2(j+offset) fit.lambdaIndex(:,j+offset).' fit.fullLambdaIndex(j+offset)]; %#ok<AGROW>
                end
            end
        end
    end
    v2_csv(fullfile(cfg.dest,'shuffle_controls.csv'),{'network','s_init','s_temporal','policy','shuffle','R2','penaltyIndex1','penaltyIndex2','penaltyIndex3','fullPenaltyIndex'},rows);
    e=d.empirical; v2_csv(fullfile(cfg.dest,'empirical_targets.csv'),{'metricID_ControlPR_BlockPR_Observed_Expected','estimate','originalResampleSD'},[(1:4).' reshape(e.prep(1:4),4,1) reshape(e.error(1:4),4,1)]);
    legacy=zeros(80,7);
    for n=1:10
        for j=1:8
            legacy((n-1)*8+j,:)=[n d.stage2.cfg.lambda(j) d.stage2.pr(n,j) d.stage2.deltaPR(n,j) 100*d.stage2.observed(n,j) 100*d.stage2.expected(n,j) d.stage2.deficitPP(n,j)];
        end
    end
    v2_csv(fullfile(cfg.dest,'MainAB_controller_effort.csv'),{'network','lambda','PR','deltaPR','observedPct','expectedPct','deficitPP'},legacy);
    movement=zeros(600*240*2,7); at=0; origin=d.representative{1}.hand(1,[1 3],1);
    for p=1:2
        for j=1:240
            r=d.representative{p}; xy=reshape(r.hand(:,[1 3],j),[],2)-origin; count=size(xy,1);
            ix=at+(1:count); movement(ix,:)=[repmat([p ceil(j/30) mod(j-1,30)+1],count,1) (0:count-1).' 100*xy r.speed(:,j)]; at=at+count;
        end
    end
    movement=movement(1:at,:);
    v2_csv(fullfile(cfg.dest,'MainDF_network1_untruncated.csv'),{'condition_Intact1_Block2','target','trial','timeFromGO_ms','handDisplacementX_cm','handDisplacementY_cm','unsmoothedSpeed_mps'},movement);
    readback=readmatrix(fullfile(cfg.dest,'MainDF_network1_untruncated.csv'));
    assert(isequaln(readback,movement));
    receipt=struct('status','PASS','shuffleRows',size(rows,1),'untruncatedMovementRows',at,'legacyRows',80,'empiricalRows',4,'fullPrecisionRoundTrip',true);
    paper_json(output,receipt);
end
