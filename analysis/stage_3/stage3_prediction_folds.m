function folds = stage3_prediction_folds(network,targets)
    targets=targets(:); folds.outer=zeros(size(targets)); folds.inner=zeros(numel(targets),3);
    for q=1:8
        ids=find(targets==q); assert(numel(ids)==30);
        stream=RandStream('mt19937ar','Seed',320000000+10000*network+q);
        ids=ids(randperm(stream,30)); folds.outer(ids)=repelem((1:3).',10);
    end
    for outer=1:3
        for q=1:8
            ids=find(targets==q & folds.outer~=outer); assert(numel(ids)==20);
            stream=RandStream('mt19937ar','Seed',321000000+10000*network+100*outer+q);
            ids=ids(randperm(stream,20)); folds.inner(ids,outer)=mod((0:19).',3)+1;
        end
    end
end
