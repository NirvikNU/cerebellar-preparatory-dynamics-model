function result=submission_null_case(c,repeats,validateCount)
    grid=logspace(-8,4,25);scores=cell(1,2);ranks=zeros(1,2);
    for epoch=1:2
        F=c.features{epoch};mu=mean(F,1);[~,S,V]=svd(F-mu,'econ');ev=diag(S).^2/239;
        rank=find(cumsum(ev)>=.75*sum(ev),1);ranks(epoch)=rank;allScores=(F-mu)*V;scores{epoch}=allScores(:,1:rank);
        assert(isequal(V,c.pca{epoch}.basis)&&isequal(ev,c.pca{epoch}.eigenvalues)&&rank==c.pca{epoch}.rank);
    end
    X=scores{1};Y=scores{2};assert(isequal(ranks,c.unshuffled.ranks));
    unshuffled=pf_ridge(X,Y,c.folds,grid);
    assert(isequal(unshuffled.r2,c.unshuffled.R2)&&isequal(unshuffled.predicted,c.unshuffled.predicted));
    result=struct('network',c.network,'pairID',c.pairID,'policy',c.policy,'initialNoise',c.initialNoise, ...
        'temporalNoise',c.temporalNoise,'repeats',repeats,'seedBase',352000000+100000*c.network, ...
        'ranks',ranks,'R2',zeros(1,repeats),'SSE',zeros(1,repeats),'SST',zeros(1,repeats), ...
        'lambdaIndex',zeros(3,repeats),'innerSSE',zeros(3,25,repeats),'permutations',zeros(240,repeats,'uint16'), ...
        'referenceMaxRelativeInnerSSEError',0,'referenceMaxAbsoluteR2Error',0,'referencePermutationsChecked',validateCount);
    batchSize=100;
    for first=1:batchSize:repeats
        ids=first:min(first+batchSize-1,repeats);responses=zeros(240,size(Y,2),numel(ids));
        for j=1:numel(ids)
            seed=result.seedBase+ids(j);stream=RandStream('mt19937ar','Seed',seed);order=randperm(stream,240).';
            assert(isequal(sort(order),(1:240).'));result.permutations(:,ids(j))=uint16(order);
            responses(:,:,j)=Y(order,:);
        end
        fit=submission_null_fit(X,responses,c.folds,grid);
        subset=find(ids<=validateCount);
        if ~isempty(subset)
            reference=pf_ridge(X,responses(:,:,subset),c.folds,grid);
            diff=abs(fit.innerSSE(:,:,subset)-reference.innerSSE)./max(1,abs(reference.innerSSE));
            lossError=max(diff,[],'all');r2Error=max(abs(fit.r2(subset)-reference.r2));
            assert(isequal(fit.lambdaIndex(:,subset),reference.lambdaIndex),'Submission:PenaltyMismatch','Optimized inner loss changed the selected penalty.');
            assert(lossError<1e-12&&r2Error<1e-12,'Submission:NullReferenceMismatch','Null differs from canonical ridge.');
            refSSE=reshape(sum((reference.actual-reference.predicted).^2,[1 2]),1,[]);
            refSST=reshape(sum((reference.actual-mean(reference.actual,1)).^2,[1 2]),1,[]);
            assert(max(abs(fit.SSE(subset)-refSSE)./max(1,abs(refSSE)))<1e-12);
            assert(max(abs(fit.SST(subset)-refSST)./max(1,abs(refSST)))<1e-12);
            assert(max(abs(fit.predicted(:,:,subset)-reference.predicted),[],'all')<1e-10);
            result.referenceMaxRelativeInnerSSEError=max(result.referenceMaxRelativeInnerSSEError,lossError);
            result.referenceMaxAbsoluteR2Error=max(result.referenceMaxAbsoluteR2Error,r2Error);
        end
        result.R2(ids)=fit.r2;result.SSE(ids)=fit.SSE;result.SST(ids)=fit.SST;
        result.lambdaIndex(:,ids)=fit.lambdaIndex;result.innerSSE(:,:,ids)=fit.innerSSE;
    end
    assert(isequal(result.R2,1-result.SSE./result.SST));
    result.status='PASS';result.unshuffledExact=true;result.all240TrialsRetained=true;
end
