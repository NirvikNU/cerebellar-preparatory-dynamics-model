function receipt=ns_simulate(root)
    cfg=ns_paths(root); started=tic; path=fullfile(cfg.dest,'simulation.json'); assert(~isfile(path));
    a=jsondecode(fileread(fullfile(cfg.manifest,'preservation_before.json'))); assert(strcmp(a.status,'PASS'));
    a=jsondecode(fileread(fullfile(cfg.dest,'unit.json'))); assert(strcmp(a.status,'PASS'));
    models=cell(10,1); controllers=models; definitions=models;
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); models{n}=s.model;
        assert(s.model.dt==.0002 && s.model.tau==.15);
        s=load(fullfile(cfg.paper,'cache','alignment95',sprintf('controls_n%02d.mat',n)),'c','d');
        controllers{n}=s.c; definitions{n}=s.d;
    end
    assert(isempty(gcp('nocreate'))); pool=parpool('Threads',10); closer=onCleanup(@()delete(pool));
    receipt=struct('status','RUNNING','newCases',0,'resumedCases',0,'reusedAnchors',40,'eta',cfg.eta,'pairs',cfg.pairs);
    flags=cfg.flags;
    for e=1:2
        eta=cfg.eta(e);
        for v=[1 3 4 5]
            si=cfg.pairs(v,1); st=cfg.pairs(v,2); outputs=cell(10,1); needed=false(10,1);
            for n=1:10
                present=arrayfun(@(p)isfile(fullfile(cfg.raw,sprintf('raw_n%02d_e%d_v%d_p%d.mat',n,e,v,p))),1:2);
                assert(all(present)||~any(present),'Partial pair; stop for preservation review.'); needed(n)=~all(present);
            end
            parfor n=1:10
                pair=cell(1,2);
                if needed(n)
                    m=models{n}; c=controllers{n}; d=definitions{n}; c.kappa0=eta*c.kappa0;
                    noise=paper_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
                    for p=1:2
                        prep=paper_prepare(m,{d},c,flags(p,:),si,st,noise,m.dt,true,false); %#ok<PFBNS>
                        move=eta_move(m,prep.go);
                        pair{p}=struct('prep',prep,'move',move,'eta',eta,'network',n,'condition',p,'pair',[si st]);
                    end
                end
                outputs{n}=pair;
            end
            for n=1:10
                if needed(n)
                    for p=1:2
                        raw=outputs{n}{p}; output=fullfile(cfg.raw,sprintf('raw_n%02d_e%d_v%d_p%d.mat',n,e,v,p));
                        assert(~isfile(output)); save(output,'raw','-v7.3'); receipt.newCases=receipt.newCases+1;
                    end
                else
                    receipt.resumedCases=receipt.resumedCases+2;
                end
                outputs{n}=[];
            end
            fprintf('Saved eta%g noise%g/%g:20 cases, %.1fs.\n',eta,si,st,toc(started));
        end
    end
    assert(receipt.newCases+receipt.resumedCases==160); receipt.status='PASS'; receipt.elapsedSeconds=toc(started);
    receipt.newBaselineRuns=0; receipt.trialsPerCase=240; paper_json(path,receipt); clear closer
end
