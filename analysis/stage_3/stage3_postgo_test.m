function receipt = stage3_postgo_test(root)
    % Deterministic synthetic plumbing only; no new scientific random draws.
    cfg=stage3_postgo_paths(root); targets=repelem((1:8).',30); trial=repmat((1:30).',8,1);
    angle=(targets-1)*pi/4; neuron=1:200;
    X=cos(angle)*sin(neuron)+sin(angle)*cos(neuron)+.03*sin((1:240).'*neuron/37);
    f=struct('targets',targets,'trials',trial,'X',{{X-mean(X),[],[]}}, ...
        'peakPosition',[.1*cos(angle)+.001*sin(trial),.1*sin(angle)+.002*cos(trial)], ...
        'peakSpeed',.5+.1*cos(angle)+.01*sin(trial));
    f.X{2}=X.*cos(neuron/7)+.01*cos((1:240).'*neuron/19); f.X{2}=f.X{2}-mean(f.X{2});
    f.X{3}=X+.02*sin((1:240).'*neuron/23); f.X{3}=f.X{3}-mean(f.X{3});
    targetXY=[cos((0:7).'*pi/4),sin((0:7).'*pi/4)];
    old=stage3_prediction_case(f,1,cfg.ridgeGrid,0,targetXY);
    current=stage3_postgo_behavior(f,old.folds,cfg.ridgeGrid,targetXY);
    err=max(abs(old.metrics(2:9)-current.metrics)); assert(err==0);
    for e=1:2
        assert(isequal(old.behavior{e}.taskAxes,current.behavior{e}.taskAxes));
        assert(isequal(old.behavior{e}.speed,current.behavior{e}.speed));
        assert(isequal(old.behavior{e}.withinR2,current.behavior{e}.withinR2));
    end
    receipt=struct('status','PASS','syntheticOnly',true,'newRandomDraws',0, ...
        'actualResponseBranchError',err,'featuresAndRegressionParametersUnchanged',true);
    assert(~isfile(fullfile(cfg.postRoot,'unit_tests.json')));
    stage3_write_json(fullfile(cfg.postRoot,'unit_tests.json'),receipt); disp(receipt);
end
