function result = paired_wilcoxon_exact(first, second)
    differences = second(:) - first(:);
    differences = differences(differences ~= 0);
    count = numel(differences);
    assert(count >= 1 && count <= 20);
    ranks = tied_ranks(abs(differences));
    observed = sum(ranks(differences > 0));
    total = sum(ranks);
    centeredObserved = abs(observed - total / 2);
    combinations = dec2bin(0:(2 ^ count - 1)) == '1';
    possible = combinations * ranks;
    centered = abs(possible - total / 2);
    p = sum(centered >= centeredObserved - 1e-12) / numel(possible);
    result.p = min(p, 1);
    result.wPlus = observed;
    result.nNonzero = count;
    result.medianDifference = median(differences);
end

function ranks = tied_ranks(values)
    [sorted, order] = sort(values);
    ranksSorted = zeros(size(sorted));
    index = 1;
    while index <= numel(sorted)
        last = find(sorted == sorted(index), 1, 'last');
        ranksSorted(index:last) = mean(index:last);
        index = last + 1;
    end
    ranks = zeros(size(values));
    ranks(order) = ranksSorted;
end
