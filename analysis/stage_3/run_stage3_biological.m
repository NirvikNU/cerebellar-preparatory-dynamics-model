function audit = run_stage3_biological(root)
    % First-gate candidate path. Never replaces accepted outputs on failure.
    if nargin<1, root=fileparts(fileparts(fileparts(mfilename('fullpath')))); end
    addpath(fullfile(root,'config'),fullfile(root,'src','stage_3'));
    cfg=stage_3_config(root);
    out=fullfile(cfg.resultsRoot,'biological_revision');
    cache=fullfile(cfg.cacheRoot,'biological_revision');
    assert(~isfile(fullfile(out,'primary_gate.mat')),'Stage3Bio:Exists','Refuse overwrite');
    if ~isfolder(out), mkdir(out); end
    if ~isfolder(cache), mkdir(cache); end
    s=load(fullfile(cfg.resultsRoot,'selected_solution_registry.mat'),'registry');
    registry=s.registry; models=cell(1,10); controllers=cell(1,10);
    rows=cell(10,1);
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model');
        models{n}=s.model;
        s=load(fullfile(root,'results','stage_2','current','cache',sprintf('network_%02d.mat',n)),'net');
        c=stage3_biological_controller(models{n},registry.primary{n},s.net.controller{1});
        controllers{n}=c;
        rows{n}=table(n,c.kappa0,c.oldKappa,c.zeroGainWorstPole,c.residualWorstPole, ...
            c.intactWorstPole,c.eulerRadius,c.gainRank,c.gainK95,c.strongGainQFraction, ...
            c.isotropicQFraction,c.careResidual,c.policyIdentityError,c.jacobianDifference, ...
            'VariableNames',{'network','kappa0','oldKappa','zeroGainWorstPole','residualWorstPole', ...
            'intactWorstPole','eulerRadius','gainRank','gainK95','strongGainQFraction', ...
            'isotropicQFraction','careResidual','policyIdentityError','jacobianDifference'});
    end
    controllerTable=vertcat(rows{:});
    save(fullfile(out,'controllers.mat'),'controllers','controllerTable','-v7');
    writetable(controllerTable,fullfile(out,'controller_audit.csv'));
    audit=struct('status','PRIMARY_NOT_COMPLETE','completedNetworks',0,'reason','');
    for n=1:10
        m=models{n}; d=registry.primary{n}; c=controllers{n};
        s=load(fullfile(cfg.cacheRoot,sprintf('reference_%02d.mat',n)),'ref'); ref=s.ref;
        pIntact=stage3_biological_prepare(m,d,c,[1 1]);
        pBlock=stage3_biological_prepare(m,d,c,[0 0]);
        inputReference=max(1,pIntact.nativeComponentMax(5));
        inputLimit=cfg.inputMultiplier*inputReference;
        primary=struct('network',n,'definition',d,'controller',c,'intact',pIntact,'block',pBlock, ...
            'inputReference',inputReference,'inputLimit',inputLimit, ...
            'rateLimit',ref.rateLimit,'stateLimit',ref.stateLimit);
        save(fullfile(cache,sprintf('primary_%02d.mat',n)),'primary','-v7.3');
        physical=struct('settle',max(pBlock.relativeSettle)<=cfg.settleRelativeTolerance, ...
            'rate',max(pIntact.nativeRateMax,pBlock.nativeRateMax)<=ref.rateLimit, ...
            'state',max(pIntact.nativeStateNormMax,pBlock.nativeStateNormMax)<=ref.stateLimit, ...
            'input',max([pIntact.nativeComponentMax pBlock.nativeComponentMax])<=inputLimit, ...
            'nonnegative',all(d.xB>=0,'all'));
        audit.completedNetworks=n; audit.physical=physical;
        audit.blockRelativeSettle=pBlock.relativeSettle;
        audit.settleTolerance=cfg.settleRelativeTolerance;
        audit.intactGOStarDistance=pIntact.distanceStar(end,:);
        audit.blockGOStarDistance=pBlock.distanceStar(end,:);
        audit.intactGOBlockDistance=pIntact.distanceBlock(end,:);
        audit.blockGOBlockDistance=pBlock.distanceBlock(end,:);
        audit.inputReference=inputReference; audit.inputLimit=inputLimit;
        audit.componentNames=pIntact.componentNames;
        audit.intactNativeComponentMax=pIntact.nativeComponentMax;
        audit.blockNativeComponentMax=pBlock.nativeComponentMax;
        audit.rateLimit=ref.rateLimit; audit.stateLimit=ref.stateLimit;
        audit.nativeRateMax=[pIntact.nativeRateMax pBlock.nativeRateMax];
        audit.nativeStateNormMax=[pIntact.nativeStateNormMax pBlock.nativeStateNormMax];
        names=fieldnames(physical); failed=names(~cellfun(@(k)physical.(k),names));
        if ~isempty(failed)
            audit.status='SCIENTIFIC_STOP_PRIMARY_PHYSICAL_FAILURE';
            audit.reason=strjoin(failed,', ');
            save(fullfile(out,'primary_gate.mat'),'audit','-v7');
            write_json(fullfile(out,'primary_gate.json'),audit);
            fprintf('SCIENTIFIC STOP network %d: %s; block settle %.12g (limit %.12g)\n', ...
                n,audit.reason,max(pBlock.relativeSettle),cfg.settleRelativeTolerance);
            return
        end
        % Primary physical acceptance precedes any null/grid/movement work.
    end
    audit.status='PRIMARY_PHYSICAL_PASS_REQUIRES_POPULATION_GATE';
    save(fullfile(out,'primary_gate.mat'),'audit','-v7');
    write_json(fullfile(out,'primary_gate.json'),audit);
end

function write_json(path,value)
    fid=fopen(path,'w'); assert(fid>=0); closer=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',jsonencode(value,PrettyPrint=true));
end
