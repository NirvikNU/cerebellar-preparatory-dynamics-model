function receipt=v2_unit(root)
    cfg=v2_paths(root); path=fullfile(cfg.dest,'unit.json'); assert(~isfile(path));
    stream=RandStream('mt19937ar','Seed',202609251); % Synthetic test only, never a model/noise stream.
    states=10+randn(stream,501,200,240); initial=reshape(states(1,:,:),200,240);
    scale=linspace(.5,2,200).'; folds=stage3_prediction_folds(1,repelem((1:8).',30));
    a=v2_convergence(states,initial,scale,folds);
    receipt.independentError=v2_convergence_audit(states,initial,scale,a); assert(receipt.independentError<1e-8);
    held=a.heldout{1,1}; mutant=states; mutant(2:end,:,held)=mutant(2:end,:,held)+1000;
    b=v2_convergence(mutant,initial,scale,folds);
    receipt.heldoutBasisLeakage=max(abs(a.basis{1,1}-b.basis{1,1}),[],'all');
    receipt.postcueBaselineLeakage=max(abs(a.precue(held)-b.precue(held)));
    receipt.postcueReferenceLeakage=max(abs(a.referencePrecue{1,1}-b.referencePrecue{1,1}));
    assert(receipt.heldoutBasisLeakage==0 && receipt.postcueBaselineLeakage==0 && receipt.postcueReferenceLeakage==0);
    states(1,:,:)=0; z=v2_convergence(states,zeros(200,240),scale,folds);
    assert(all(z.precue==0) && z.undefined==240 && all(isnan(z.c)) && isnan(z.value));
    receipt.zeroDenominatorNotRescued=true; receipt.status='PASS'; receipt.syntheticOnly=true;
    paper_json(path,receipt);
end
