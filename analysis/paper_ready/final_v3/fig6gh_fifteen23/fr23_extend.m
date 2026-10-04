function [chosen,addedStrata,extraDraws]=fr23_extend(groups,prior,seed)
    % Preserve original ten; continue the same RNG without screening outcomes.
    assert(isequal(size(groups),[10 3]) && numel(prior)==10);
    stream=RandStream('mt19937ar','Seed',seed); originalDraws=randi(stream,3,10,1);
    expected=groups(sub2ind([10 3],(1:10).',originalDraws)); assert(isequal(prior(:),expected));
    addedStrata=randperm(stream,10,5).'; extraDraws=zeros(5,1); extra=zeros(5,1);
    for k=1:5
        stratum=addedStrata(k); available=groups(stratum,groups(stratum,:)~=prior(stratum));
        assert(numel(available)==2); extraDraws(k)=randi(stream,2); extra(k)=available(extraDraws(k));
    end
    chosen=[prior(:);extra]; assert(numel(unique(chosen))==15);
end
