function [target,table,rule]=sp10_choose_target(countI,countB,score10)
    ids=(1:8).'; eligible=countI(:)>=10 & countB(:)>=10; minimum=min(countI(:),countB(:));
    if any(eligible)
        candidates=ids(eligible); rule='primary: at least 10 successes in both conditions';
    else
        candidates=ids(minimum==max(minimum)); rule='fallback: maximize minimum success count';
    end
    ranked=sortrows([score10(candidates).' candidates],[1 2]); target=ranked(1,2);
    rank=nan(8,1); rank(ranked(:,2))=(1:size(ranked,1)).';
    table=[ids countI(:) countB(:) eligible minimum score10(:) ismember(ids,candidates) rank ids==target];
end
