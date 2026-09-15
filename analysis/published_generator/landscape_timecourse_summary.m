function receipt=landscape_timecourse_summary(root)
    % Cache-only organization of the already-declared neural norm metric.
    c=landscape_paths(root);
    audit=jsondecode(fileread(fullfile(c.land,'independent_audit.json')));
    assert(strcmp(audit.status,'PASS'));
    path=fullfile(c.land,'neural_norm_timecourse.mat'); assert(~isfile(path));
    loaded=load(fullfile(c.land,'summary.mat'),'s'); s=loaded.s;
    curve=zeros(10,numel(s.time),3,2,6);
    for n=1:10
        d=load(fullfile(c.land,sprintf('network_%02d.mat',n)));
        for amp=2:6
            loaded=load(fullfile(c.cache,sprintf('perturb_n%02d_a%d.mat',n,amp)),'out');
            normAtSavedTime=loaded.out.nativeNorm(1:5:2991,:);
            assert(size(normAtSavedTime,1)==numel(s.time));
            for g=1:3
                for sign=1:2
                    targets=zeros(numel(s.time),8);
                    for q=1:8
                        ids=d.targetIds==q & d.classes(d.directionIds)==g & d.signs==s.signs(sign);
                        targets(:,q)=mean(normAtSavedTime(:,ids),2);
                    end
                    curve(n,:,g,sign,amp)=mean(targets,2).';
                    ids=d.classes(d.directionIds)==g & d.signs==s.signs(sign);
                    direct=mean(normAtSavedTime(:,ids),2);
                    assert(max(abs(direct-mean(targets,2)))<1e-10);
                end
            end
        end
    end
    center=zeros(numel(s.time),3,2,6); standardError=center;
    previous=rng; guard=onCleanup(@()rng(previous)); rng(c.bootstrapSeed,'twister');
    indices=zeros(10000,10);
    for draw=1:10000, indices(draw,:)=randi(10,10,1).'; end
    maxBootstrapError=0;
    for amp=1:6
        for g=1:3
            for sign=1:2
                values=curve(:,:,g,sign,amp);
                b=bootstrap_network_median(values,10000,c.bootstrapSeed);
                center(:,g,sign,amp)=b.median.';
                standardError(:,g,sign,amp)=b.standardError.';
                for time=[1 101 201 401 599]
                    v=values(:,time); draws=median(reshape(v(indices),10000,10),2);
                    se=sqrt(sum((draws-mean(draws)).^2)/9999);
                    err=abs(se-b.standardError(time)); maxBootstrapError=max(maxBootstrapError,err);
                    assert(err<1e-10 && median(v)==b.median(time));
                end
            end
        end
    end
    time=s.time; fraction=s.fraction; classes=s.classes; signs=s.signs;
    dimensionOrder='network x saved-time x direction-class x sign x amplitude';
    save(path,'curve','center','standardError','time','fraction','classes','signs','dimensionOrder');
    receipt=struct('status','PASS','cachedMovements',16000,'savedTimes',599, ...
        'networkCount',10,'independentBootstrapChecks',180,'maximumBootstrapError',maxBootstrapError, ...
        'dimensionOrder',dimensionOrder,'newModelReplays',0);
    landscape_json(fullfile(c.manifest,'TIMECOURSE.json'),receipt);
end
