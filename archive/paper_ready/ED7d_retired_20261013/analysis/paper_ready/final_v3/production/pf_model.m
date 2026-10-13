function receipt=pf_model(root,mode,outputRoot)
    assert(any(strcmp(mode,{'check','stochastic'})),'Use check or stochastic; no selection is performed.');
    source=fullfile(root,'data/paper_ready/final_v3');
    if ~isfolder(outputRoot), mkdir(outputRoot); end
    values=jsondecode(fileread(fullfile(source,'tables/Fig6gh_values.json')));
    stats=jsondecode(fileread(fullfile(source,'tables/statistics.json')));
    levels=[.05 .1 .15 .2]; pairs=[levels(:) .1*ones(4,1);.1*ones(3,1) levels([1 3 4]).';.2 .2];
    networks=1:10; cases=1:8;
    if strcmp(mode,'check'), networks=1; cases=2; end
    flags=[1 1;1 0;0 1;0 0]; receipt=struct('status','RUNNING','mode',mode,'cases',{{}},'maxR2Error',0);
    for n=networks
        z=load(fullfile(source,sprintf('network_%02d.mat',n))); m=z.model; c=z.controller; d=z.definition;
        assert(c.kappa0==0 && c.lambda==10 && d.alpha==.5 && d.betaNormalized==1.25 && m.dt==.0002);
        noise=pf_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
        for v=cases
            policies=[1 4]; if v==8, policies=1:4; end
            for p=policies
                file=fullfile(outputRoot,sprintf('network_%02d_pair%d_policy%d.mat',n,v,p));
                assert(~isfile(file),'Production:NoOverwrite','Replay output exists; choose a new output folder.');
                prep=pf_prepare(m,{d},c,flags(p,:),pairs(v,1),pairs(v,2),noise,m.dt,true,false);
                move=pf_move(m,prep.go); analysis=pf_prediction(n,prep,move,z.normalization);
                assert(analysis.predictionEvaluable); actual=analysis.prediction.fit.r2;
                if v<=4
                    sweep=1; level=v;
                elseif v<8
                    sweep=2; order=[1 3 4]; level=order(v-4);
                end
                if v==8
                    expected=stats.ED7dAbsoluteR2(n,p);
                elseif p==1
                    expected=values.RI(n,level,sweep);
                else
                    expected=values.RB(n,level,sweep);
                end
                err=abs(actual-expected); assert(err<1e-9,'Production:ReplayMismatch','Frozen prediction replay differs: %.17g',err);
                receipt.maxR2Error=max(receipt.maxR2Error,err);
                receipt.cases{end+1}=struct('network',n,'noise',pairs(v,:),'policy',p,'R2',actual,'expectedR2',expected,'error',err);
                evidence=struct('go',prep.go,'hand',move.hand,'speed',move.speed,'moMs',move.moMs, ...
                    'peak',move.peak,'prepSeeds',prep.seeds,'analysis',analysis,'condition',p,'noise',pairs(v,:));
                save(file,'evidence','-v7');
                fprintf('Frozen replay passed: network %d pair %d policy %d; R2 error %.3g\n',n,v,p,err);
            end
            if v==2, pf_audit_behavior(root,outputRoot,n); end
        end
    end
    receipt.status='PASS'; pf_json(fullfile(outputRoot,'validation.json'),receipt);
end
