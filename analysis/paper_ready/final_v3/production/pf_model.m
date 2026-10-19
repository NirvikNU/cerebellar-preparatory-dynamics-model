function receipt=pf_model(root,mode,outputRoot)
    assert(any(strcmp(mode,{'check','stochastic'})),'Use check or stochastic; no selection is performed.');
    if strcmp(mode,'stochastic')
        receipt=pf_replay_noise(root,outputRoot);return
    end
    % The primary .10/.10 bounded replay is unchanged by the separate Fig6g,h grid.
    source=fullfile(root,'data/paper_ready/final_v3');
    if ~isfolder(outputRoot),mkdir(outputRoot);end
    values=jsondecode(fileread(fullfile(source,'noise_sensitivity_20261019/primary_reference.json')));
    assert(isequal(values.noise(:).',[.1 .1]));
    n=1;v=2;pair=[.1 .1];policies=[1 4];flags=[1 1;0 0];
    receipt=struct('status','RUNNING','mode',mode,'cases',{{}},'maxR2Error',0);
    z=load(fullfile(source,sprintf('network_%02d.mat',n)));m=z.model;c=z.controller;d=z.definition;
    assert(c.kappa0==0&&c.lambda==10&&d.alpha==.5&&d.betaNormalized==1.25&&m.dt==.0002);
    noise=pf_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
    for j=1:2
        p=policies(j);file=fullfile(outputRoot,sprintf('network_%02d_pair%d_policy%d.mat',n,v,p));
        assert(~isfile(file),'Production:NoOverwrite','Replay output exists; choose a new output folder.');
        prep=pf_prepare(m,{d},c,flags(j,:),pair(1),pair(2),noise,m.dt,true,false);
        move=pf_move(m,prep.go);analysis=pf_prediction(n,prep,move,z.normalization);
        assert(analysis.predictionEvaluable);actual=analysis.prediction.fit.r2;
        if p==1,expected=values.ControlR2(n);else,expected=values.BlockR2(n);end
        err=abs(actual-expected);assert(err<1e-9,'Production:ReplayMismatch','Frozen prediction replay differs: %.17g',err);
        receipt.maxR2Error=max(receipt.maxR2Error,err);
        receipt.cases{end+1}=struct('network',n,'noise',pair,'policy',p,'R2',actual,'expectedR2',expected,'error',err);
        evidence=struct('go',prep.go,'hand',move.hand,'speed',move.speed,'moMs',move.moMs, ...
            'peak',move.peak,'prepSeeds',prep.seeds,'analysis',analysis,'condition',p,'noise',pair);
        save(file,'evidence','-v7');
        fprintf('Frozen primary replay passed: network %d policy %d; R2 error %.3g\n',n,p,err);
    end
    pf_audit_behavior(root,outputRoot,n);
    receipt.status='PASS';pf_json(fullfile(outputRoot,'validation.json'),receipt);
end
