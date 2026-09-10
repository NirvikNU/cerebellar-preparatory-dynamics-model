function result = stage3_bio_movement
    % Movement is a consequence only; achieved GO states are never reset.
    cfg=stage3_bio_paths; destination=fullfile(cfg.bioRoot,'movement.mat'); assert(~isfile(destination));
    s=load(fullfile(cfg.bioRoot,'population.mat'),'result'); pop=s.result; assert(pop.primaryPass);
    result=struct('primary',{{}},'indices',pop.bootstrapIndices,'earlyErrorMM',zeros(10,2));
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        result.primary{n}=struct('targetHand',m.targetHand,'comparatorHand',ref.comparatorHand, ...
            'comparatorMoMs',ref.comparatorMoMs,'hand',{{}},'targetErrorMM',zeros(8,2));
        for condition=1:2
            policy=1; if condition==2, policy=4; end
            p=stage3_bio_load(cfg,n,policy);
            path=fullfile(cfg.bioCache,sprintf('movement_n%02d_p%d.mat',n,policy));
            if isfile(path)
                s=load(path,'evidence'); evidence=s.evidence;
                assert(isequal(evidence.initialState,p.go));
            else
                movement=simulate_published_cortex(m,p.go,true);
                [theta,hand]=simulate_published_arm(m,movement.torque);
                evidence=struct('initialState',p.go,'movement',movement,'theta',theta,'hand',hand);
                save(path,'evidence','-v7.3');
            end
            assert(isequal(squeeze(evidence.movement.rates(1,:,:)),max(p.go,0)));
            assert(all(isfinite(evidence.hand),'all'));
            result.primary{n}.hand{condition}=evidence.hand;
            for q=1:8
                ix=ref.comparatorMoMs(q)+(0:200)+1;
                delta=evidence.hand(ix,[1 3],q)-ref.comparatorHand(ix,[1 3],q);
                result.primary{n}.targetErrorMM(q,condition)=1000*sqrt(mean(sum(delta.^2,2)));
            end
            result.earlyErrorMM(n,condition)=mean(result.primary{n}.targetErrorMM(:,condition));
        end
        fprintf('Movement consequence network %02d complete; no state reset or selection\n',n);
    end
    pr=pop.primaryTable{:,{'prIntact','prBlock'}}; ai=pop.primaryTable{:,{'observed','expected'}};
    result.statistics=stage3_statistics(pr,ai,result.earlyErrorMM,pop.bootstrapIndices);
    result.nontrivialMovement=all(result.earlyErrorMM(:,2)>result.earlyErrorMM(:,1));
    save(destination,'result','-v7.3');
    tableOut=table((1:10).',result.earlyErrorMM(:,1),result.earlyErrorMM(:,2), ...
        'VariableNames',{'network','intactEarlyErrorMM','blockEarlyErrorMM'});
    writetable(tableOut,fullfile(cfg.bioRoot,'movement_summary.csv'));
    stage3_write_json(fullfile(cfg.bioRoot,'statistics.json'),result.statistics);
    assert(result.nontrivialMovement,'BioResume:Movement','No consistent movement consequence; report without tuning');
end
