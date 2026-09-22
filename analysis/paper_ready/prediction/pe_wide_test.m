function audit = pe_wide_test(root)
    cfg=pe_paths(root); rs=RandStream('mt19937ar','Seed',323000002);
    X=randn(rs,240,200); Y=X*randn(rs,200,12)*randn(rs,12,200)/50+.1*randn(rs,240,200);
    folds=stage3_prediction_folds(1,repelem((1:8)',30)); started=tic;
    fit=pe_rrr_fit(X,Y,folds,cfg.ridgeGrid,1:200); elapsed=toc(started);
    discrepancy=0;
    for o=1:3
        train=folds.outer~=o; xm=mean(X(train,:),1); ym=mean(Y(train,:),1);
        for rank=[1 7 40 106 159 160 200]
            g=fit.lambdaIndex(o,rank); Z=[X(train,:)-xm;sqrt(cfg.ridgeGrid(g))*eye(200)]; T=[Y(train,:)-ym;zeros(200)];
            [Q,R]=qr(Z,0); cross=Q.'*T; [~,~,V]=svd(cross,'econ'); B=(R\cross)*V(:,1:rank)*V(:,1:rank).';
            prediction=(X(~train,:)-xm)*B+ym;
            discrepancy=max(discrepancy,abs(norm(Y(~train,:)-prediction,'fro')^2-fit.outerSSE(o,rank)));
        end
    end
    assert(discrepancy<1e-6);
    audit=struct('status','PASS','seed',323000002,'full200DirectQRSSEError',discrepancy,'singleNestedFitSeconds',elapsed, ...
        'fullSweepFits',40400,'realPredictionRun',false);
    paper_json(fullfile(cfg.dest,'unit_wide.json'),audit); disp(audit);
end
