function receipt=pf_replay_geometry(root,outputRoot,networks)
    % Reproduce all fixed grid cells; the selected point stays 24, never reselected.
    if nargin<3, networks=1:10; end
    source=fullfile(root,'data/paper_ready/final_v3'); frozen=readtable(fullfile(source,'tables/ED7a_network_grid.csv'));
    if ~isfolder(outputRoot), mkdir(outputRoot); end
    alpha=[.1 .2 .35 .5 .75 1]; beta=[.1 .25 .5 .75 1 1.25]; receipt=struct('status','RUNNING','maxError',0,'selectionPerformed',false,'selectedIndex',24); rows=[];
    for n=networks
        z=load(fullfile(source,sprintf('network_%02d.mat',n))); m=z.model; c=z.controller; base=z.definition;
        noise=pf_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
        intact=pf_prepare(m,{base},c,[1 1],.1,.1,noise,m.dt,false,false);
        gi=pf_geometry(intact.meanRates(401:10:501,:,:),z.normalization); gi.k=find(cumsum(gi.eigenvalues)>=.95*sum(gi.eigenvalues),1);
        P=pf_projector(z.referenceCov,gi.k,10000,2026090900+n); den=sum(gi.eigenvalues(1:gi.k)); expected=trace(gi.cov*P)/den;
        for ia=1:6
            definitions=cell(1,6);
            for ib=1:6
                d=base; d.alpha=alpha(ia); d.betaNormalized=beta(ib); d.beta=beta(ib)*sqrt(sum(base.ell)/numel(base.ell));
                rates=mean(max(m.xstar,0),2)+base.scale.*((d.alpha*base.U*diag(sqrt(base.ell))+d.beta*base.V)*base.Z);
                d.xB=rates; mask=rates==0; internal=repmat(min(mean(m.xstar,2),0),1,8); d.xB(mask)=internal(mask);
                if ia==4 && ib==6, assert(max(abs(d.xB-base.xB),[],'all')<1e-12); end
                definitions{ib}=d;
            end
            blocks=pf_prepare(m,definitions,c,[0 0],.1,.1,noise,m.dt,false,false);
            for ib=1:6
                j=(ia-1)*6+ib; gb=pf_geometry(blocks(ib).meanRates(401:10:501,:,:),z.normalization);
                B=gb.basis(:,1:gi.k); observed=trace(B.'*gi.cov*B)/den;
                v=[gb.pr-gi.pr 100*(expected-observed)]; ix=frozen.network==n & frozen.gridIndex==j;
                expectedRow=[frozen.deltaPR(ix) frozen.deficitPP(ix)];
                receipt.maxError=max(receipt.maxError,max(abs(v-expectedRow))); assert(receipt.maxError<1e-8,'Frozen grid mismatch: stop.');
                rows=[rows;n j alpha(ia) beta(ib) v]; %#ok<AGROW> Fixed 360 cells, no reselection.
            end
        end
        fprintf('Frozen calibration grid reproduced without selection: network %d\n',n);
    end
    receipt.status='PASS'; receipt.rows=rows; pf_json(fullfile(outputRoot,'validation.json'),receipt);
end
