function export_null_audit(repo,source,dest)
    assert(~isfolder(dest));mkdir(dest);addpath(fullfile(repo,'analysis/paper_ready/final_v3/production'));
    fid=fopen(fullfile(dest,'draws_float64le.bin'),'w','ieee-le');assert(fid>0);guard=onCleanup(@()fclose(fid));index=cell(230,1);at=0;
    for n=1:10
        z=load(fullfile(source,sprintf('null_network_%02d.mat',n)));
        for j=1:numel(z.results)
            at=at+1;c=z.results(j);assert(fwrite(fid,[c.R2;c.SSE;c.SST],'double')==3*c.repeats);
            index{at}=struct('network',n,'pairID',c.pairID,'policy',c.policy,'repeats',c.repeats);
        end
    end
    clear guard
    pf_json(fullfile(dest,'draws_index.json'),vertcat(index{:}));
end
