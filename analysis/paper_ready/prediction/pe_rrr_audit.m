function audit = pe_rrr_audit(root)
    cfg=pe_paths(root); s=load(fullfile(cfg.dest,'rrr.mat'),'summary'); summary=s.summary;
    pool=gcp('nocreate'); owned=isempty(pool); if owned, pool=parpool('Threads',12); end
    cleanup=onCleanup(@()releasePool(pool,owned));
    % V7.3 file IO is not supported on thread workers. Load unchanged evidence
    % on the client; only numerical audit calculations execute in parallel.
    source=cell(40,1); evidence=cell(40,1);
    for caseID=1:40
        n=ceil(caseID/4); p=mod(caseID-1,4)+1;
        loaded=load(fullfile(cfg.raw,sprintf('primary_n%02d_p%d.mat',n,p)),'result');
        source{caseID}=loaded.result;
        evidence{caseID}=load(fullfile(cfg.raw,sprintf('rrr_n%02d_p%d.mat',n,p)));
    end
    rows=cell(40,1);
    parfor caseID=1:40
        maxNumCompThreads(1); n=ceil(caseID/4); p=mod(caseID-1,4)+1;
        base=source{caseID}; s=evidence{caseID};
        X=base.features.X{1}; Y=base.features.X{2};
        row=struct('network',n,'policy',p,'lossError',0,'predictionError',0,'r2Error',0,'dimensionError',0,'checks',0);
        for repeat=1:10
            assert(isequal(s.folds{repeat},stage3_prediction_folds(n+100*(repeat-1),base.features.targets)));
        end
        assert(isequal(s.perm,base.permutations));
        for shuffle=1:101
            for repeat=1:10
                loss=reshape(s.losses{shuffle}(repeat,:,:,:),3,25,200);
                [~,selected]=min(loss,[],2);
                assert(isequal(uint8(reshape(selected,3,200)),reshape(s.selected(shuffle,repeat,:,:),3,200)));
                row.checks=row.checks+600;
            end
            curves=squeeze(s.curves(shuffle,:,:)); mu=sum(curves,1)/10;
            se=sqrt(sum((curves-mu).^2,1)/9)/sqrt(10); peak=max(mu); at=find(mu==peak,1);
            threshold=peak-se(at); crossing=1;
            while mu(crossing)<threshold, crossing=crossing+1; end
            estimatedRank=crossing;
            if crossing>1, estimatedRank=crossing-1+(threshold-mu(crossing-1))/(mu(crossing)-mu(crossing-1)); end
            if shuffle==1
                row.dimensionError=max(abs([estimatedRank-summary.rank(n,p),peak-summary.peak(n,p),threshold-summary.threshold(n,p)])); %#ok<PFBNS> Small immutable comparison summaries.
                assert(max(abs(mu-reshape(summary.mean(n,p,:),1,200)))<1e-12);
                assert(max(abs(se-reshape(summary.se(n,p,:),1,200)))<1e-12);
            else
                assert(abs(peak-summary.shufflePeak(n,p,shuffle-1))<1e-12);
            end
        end
        % Full observed repeated nested searches; one predeclared shuffle/repeat
        % also independently re-fitted. All remaining shuffle selection/rank
        % summaries above are checked from saved search evidence, not re-simulated.
        for repeat=1:10
            fit=s.fit{repeat}; f=s.folds{repeat}; predicted=zeros(240,200,200);
            for o=1:3
                train=f.outer~=o; loss=zeros(25,200);
                for inner=1:3
                    tr=train & f.inner(:,o)~=inner; va=train & f.inner(:,o)==inner;
                    for g=1:25
                        [B,V,xm,ym]=augmented(X(tr,:),Y(tr,:),cfg.ridgeGrid(g)); %#ok<PFBNS> Shared immutable penalty grid.
                        P=(X(va,:)-xm)*B*V; yy=Y(va,:)-ym;
                        loss(g,:)=loss(g,:)+norm(yy,'fro')^2+cumsum(sum(P.^2,1)-2*sum((yy*V).*P,1));
                    end
                end
                row.lossError=max(row.lossError,max(abs(loss-reshape(fit.innerSSE(o,:,:),25,200)),[],'all'));
                [~,best]=min(loss,[],1); assert(isequal(best,fit.lambdaIndex(o,:)),'Independent RRR penalty mismatch');
                for g=unique(best)
                    [B,V,xm,ym]=augmented(X(train,:),Y(train,:),cfg.ridgeGrid(g));
                    factor=fit.factors{o}{g};
                    for rank=find(best==g)
                        actual=(X(~train,:)-xm)*B*V(:,1:rank)*V(:,1:rank).'+ym;
                        k=min(rank,size(factor.right,2));
                        saved=(X(~train,:)-factor.xmean)*factor.Bscore(:,1:k)*factor.right(:,1:k).'+factor.ymean;
                        row.predictionError=max(row.predictionError,max(abs(actual-saved),[],'all'));
                        predicted(~train,:,rank)=actual;
                    end
                end
            end
            for rank=1:200
                value=1-norm(Y-predicted(:,:,rank),'fro')^2/norm(Y-mean(Y,1),'fro')^2;
                row.r2Error=max(row.r2Error,abs(value-s.curves(1,repeat,rank)));
            end
        end
        yy=Y(base.permutations(:,1),:); f=s.folds{1}; loss=s.losses{2}; err=0;
        for o=1:3
            train=f.outer~=o; independent=zeros(25,200);
            for inner=1:3
                tr=train & f.inner(:,o)~=inner; va=train & f.inner(:,o)==inner;
                for g=1:25
                    [B,V,xm,ym]=augmented(X(tr,:),yy(tr,:),cfg.ridgeGrid(g));
                    P=(X(va,:)-xm)*B*V; yr=yy(va,:)-ym;
                    independent(g,:)=independent(g,:)+norm(yr,'fro')^2+cumsum(sum(P.^2,1)-2*sum((yr*V).*P,1));
                end
            end
            err=max(err,max(abs(independent-reshape(loss(1,o,:,:),25,200)),[],'all'));
        end
        row.shuffleLossError=err;
        assert(row.lossError<1e-5 && row.predictionError<1e-7 && row.r2Error<1e-8 && row.dimensionError<1e-12 && err<1e-5);
        rows{caseID}=row;
    end
    audit=struct('status','PASS','cases',{rows},'fullObservedRepeats',400,'independentlyRefitShuffleRepeats',40, ...
        'savedShuffleSearchRepeatsChecked',40000,'method','Independent augmented QR, explicit held-out rank predictions');
    paper_json(fullfile(cfg.dest,'rrr_audit.json'),audit);
    clear cleanup
end

function [B,V,xm,ym]=augmented(X,Y,lambda)
    xm=mean(X,1); ym=mean(Y,1); p=size(X,2);
    Z=[X-xm;sqrt(lambda)*eye(p)]; T=[Y-ym;zeros(p,size(Y,2))];
    [Q,R]=qr(Z,0); projected=Q.'*T; [~,~,V]=svd(projected,'econ'); B=R\projected;
end

function releasePool(pool,owned)
    if owned && isvalid(pool), delete(pool); end
end
