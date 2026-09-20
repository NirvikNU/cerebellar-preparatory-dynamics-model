function audit = paper_preflight(root)
    addpath(fullfile(root,'analysis','stage_3')); cfg=stage3_bio_paths(root);
    dest=fullfile(root,'results','paper_ready');
    s=load(fullfile(dest,'timing','timing.mat'),'result'); timing=s.result;
    assert(strcmp(timing.status,'TIMING_PASS'));
    assert(~isfile(fullfile(dest,'preflight.mat')));
    s=load(fullfile(cfg.ensembleRoot,'network_01.mat'),'model'); m=s.model;
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry'); d=s.registry.primary{1};
    s=load(fullfile(cfg.resultsRoot,'biological_revision','controllers.mat'),'controllers'); c=s.controllers{1};
    % Reuse passed isolated-leak/Brownian-bridge evidence, not another noise fit.
    s=load(fullfile(cfg.cacheRoot,'prediction_validation','preflight_evidence.mat'),'evidence'); old=s.evidence;
    s=load(fullfile(cfg.resultsRoot,'prediction_validation','preflight_repair.mat'),'report');
    assert(strcmp(s.report.status,'PASS')); audit.priorNumericalPreflight=s.report;
    noise=paper_noise(1,[1 5],[1 1],2500);
    audit.standardInitialIdentity=isequal(noise.initial,old.noise.initial);
    audit.standardProcessIdentity=isequal(noise.process,old.noise.process(:,:,1:2500));
    assert(audit.standardInitialIdentity && audit.standardProcessIdentity);
    fine=old.fineNoise; fine.process=fine.process(:,:,1:5000); fine.targets=[1 5];
    % Explicit sentinel: each matrix column is one neuron, all targets/times.
    sentinel=zeros(11,200,8);
    for q=1:8, sentinel(:,:,q)=(1:11).'+1000*(1:200)+100*q; end
    flattened=reshape(permute(sentinel,[1 3 2]),[],200);
    assert(isequal(floor(flattened/1000),repmat(1:200,88,1)));
    audit.neuronIdentity=true;
    zero=paper_noise(1,1:8,ones(1,8),2500); audit.deterministic=zeros(1,4);
    for p=1:4
        actual=paper_prepare(m,{d},c,cfg.policyFlags(p,:),0,0,zero,m.dt,true);
        frozen=stage3_bio_load(cfg,1,p);
        audit.deterministic(p)=max(abs(actual.states-frozen.states),[],'all');
        assert(audit.deterministic(p)<1e-10);
    end
    s=load(fullfile(root,'results','stage_2','current','cache','network_01.mat'),'net');
    j=timing.lambda==timing.selectedLambda; c.P=s.net.controller{j}.P; c.L=c.P/timing.selectedLambda;
    audit.fineStep=zeros(4,2);
    for p=1:4
        coarse=paper_prepare(m,{d},c,cfg.policyFlags(p,:),.1,.1,noise,m.dt,true);
        finer=paper_prepare(m,{d},c,cfg.policyFlags(p,:),.1,.1,fine,.0001,true);
        mc=simulate_published_cortex(m,coarse.go,false); [~,hc]=simulate_published_arm(m,mc.torque);
        % Source-faithful fine movement, no postGO noise or changed arm step.
        mf=m; mf.dt=.0001; mf.nInternalSteps=2*m.nInternalSteps;
        mm=simulate_published_cortex(mf,finer.go,false); [~,hf]=simulate_published_arm(m,mm.torque);
        audit.fineStep(p,:)=[sqrt(mean((coarse.states-finer.states).^2,'all'))/max(1,sqrt(mean(finer.states.^2,'all'))), ...
            sqrt(mean((hc(:,[1 3],:)-hf(:,[1 3],:)).^2,'all'))];
        assert(audit.fineStep(p,1)<=.01 && audit.fineStep(p,2)<=.001);
    end
    audit.status='PASS'; audit.predictionRun=false;
    save(fullfile(dest,'preflight.mat'),'audit'); paper_json(fullfile(dest,'preflight.json'),audit);
end
