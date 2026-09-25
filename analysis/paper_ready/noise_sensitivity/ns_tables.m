function receipt=ns_tables(root)
    %#ok<*ALIGN> Compact nested loops below only enumerate output table rows.
    cfg=ns_paths(root); a=jsondecode(fileread(fullfile(cfg.dest,'audit.json'))); assert(strcmp(a.status,'PASS'));
    s=load(fullfile(cfg.dest,'summary.mat'),'summary'); r=s.summary;
    network=[]; targets=[]; trials=[]; controls=[]; paired=[]; count=0;
    networkFields={'convergence','pr','r2','bias','dispersion','mo','peakTime','peakSpeed','endpoint','separation','shuffle','matched'};
    for n=1:10
        for e=1:2
            for v=1:5
                paired(end+1,:)=[n r.eta(e) cfg.pairs(v,:) r.deltaC(n,e,v) r.deltaR2(n,e,v) r.lossPct(n,e,v) ...
                    isfinite(r.lossPct(n,e,v)) r.k(n,e,v) r.observed(n,e,v) r.expected(n,e,v) r.deficit(n,e,v)]; %#ok<AGROW>
                for p=1:2
                    count=count+1; s=load(fullfile(cfg.raw,sprintf('analysis_n%02d_e%d_v%d_p%d.mat',n,e,v,p)),'result'); z=s.result;
                    key=[n r.eta(e) cfg.pairs(v,:) p]; row=key;
                    for name=networkFields, row(end+1)=r.(name{1})(n,e,v,p); end %#ok<AGROW>
                    qc=z.qc;
                    row=[row r.k(n,e,v) r.observed(n,e,v) r.expected(n,e,v) r.deficit(n,e,v) ...
                        z.convergence.undefined z.evaluable z.predictionEvaluable qc.finite qc.prepBounds qc.prepRateMax qc.prepStateMax qc.prepInputMax ...
                        z.bounds qc.movementRateMax qc.movementStateMax qc.nearZero qc.missingWindow qc.boundaryPeak qc.multiPeak ...
                        reshape(r.pc75(n,e,v,p,:),1,2) mean(z.convergence.cue) mean(z.convergence.prego) mean(z.convergence.prego./z.convergence.cue)]; %#ok<AGROW>
                    network(count,:)=row; %#ok<AGROW>
                    for q=1:8
                        targets((count-1)*8+q,:)=[key q z.bias(q) z.cueDistance(q) z.relativeBias(q) z.dispersion(q) z.convergence.targetMean(q) z.movement.endpointRmsByTarget(q)]; %#ok<AGROW>
                    end
                    for j=1:240
                        q=ceil(j/30); fold=z.folds.outer(j); k=z.convergence.k(q,fold); ev=z.convergence.eigenvalues{q,fold};
                        trials((count-1)*240+j,:)=[key q j-(q-1)*30 fold k sum(ev(1:k))/sum(ev) sum(ev(1:k-1))/sum(ev) ...
                            z.convergence.cue(j) z.convergence.prego(j) z.convergence.prego(j)/z.convergence.cue(j) z.convergence.c(j) ...
                            ~isfinite(z.convergence.c(j)) z.movement.moMs(j) z.movement.peakMs(j) z.movement.peak(j) z.movement.nearZero(j) ...
                            z.movement.missingWindow(j) z.movement.boundaryPeak(j) z.movement.multiPeakCount(j)]; %#ok<AGROW>
                    end
                    if z.predictionEvaluable
                        pred=z.prediction;
                        if pred.reusedShuffles, sf=pred.fit; offset=1; else, sf=pred.shuffleFit; offset=0; end
                        for rep=1:100
                            controls(end+1,:)=[key rep sf.r2(rep+offset) sf.lambdaIndex(:,rep+offset).' sf.fullLambdaIndex(rep+offset)]; %#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
    networkNames=[{'network','eta','s_init','s_temporal','condition'},networkFields, ...
        {'Control95K','observed','expected','deficit','undefinedC','evaluable','predictionEvaluable','finite','prepBounds', ...
        'prepRateMax','prepStateMax','prepInputMax','rateLimit','stateLimit','inputLimit','movementRateMax','movementStateMax', ...
        'nearZero','missingWindow','boundaryPeak','multiPeak','prepPC75','movePC75','mean_d_cue','mean_d_prego','mean_ratio'}];
    csv(fullfile(cfg.dest,'network_metrics.csv'),networkNames,network);
    csv(fullfile(cfg.dest,'target_metrics.csv'),{'network','eta','s_init','s_temporal','condition','target','goBias','cueEqDistance','relativeBias','dispersion','C','endpointRmsM'},targets);
    csv(fullfile(cfg.dest,'trial_metrics.csv'),{'network','eta','s_init','s_temporal','condition','target','trial','fold','referenceK95','capture','captureBefore', ...
        'd_cue','d_prego','distanceRatio','C','undefinedC','moMs','peakMs','peakSpeed','nearZero','missingWindow','boundaryPeak','largePeakCount'},trials);
    csv(fullfile(cfg.dest,'shuffle_controls.csv'),{'network','eta','s_init','s_temporal','condition','rep','r2','lambdaIndex1','lambdaIndex2','lambdaIndex3','fullLambdaIndex'},controls);
    csv(fullfile(cfg.dest,'paired_metrics.csv'),{'network','eta','s_init','s_temporal','deltaC','deltaR2','lossPct','lossDefined','Control95K','observed','expected','deficit'},paired);
    headers={'eta','s_init','s_temporal','condition','metric','median','bootstrapSE','availableN'};
    path=fullfile(cfg.dest,'ensemble_summary.csv'); assert(~isfile(path)); fid=fopen(path,'w'); assert(fid>0); closer=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',strjoin(headers,','));
    for name=fieldnames(r.bootstrap).'
        b=r.bootstrap.(name{1}); values=reshape(r.(name{1}),10,2,5,[]); means=reshape(b.median,2,5,[]); se=reshape(b.se,2,5,[]);
        for p=1:size(values,4), for v=1:5, for e=1:2
            condition=p; if size(values,4)==1, condition=0; end
            fprintf(fid,'%.17g,%.17g,%.17g,%d,%s,%.17g,%.17g,%d\n',r.eta(e),cfg.pairs(v,:),condition,name{1},means(e,v,p),se(e,v,p),sum(isfinite(values(:,e,v,p))));
        end, end, end
    end
    clear closer
    receipt=struct('status','PASS','networkRows',size(network,1),'targetRows',size(targets,1),'trialRows',size(trials,1), ...
        'shuffleRows',size(controls,1),'pairedRows',size(paired,1),'conditionEncoding','1=Intact,2=Block; ensemble0=paired/alignment');
    assert(receipt.networkRows==200 && receipt.targetRows==1600 && receipt.trialRows==48000 && receipt.pairedRows==100);
    paper_json(fullfile(cfg.dest,'tables.json'),receipt);
end

function csv(path,names,values)
    assert(~isfile(path) && size(values,2)==numel(names)); fid=fopen(path,'w'); assert(fid>0); closer=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',strjoin(names,',')); format=[repmat('%.17g,',1,size(values,2)-1) '%.17g\n']; fprintf(fid,format,values.');
end
