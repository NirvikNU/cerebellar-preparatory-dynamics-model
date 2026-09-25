function receipt=v2_simulate(root)
    cfg=v2_paths(root); output=fullfile(cfg.dest,'simulation.json'); assert(~isfile(output));
    selection=jsondecode(fileread(fullfile(cfg.dest,'geometry_selection.json'))); assert(strcmp(selection.status,'FROZEN'));
    started=tic; receipt=struct('newCases',0,'reusedCases',0,'resumedCases',0,'totalCases',120,'eta',0);
    models=cell(10,1); controllers=models; definitions=models;
    for n=1:10, [models{n},controllers{n},definitions{n}]=v2_definition(cfg,n); end
    assert(isempty(gcp('nocreate'))); pool=parpool('Threads',10); closer=onCleanup(@()delete(pool));
    for v=1:5
        policies=[1 4]; if v==2, policies=1:4; end
        outputs=cell(10,1); needed=false(10,4);
        for n=1:10
            for p=policies
                reused=v2_reuse(selection,p); present=isfile(fullfile(cfg.raw,sprintf('raw_n%02d_v%d_p%d.mat',n,v,p)));
                needed(n,p)=~reused && ~present;
                receipt.reusedCases=receipt.reusedCases+reused;
                receipt.resumedCases=receipt.resumedCases+(~reused&&present);
            end
        end
        si=cfg.pairs(v,1); st=cfg.pairs(v,2); flags=cfg.componentFlags;
        parfor n=1:10
            cases=cell(1,4);
            if any(needed(n,:))
                m=models{n}; c=controllers{n}; d=definitions{n};
                noise=paper_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
                for p=policies
                    if needed(n,p) %#ok<PFBNS> Tiny frozen 10-by-4 scheduling mask.
                        prep=paper_prepare(m,{d},c,flags(p,:),si,st,noise,m.dt,true,false); %#ok<PFBNS> Four immutable policy flags.
                        move=eta_move(m,prep.go);
                        cases{p}=struct('prep',prep,'move',move,'network',n,'condition',p,'eta',0, ...
                            'alpha',d.alpha,'betaNormalized',d.betaNormalized,'pair',[si st]);
                    end
                end
            end
            outputs{n}=cases;
        end
        for n=1:10
            for p=policies
                if needed(n,p)
                    raw=outputs{n}{p}; path=fullfile(cfg.raw,sprintf('raw_n%02d_v%d_p%d.mat',n,v,p));
                    assert(~isfile(path)); save(path,'raw','-v7.3'); receipt.newCases=receipt.newCases+1;
                end
            end
            outputs{n}=[];
        end
        fprintf('Final-v2 raw noise pair%d saved, %.1fs\n',v,toc(started));
    end
    assert(receipt.newCases+receipt.reusedCases+receipt.resumedCases==120);
    receipt.status='PASS'; receipt.elapsedSeconds=toc(started); receipt.selection=selection;
    paper_json(output,receipt); clear closer
end
