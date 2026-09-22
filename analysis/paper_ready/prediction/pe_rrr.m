function summary = pe_rrr(root)
    cfg=pe_paths(root); a=jsondecode(fileread(fullfile(cfg.dest,'primary_audit.json'))); assert(strcmp(a.status,'PASS'));
    assert(~isfile(fullfile(cfg.dest,'rrr.mat')));
    s=load(fullfile(cfg.dest,'primary.mat'),'summary'); summary.indices=s.summary.indices;
    summary.rank=zeros(10,4); summary.peak=zeros(10,4); summary.shufflePeak=zeros(10,4,100);
    summary.mean=zeros(10,4,200); summary.se=zeros(10,4,200); summary.threshold=zeros(10,4);
    pool=gcp('nocreate'); owned=isempty(pool);
    if owned, pool=parpool('Threads',20); end
    cleanup=onCleanup(@()releasePool(pool,owned));
    started=tic;
    for n=1:10
        for p=1:4
            output=fullfile(cfg.raw,sprintf('rrr_n%02d_p%d.mat',n,p)); assert(~isfile(output));
            s=load(fullfile(cfg.raw,sprintf('primary_n%02d_p%d.mat',n,p)),'result'); prior=s.result;
            X=prior.features.X{1}; Y=prior.features.X{2}; perm=prior.permutations;
            correspondence=[(1:size(Y,1)).' perm];
            folds=cell(1,10);
            for repeat=1:10, folds{repeat}=stage3_prediction_folds(n+100*(repeat-1),prior.features.targets); end
            curves=zeros(101,10,200); selected=zeros(101,10,3,200,'uint8');
            losses=cell(101,1); realFits=cell(101,1); grid=cfg.ridgeGrid;
            parfor shuffle=1:101
                maxNumCompThreads(1);
                yy=Y(correspondence(:,shuffle),:); %#ok<PFBNS> Immutable response shared across correspondence permutations.
                rr=zeros(10,200); ss=zeros(10,3,200,'uint8'); ll=zeros(10,3,25,200); ff=cell(10,1);
                for repeat=1:10
                    fit=pe_rrr_fit(X,yy,folds{repeat},grid,1:200); %#ok<PFBNS> Fixed small shared fold table.
                    rr(repeat,:)=fit.r2; ss(repeat,:,:)=uint8(fit.lambdaIndex); ll(repeat,:,:,:)=fit.innerSSE;
                    if shuffle==1, ff{repeat}=fit; end
                end
                curves(shuffle,:,:)=rr; selected(shuffle,:,:,:)=ss; losses{shuffle}=ll; realFits{shuffle}=ff;
            end
            fit=realFits{1}; clear realFits
            assert(all(selected>=1 & selected<=25,'all') && all(cellfun(@(v)all(isfinite(v),'all'),losses)));
            details=pe_rrr_dimension(squeeze(curves(1,:,:)));
            summary.rank(n,p)=details.rank; summary.peak(n,p)=details.peak;
            summary.mean(n,p,:)=details.mean; summary.se(n,p,:)=details.se; summary.threshold(n,p)=details.threshold;
            for shuffle=1:100
                dd=pe_rrr_dimension(squeeze(curves(shuffle+1,:,:))); summary.shufflePeak(n,p,shuffle)=dd.peak;
            end
            save(output,'curves','selected','losses','fit','folds','perm','details','-v7.3');
            fprintf('Full-space RRR 10 repeats x101 correspondences n%d p%d %.1fs\n',n,p,toc(started));
        end
    end
    summary.rankBootstrap=stage2_bootstrap(summary.rank,summary.indices);
    summary.peakBootstrap=stage2_bootstrap(summary.peak,summary.indices);
    summary.shuffleMedian=median(summary.shufflePeak,3); summary.shuffleBootstrap=stage2_bootstrap(summary.shuffleMedian,summary.indices);
    summary.tests=cell(2,3); summary.p=zeros(2,3); summary.q=zeros(2,3);
    for metric=1:2
        values={summary.rank,summary.peak}; v=values{metric};
        for j=1:3, summary.tests{metric,j}=stage2_signflip(v(:,j+1)-v(:,1),summary.indices); summary.p(metric,j)=summary.tests{metric,j}.p; end
        summary.q(metric,:)=stage2_bh(summary.p(metric,:));
    end
    summary.status='PASS'; summary.elapsedSeconds=toc(started); save(fullfile(cfg.dest,'rrr.mat'),'summary');
    paper_json(fullfile(cfg.dest,'rrr.json'),rmfield(summary,'indices'));
    clear cleanup
end

function releasePool(pool,owned)
    if owned && isvalid(pool), delete(pool); end
end
