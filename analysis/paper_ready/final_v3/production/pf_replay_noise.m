function receipt=pf_replay_noise(root,outputRoot,networks,pairIDs)
    % Reproduce only the committed Control/Block noise grid; optional subsets are validation selections.
    spec=pf_noise_grid;
    if nargin<3,networks=spec.networks;end
    if nargin<4,pairIDs=1:15;end
    assert(all(ismember(networks,1:10))&&numel(unique(networks))==numel(networks));
    assert(all(ismember(pairIDs,1:15))&&numel(unique(pairIDs))==numel(pairIDs));
    source=fullfile(root,'data/paper_ready/final_v3');
    values=jsondecode(fileread(fullfile(source,'tables/Fig6gh_values.json')));
    assert(isequal(values.levels(:).',spec.levels)&&isequal(values.pairs,spec.pairs));
    assert(isequal(values.RI(:,1,1),values.RI(:,1,2))&&isequal(values.RB(:,1,1),values.RB(:,1,2)));
    if ~isfolder(outputRoot),mkdir(outputRoot);end
    receipt=struct('status','RUNNING','mode','stochastic','cases',{{}},'maxR2Error',0,'maxRelativeSSEError',0,'maxRelativeSSTError',0);
    flags=[1 1;0 0];
    for n=networks
        z=load(fullfile(source,sprintf('network_%02d.mat',n)));m=z.model;c=z.controller;d=z.definition;
        assert(c.kappa0==0&&c.lambda==10&&d.alpha==.5&&d.betaNormalized==1.25&&m.dt==.0002);
        noise=pf_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
        for v=pairIDs
            pair=spec.pairs(v,:);
            if v<=8,sweep=1;level=v;else,sweep=2;level=v-7;end
            for j=1:2
                p=spec.policies(j);file=fullfile(outputRoot,sprintf('network_%02d_pair%d_policy%d.mat',n,v,p));
                assert(~isfile(file),'Production:NoOverwrite','Replay evidence exists; use a new output directory.');
                prep=pf_prepare(m,{d},c,flags(j,:),pair(1),pair(2),noise,m.dt,true,false);
                move=pf_move(m,prep.go);analysis=pf_prediction(n,prep,move,z.normalization);
                assert(analysis.predictionEvaluable,'Production:PredictionWindow','Required neural response window or fit unavailable.');
                fit=analysis.prediction.fit;actual=fit.r2;
                SSE=sum((fit.actual-fit.predicted).^2,[1 2]);SST=sum((fit.actual-mean(fit.actual,1)).^2,[1 2]);
                if p==1
                    expected=values.RI(n,level,sweep);expectedSSE=values.SSEI(n,level,sweep);expectedSST=values.SSTI(n,level,sweep);
                else
                    expected=values.RB(n,level,sweep);expectedSSE=values.SSEB(n,level,sweep);expectedSST=values.SSTB(n,level,sweep);
                end
                err=abs(actual-expected);sseError=abs(SSE-expectedSSE)/max(1,abs(expectedSSE));sstError=abs(SST-expectedSST)/max(1,abs(expectedSST));
                assert(err<1e-9&&sseError<1e-10&&sstError<1e-10,'Production:ReplayMismatch','Noise-source replay differs from committed numerical evidence.');
                assert(SST>0&&isfinite(SSE)&&isequal(actual,1-SSE/SST));
                evidence=struct('go',prep.go,'hand',move.hand,'speed',move.speed,'moMs',move.moMs, ...
                    'peak',move.peak,'prepSeeds',prep.seeds,'analysis',analysis,'condition',p,'noise',pair);
                save(file,'evidence','-v7');
                receipt.maxR2Error=max(receipt.maxR2Error,err);
                receipt.maxRelativeSSEError=max(receipt.maxRelativeSSEError,sseError);receipt.maxRelativeSSTError=max(receipt.maxRelativeSSTError,sstError);
                receipt.cases{end+1}=struct('network',n,'pairID',v,'noise',pair,'policy',p,'R2',actual,'expectedR2',expected, ...
                    'SSE',SSE,'SST',SST,'R2Error',err,'relativeSSEError',sseError,'relativeSSTError',sstError);
                fprintf('Noise replay PASS: network %d pair %d policy %d; R2 error %.3g\n',n,v,p,err);
            end
        end
    end
    receipt.status='PASS';receipt.uniquePairs=numel(pairIDs);receipt.networks=networks;
    receipt.trials=numel(receipt.cases)*240;receipt.sharedBaselineComputedOnce=nnz(pairIDs==1)<=1;
    pf_json(fullfile(outputRoot,'validation.json'),receipt);
end
