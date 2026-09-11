function audit = stage3_prediction_pipeline_test(root)
    % End-to-end analysis plumbing on deterministic synthetic, non-model data.
    cfg=stage3_prediction_paths(root); targets=repelem((1:8).',30); trial=repmat((1:30).',8,1);
    angle=(targets-1)*pi/4; neuron=1:200;
    X=cos(angle)*sin(neuron)+sin(angle)*cos(neuron)+.03*sin((1:240).'*neuron/37);
    f=struct('targets',targets,'trials',trial,'X',{{X-mean(X),[],[]}}, ...
        'peakPosition',[.1*cos(angle)+.001*sin(trial),.1*sin(angle)+.002*cos(trial)], ...
        'peakSpeed',.5+.1*cos(angle)+.01*sin(trial));
    f.X{2}=X.*cos(neuron/7)+.01*cos((1:240).'*neuron/19); f.X{2}=f.X{2}-mean(f.X{2});
    f.X{3}=X+.02*sin((1:240).'*neuron/23); f.X{3}=f.X{3}-mean(f.X{3});
    result=stage3_prediction_case(f,1,cfg.ridgeGrid,cfg.permutations,[cos((0:7).'*pi/4),sin((0:7).'*pi/4)]);
    assert(numel(result.metrics)==11 && all(isfinite(result.metrics)));
    assert(numel(result.neural.r2)==101 && isequal(size(result.behavior{1}.speedAxes),[200 101]));
    for rep=1:100
        assert(isequal(sort(result.globalPermutations(:,rep)),(1:240).'));
        assert(isequal(targets(result.withinPermutations(:,rep)),targets));
    end
    audit=struct('status','PASS','syntheticOnly',true,'noAcceptedDataUsed',true, ...
        'featureCount',200,'trialCount',240,'permutations',100,'metricCount',11);
    assert(~isfile(fullfile(cfg.predRoot,'pipeline_unit_tests.json')));
    stage3_write_json(fullfile(cfg.predRoot,'pipeline_unit_tests.json'),audit); disp(audit);
end
