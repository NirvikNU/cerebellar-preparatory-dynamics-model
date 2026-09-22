function receipt=eta_unit(root)
    % Synthetic indexing and leakage tests only; no model/noise parameters changed.
    cfg=eta_paths(root); receipt=struct('status','RUNNING');
    stream=RandStream('mt19937ar','Seed',20260922);
    states=10+.1*randn(stream,501,200,240); scale=linspace(.5,2,200).';
    folds=stage3_prediction_folds(1,repelem((1:8).',30));
    original=eta_convergence(states,scale,folds);
    heldout=find(folds.outer(1:30)==1); altered=states;
    altered(:,:,heldout)=altered(:,:,heldout)+reshape(linspace(0,1,501),501,1,1);
    changed=eta_convergence(altered,scale,folds);
    receipt.heldoutBasisChange=norm(original.basis{1,1}*original.basis{1,1}.'-changed.basis{1,1}*changed.basis{1,1}.','fro');
    receipt.heldoutReferenceMeanChange=max(abs(original.mean{1,1}-changed.mean{1,1}));
    assert(receipt.heldoutBasisChange==0 && receipt.heldoutReferenceMeanChange==0);
    sentinel=repmat(reshape(1:200,1,200,1),51,1,20);
    columns=reshape(permute(sentinel,[1 3 2]),[],200);
    receipt.neuronColumnIdentity=isequal(columns,repmat(1:200,1020,1)); assert(receipt.neuronColumnIdentity);
    coverage=zeros(240,1);
    for q=1:8
        for fold=1:3
            refs=original.references{q,fold}; tests=original.heldout{q,fold};
            assert(numel(refs)==20 && numel(tests)==10 && isempty(intersect(refs,tests)));
            coverage(tests)=coverage(tests)+1;
        end
    end
    assert(all(coverage==1)); receipt.everyTrialHeldOutOnce=true;
    receipt.status='PASS'; path=fullfile(cfg.dest,'unit.json'); assert(~isfile(path)); paper_json(path,receipt);
end
