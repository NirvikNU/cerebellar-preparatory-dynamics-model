function report = test_stage2(cfg)
    % Bounded synthetic/source-algebra tests, without model rollout or tuning.
    [t,n,g] = ndgrid(1:11,1:200,1:8);
    sentinel = 100000*n+100*g+t;
    X = stage2_matrix(sentinel);
    expected = zeros(88,200);
    for neuron = 1:200
        expected(:,neuron) = reshape(sentinel(:,neuron,:),[],1);
    end
    assert(isequal(X,expected));
    assert(all(floor(X/100000)==1:200,'all'));
    report.sentinelExact = true;
    C = diag([ones(1,15) zeros(1,25)]);
    U = eye(40);
    report.identicalAlignment = trace(U(:,1:15).'*C*U(:,1:15))/15;
    report.orthogonalAlignment = trace(U(:,16:30).'*C*U(:,16:30))/15;
    assert(report.identicalAlignment==1 && report.orthogonalAlignment==0);
    values = stage2_null(eye(40),C,15,15,1000,20260910);
    report.isotropicNullMean = mean(values);
    assert(abs(report.isotropicNullMean-15/40)<0.025);
    zeroNull = stage2_null(C,C,15,15,50,20260911);
    assert(max(abs(zeroNull-1))<1e-10);
    s = load(fullfile(cfg.ensembleRoot,'network_01.mat'),'model');
    m = s.model;
    ctl = stage2_controller(m,0.1);
    r = max(m.spontaneous+0.1*cos((1:200).'),0);
    direct = m.h+(m.W+ctl.K)*r+ctl.specific;
    offset = m.h+m.W*r+ctl.tonic+ctl.K*(r-max(m.xstar,0));
    report.sourceAlgebraError = max(abs(direct-offset),[],'all');
    assert(report.sourceAlgebraError<1e-10);
    report.careRelativeResidual = ctl.careRelativeResidual;
    report.status = 'PASS';
end
