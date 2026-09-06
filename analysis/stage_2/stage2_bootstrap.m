function summary = stage2_bootstrap(values, indices)
    % The first dimension is network. One shared index matrix for all outputs.
    assert(size(values,1)==10 && size(indices,2)==10);
    values = reshape(values,10,[]);
    draws = size(indices,1);
    bootstrap = zeros(draws,size(values,2));
    for j = 1:size(values,2)
        v = values(:,j);
        bootstrap(:,j) = median(reshape(v(indices),size(indices)),2);
    end
    summary.median = median(values,1);
    summary.se = std(bootstrap,0,1);
end
