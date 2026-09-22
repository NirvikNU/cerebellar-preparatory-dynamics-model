function audit = eta_baseline(root)
    cfg=eta_paths(root); receipt=fullfile(cfg.dest,'baseline.json'); assert(~isfile(receipt));
    protection=jsondecode(fileread(fullfile(cfg.manifest,'RESUME_INVENTORY.json')));
    assert(strcmp(protection.status,'PASS'));
    models=cell(10,1); definitions=cell(10,1); controllers=cell(10,1); originals=cell(10,1);
    started=tic;
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); models{n}=s.model;
        s=load(fullfile(cfg.paper,'cache','alignment95',sprintf('controls_n%02d.mat',n)),'c','d','policies');
        assert(s.c.lambda==10 && s.d.alpha==.5 && s.d.betaNormalized==1);
        definitions{n}=s.d; controllers{n}=s.c; originals{n}=s.policies([1 4]);
    end
    pool=gcp('nocreate'); assert(isempty(pool),'Do not reuse or alter an unrelated MATLAB pool.');
    pool=parpool('Threads',10); cleanup=onCleanup(@()delete(pool));
    outputs=cell(10,1); equations=cell(10,1); etaValues=cfg.eta; policyFlags=cfg.flags;
    parfor n=1:10
        noise=paper_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
        c=controllers{n}; d=definitions{n}; m=models{n}; pair=cell(1,2); checked=cell(1,5);
        % Intentional read-only broadcasts: five eta values and four flags.
        for e=1:5, checked{e}=eta_equations(m,d,c,etaValues(e)); end %#ok<PFBNS>
        for p=1:2
            pair{p}=paper_prepare(m,{d},c,policyFlags(p,:),.1,.1,noise,m.dt,true,false); %#ok<PFBNS>
        end
        outputs{n}=pair; equations{n}=checked;
    end
    audit=struct('status','RUNNING','elapsedSeconds',0,'errors',zeros(10,2,9), ...
        'eta',cfg.eta,'etaOneReplays',20,'scientificParametersChanged',false, ...
        'newPredictionFits',false,'rrrRun',false,'newMovementRuns',false);
    audit.errorNames={'allSavedPrepStates','GO','initial','lateRates','meanRates', ...
        'nativeRateMaximum','nativeStateMaximum','deliveredComponentMaxima','nativeTransitions'};
    for n=1:10
        for p=1:2
            prior=originals{n}{p}; replay=outputs{n}{p};
            s=load(fullfile(cfg.paper,'cache','prediction',sprintf('series_n%02d_p%d.mat',n,cfg.previousPolicies(p))), ...
                'prepStates','scale','provenance');
            errors=[max(abs(replay.states-s.prepStates),[],'all'), ...
                max(abs(replay.go-prior.go),[],'all'),max(abs(replay.initial-prior.initial),[],'all'), ...
                max(abs(replay.lateRates-prior.lateRates),[],'all'),max(abs(replay.meanRates-prior.meanRates),[],'all'), ...
                abs(replay.rateMax-prior.rateMax),abs(replay.stateMax-prior.stateMax), ...
                max(abs(replay.componentMax-prior.componentMax)),0];
            assert(isequal(replay.seeds,prior.seeds) && isequal(replay.seeds,s.provenance.seeds));
            for j=1:numel(replay.audit)
                a=replay.audit(j); b=prior.audit(j);
                errors(9)=max([errors(9),max(abs(a.x-b.x),[],'all'), ...
                    max(abs(a.next-b.next),[],'all'),max(abs(a.noiseIncrement-b.noiseIncrement),[],'all')]);
            end
            audit.errors(n,p,:)=errors;
            assert(max(errors)<1e-10,'ETA:BaselineMismatch','eta=1 replay does not reproduce protected evidence.');
            outputs{n}{p}=[];
        end
        fprintf('Baseline fully matched: network %d, both policies.\n',n);
    end
    audit.spectralAbscissa=zeros(10,5,2,8); audit.maxAlgebraError=0;
    audit.maxEquilibriumError=0; audit.maxJacobianError=0; audit.maxSpectralShiftError=0;
    audit.minKinkDistance=Inf;
    for n=1:10
        for e=1:5
            checked=equations{n}{e};
            audit.spectralAbscissa(n,e,:,:)=checked.spectralAbscissa.';
            audit.maxAlgebraError=max(audit.maxAlgebraError,checked.algebraError);
            audit.maxEquilibriumError=max(audit.maxEquilibriumError,checked.equilibriumError);
            audit.maxJacobianError=max(audit.maxJacobianError,checked.jacobianError);
            audit.maxSpectralShiftError=max(audit.maxSpectralShiftError,checked.spectralShiftError);
            audit.minKinkDistance=min(audit.minKinkDistance,min(checked.minKinkDistance,[],'all'));
        end
    end
    audit.equationCaseCount=sum(cellfun(@numel,equations));
    assert(audit.equationCaseCount==50);
    audit.status='PASS'; audit.elapsedSeconds=toc(started);
    save(fullfile(cfg.dest,'baseline.mat'),'audit','equations','-v7.3');
    paper_json(receipt,audit);
    clear cleanup
end
