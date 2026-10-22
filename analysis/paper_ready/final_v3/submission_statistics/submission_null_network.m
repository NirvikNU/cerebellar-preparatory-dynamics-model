function submission_null_network(repo,inputs,dest,networks,repeats)
    addpath(fullfile(repo,'analysis/paper_ready/final_v3/production'));
    if ~isfolder(dest),mkdir(dest);end
    assert(ismember(repeats,[2000 4000 8000]));
    for n=networks
        file=fullfile(dest,sprintf('null_network_%02d.mat',n));assert(~isfile(file));
        z=load(fullfile(inputs,sprintf('features_network_%02d.mat',n)));assert(numel(z.cases)==23);
        started=tic;items=cell(23,1);
        for j=1:23
            items{j}=submission_null_case(z.cases(j),repeats,16);
            fprintf('Null PASS n%02d pair%02d policy%d, %d shuffles\n',n,z.cases(j).pairID,z.cases(j).policy,repeats);
        end
        results=vertcat(items{:});seconds=toc(started);save(file,'results','seconds','-v7');
        check=load(file);assert(isequaln(check.results,results));
        pf_json(fullfile(dest,sprintf('network_%02d_receipt.json',n)),struct('status','PASS','network',n, ...
            'cases',23,'repeats',repeats,'elapsedSeconds',seconds,'allOriginalUnshuffledExact',true, ...
            'canonicalRidgePermutationsPerCase',16,'readbackExact',true));
    end
end
