function receipt=ns_unit(root)
    % Reuse bounded released indexing/leakage test logic; write only this bundle.
    cfg=ns_paths(root); path=fullfile(cfg.dest,'unit.json'); assert(~isfile(path));
    stream=RandStream('mt19937ar','Seed',20260922);
    states=10+.1*randn(stream,501,200,240); scale=linspace(.5,2,200).';
    folds=stage3_prediction_folds(1,repelem((1:8).',30)); a=eta_convergence(states,scale,folds);
    tests=find(folds.outer(1:30)==1); altered=states;
    altered(:,:,tests)=altered(:,:,tests)+reshape(linspace(0,1,501),501,1,1);
    b=eta_convergence(altered,scale,folds);
    receipt.basisLeakage=norm(a.basis{1,1}*a.basis{1,1}.'-b.basis{1,1}*b.basis{1,1}.','fro');
    receipt.meanLeakage=max(abs(a.mean{1,1}-b.mean{1,1})); assert(receipt.basisLeakage==0 && receipt.meanLeakage==0);
    sentinel=repmat(reshape(1:200,1,200,1),51,1,20);
    receipt.neuronIdentity=isequal(reshape(permute(sentinel,[1 3 2]),[],200),repmat(1:200,1020,1)); assert(receipt.neuronIdentity);
    coverage=zeros(240,1);
    for q=1:8, for f=1:3, coverage(a.heldout{q,f})=coverage(a.heldout{q,f})+1; end, end
    assert(all(coverage==1));
    X=randn(stream,240,9); Y=randn(stream,240,7); fit=stage3_prediction_ridge(X,Y,folds,cfg.grid);
    direct=ns_fit_audit(X,fit,1); assert(direct.predictionError<1e-8 && direct.r2Error<1e-10);
    receipt.ridge=direct; receipt.status='PASS'; paper_json(path,receipt);
end
