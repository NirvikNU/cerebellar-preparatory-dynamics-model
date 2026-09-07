function out = stage2_geometry_population(net,cfg,member)
    % Cache dimensions: time x neuron x target x lambda; cue at GO -500 ms.
    onset=zeros(8,8); peak=zeros(8,8);
    for l=1:8
        hand=net.hand{l};
        for target=1:8
            speed=hypot(hand(:,2,target),hand(:,4,target));
            peak(target,l)=max(speed);
            ix=find(speed>=cfg.speedFraction*peak(target,l),1);
            assert(ix>1 && all(speed(1:ix-1)<cfg.speedFraction*peak(target,l)));
            onset(target,l)=ix-1;
        end
    end
    rawFull=cat(1,epoch(net.rates,cfg.fullGoMs,zeros(8,1),1), ...
        epoch(net.rates,cfg.fullMoMs,onset(:,1),1));
    rawX=stage2_matrix(rawFull);
    out.scale=std(rawX,0,1);
    tolerance=cfg.degeneracyEpsMultiplier*eps(max(1,max(abs(rawX),[],1)));
    assert(all(isfinite(out.scale) & out.scale>tolerance),'Zero/degenerate reference SD: STOP.');
    out.onset=onset; out.peakSpeed=peak;
    full=center(rawFull,out.scale);
    Xfull=stage2_matrix(full);
    Cfull=cov(Xfull,0);
    prep=cell(1,8);
    out.pr=zeros(1,8); out.minimumK=zeros(1,8);
    out.eigenvalues=zeros(8,200);
    out.prError=0; out.varianceError=0; out.directError=0;
    out.centerResidual=max(abs(mean(full,3)),[],'all');
    for l=1:8
        rates=center(epoch(net.rates,cfg.prepEpochMs,zeros(8,1),l),out.scale);
        prep{l}=population(stage2_matrix(rates),cfg.varianceThreshold);
        p=prep{l};
        out.pr(l)=p.pr; out.minimumK(l)=p.minimumK;
        out.eigenvalues(l,:)=p.eigenvalues;
        out.prError=max(out.prError,p.prError);
        out.varianceError=max(out.varianceError,p.varianceError);
        out.centerResidual=max(out.centerResidual,max(abs(mean(rates,3)),[],'all'));
    end
    out.commonK=max(out.minimumK(1),out.minimumK);
    out.observed=zeros(1,8); out.expected=zeros(1,8);
    out.null=zeros(cfg.nullDraws,8);
    out.capturedReference=zeros(1,8); out.capturedComparison=zeros(1,8);
    ref=prep{1};
    for l=1:8
        k=out.commonK(l);
        [out.observed(l),err]=alignment(ref,prep{l},k);
        out.directError=max(out.directError,err);
        den=sum(ref.eigenvalues(1:k));
        previous=find(out.commonK(1:l-1)==k,1);
        if isempty(previous)
            out.null(:,l)=stage2_null(Cfull,ref.covariance,den,k, ...
                cfg.nullDraws,cfg.nullSeedBase+member);
        else
            out.null(:,l)=out.null(:,previous);
        end
        out.expected(l)=mean(out.null(:,l));
        out.capturedReference(l)=sum(ref.eigenvalues(1:k))/sum(ref.eigenvalues);
        out.capturedComparison(l)=sum(prep{l}.eigenvalues(1:k))/sum(prep{l}.eigenvalues);
    end
    pre=population(stage2_matrix(center(epoch(net.rates, ...
        cfg.prepMoveCueMs-cfg.preparationMs,zeros(8,1),1),out.scale)),cfg.varianceThreshold);
    mov=population(stage2_matrix(center(epoch(net.rates, ...
        cfg.prepMoveMoMs,onset(:,1),1),out.scale)),cfg.varianceThreshold);
    out.prepMoveMinimumK=[pre.minimumK mov.minimumK];
    k=max(out.prepMoveMinimumK); out.prepMoveCommonK=k;
    [out.prepMoveObserved,err]=alignment(pre,mov,k);
    out.directError=max(out.directError,err);
    out.prepMoveCaptured=[sum(pre.eigenvalues(1:k))/sum(pre.eigenvalues) ...
        sum(mov.eigenvalues(1:k))/sum(mov.eigenvalues)];
    out.prepMoveEigenvalues=[pre.eigenvalues.';mov.eigenvalues.'];
    out.prepMoveNull=stage2_null(Cfull,pre.covariance,sum(pre.eigenvalues(1:k)), ...
        k,cfg.nullDraws,cfg.nullSeedBase+member);
    out.prepMoveExpected=mean(out.prepMoveNull);
    out.prError=max([out.prError pre.prError mov.prError]);
    out.varianceError=max([out.varianceError pre.varianceError mov.varianceError]);
    assert(all([out.capturedReference out.capturedComparison out.prepMoveCaptured]>.95));
    assert(abs(out.observed(1)-1)<1e-10 && out.directError<1e-10);
    assert(out.prError<1e-10 && out.varianceError<1e-10 && out.centerResidual<1e-10);
end

function rates = epoch(allRates,times,offsets,l)
    rates=zeros(numel(times),size(allRates,2),8);
    for target=1:8
        rows=times+offsets(target)+501;
        assert(all(rows==round(rows) & rows>=1 & rows<=size(allRates,1)),'Missing epoch samples.');
        rates(:,:,target)=allRates(rows,:,target,l);
    end
end

function rates = center(rates,scale)
    rates=rates./reshape(scale,1,[],1);
    rates=rates-mean(rates,3);
end

function p = population(X,threshold)
    X=X-mean(X,1);
    C=(X.'*X)/(size(X,1)-1);
    [V,d]=eig((C+C.')/2,'vector');
    [d,order]=sort(max(d,0),'descend');
    assert(sum(d)>0 && all(isfinite(d)));
    cumulative=cumsum(d)/sum(d);
    k=find(cumulative>threshold,1);
    assert(k==1 || cumulative(k-1)<=threshold);
    sv=svd(X,'econ').^2/(size(X,1)-1);
    sv=[sv;zeros(numel(d)-numel(sv),1)];
    assert(find(cumsum(sv)/sum(sv)>threshold,1)==k);
    p=struct('covariance',C,'basis',V(:,order),'eigenvalues',d,'minimumK',k, ...
        'X',X,'pr',sum(d)^2/sum(d.^2),'prError',abs(sum(d)^2/sum(d.^2)-sum(sv)^2/sum(sv.^2)), ...
        'varianceError',max(abs(cumulative-cumsum(sv)/sum(sv))));
end

function [value,err] = alignment(ref,comparison,k)
    U=comparison.basis(:,1:k); V=ref.basis(:,1:k);
    value=trace(U.'*ref.covariance*U)/sum(ref.eigenvalues(1:k));
    direct=norm(ref.X*U,'fro')^2/norm(ref.X*V,'fro')^2;
    err=abs(value-direct);
    assert(isfinite(value) && value>=-1e-10 && value<=1+1e-8);
end
