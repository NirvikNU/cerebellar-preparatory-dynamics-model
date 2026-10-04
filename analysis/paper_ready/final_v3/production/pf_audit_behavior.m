function receipt=pf_audit_behavior(root,folder,n)
    % Independent all-trial behavioral check using already replayed primary evidence.
    cases=cell(1,2); speed=zeros(1,2);
    for p=1:2
        policies=[1 4]; z=load(fullfile(folder,sprintf('network_%02d_pair2_policy%d.mat',n,policies(p))));
        e=z.evidence; [peak,ix]=max(e.speed,[],1); positions=zeros(240,2);
        for j=1:240, positions(j,:)=e.hand(ix(j),[1 3],j); end
        cases{p}=struct('movement',struct('peak',peak),'peakPosition',positions);
        speed(p)=mean(mean(reshape(peak,30,8),1));
    end
    b=pf_behavior(cases{1},cases{2});
    source=fullfile(root,'data/paper_ready/final_v3/tables');
    values=readmatrix(fullfile(source,'Fig6e_alltrial_peak_speed.csv'));
    matched=readmatrix(fullfile(source,'Fig6f_alltrial_matched_dispersion.csv'));
    unmatched=readmatrix(fullfile(source,'Fig6f_alltrial_unmatched_control.csv'));
    speedError=max(abs(speed-values(values(:,1)==n,2:3)));
    row=matched(matched(:,1)==n,2:3);
    assert(isequal(isnan(row),isnan(b.network)));
    matchedError=max(abs(row-100*b.network),[],'omitnan');
    if isempty(matchedError)||isnan(matchedError), matchedError=0; end
    unmatchedError=max(abs(unmatched(unmatched(:,1)==n,2:3)-100*b.unmatchedNetwork));
    assert(max([speedError matchedError unmatchedError])<1e-9,'Frozen all-trial behavior mismatch');
    receipt=struct('status','PASS','network',n,'speedError',speedError,'matchedErrorCM',matchedError, ...
        'unmatchedErrorCM',unmatchedError,'matching',b,'statisticsRecomputed',false);
    pf_json(fullfile(folder,sprintf('behavior_%02d.json',n)),receipt);
end
