function receipt = eta_simulate(root)
    cfg=eta_paths(root); started=tic;
    baseline=load(fullfile(cfg.dest,'baseline.mat'),'audit'); assert(strcmp(baseline.audit.status,'PASS'));
    assert(~isfile(fullfile(cfg.dest,'simulation.json')));
    models=cell(10,1); controllers=models; definitions=models;
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); models{n}=s.model;
        s=load(fullfile(cfg.paper,'cache','alignment95',sprintf('controls_n%02d.mat',n)),'c','d');
        controllers{n}=s.c; definitions{n}=s.d;
    end
    assert(isempty(gcp('nocreate'))); pool=parpool('Threads',10); cleanup=onCleanup(@()delete(pool));
    flags=cfg.flags; receipt.newCases=0; receipt.reusedCases=0;
    for e=2:5
        eta=cfg.eta(e); outputs=cell(10,1); needed=false(10,1);
        for n=1:10
            present=arrayfun(@(p)isfile(fullfile(cfg.raw,sprintf('raw_n%02d_e%d_p%d.mat',n,e,p))),1:2);
            assert(all(present)||~any(present),'Incomplete network pair: inspect before resuming.');
            needed(n)=~all(present);
        end
        parfor n=1:10
            pair=cell(1,2);
            if needed(n)
                m=models{n}; c=controllers{n}; d=definitions{n}; c.kappa0=eta*c.kappa0;
                noise=paper_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
                for p=1:2
                    prep=paper_prepare(m,{d},c,flags(p,:),.1,.1,noise,m.dt,true,false); %#ok<PFBNS>
                    move=eta_move(m,prep.go);
                    pair{p}=struct('prep',prep,'move',move,'eta',eta,'network',n,'condition',p,'kappa',c.kappa0);
                end
            end
            outputs{n}=pair;
        end
        for n=1:10
            if needed(n)
                for p=1:2
                    raw=outputs{n}{p}; path=fullfile(cfg.raw,sprintf('raw_n%02d_e%d_p%d.mat',n,e,p));
                    assert(~isfile(path)); save(path,'raw','-v7.3'); receipt.newCases=receipt.newCases+1;
                end
            else
                receipt.reusedCases=receipt.reusedCases+2;
            end
            outputs{n}=[];
        end
        fprintf('Saved eta %.2f: all ten networks and both policies; %.1fs.\n',eta,toc(started));
    end
    receipt.status='PASS'; receipt.eta=cfg.eta; receipt.newBaselineRuns=0;
    receipt.elapsedSeconds=toc(started); receipt.trialsPerCase=240;
    paper_json(fullfile(cfg.dest,'simulation.json'),receipt); clear cleanup
end
