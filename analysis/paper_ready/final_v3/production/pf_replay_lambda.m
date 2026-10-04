function receipt=pf_replay_lambda(root,outputRoot,networks)
    if nargin<3, networks=1:10; end
    source=fullfile(root,'data/paper_ready/final_v3'); frozen=readmatrix(fullfile(source,'tables/Fig6ab_network_values.csv'));
    if ~isfolder(outputRoot), mkdir(outputRoot); end
    lambda=[.1 .2 .5 1 2 5 10 100 Inf]; rows=[]; receipt=struct('status','RUNNING','maximumError',0,'zeroGainEffort',0);
    for n=networks
        z=load(fullfile(source,sprintf('network_%02d.mat',n))); m=z.model;
        prepared=cell(1,9); refFull=[];
        for j=1:9
            if j<9
                derived=pf_lambda_controller(m,lambda(j)); c=z.lambdaControllers{j};
                % Verify the CARE implementation, then replay the accepted gains
                % exactly. Tiny CARE roundoff can perturb a finite null sample.
                assert(max(abs(c.K-derived.K),[],'all')<1e-10 && c.lambda==lambda(j));
            else
                q=(m.Qnative+m.Qnative.')/2;
                c=struct('K',zeros(200),'Q',200*q/trace(q),'specific',m.xstar-m.h-m.W*max(m.xstar,0));
            end
            prepared{j}=pf_lambda_prepare(m,c,struct('preparationMs',500));
            if j==9, assert(prepared{j}.effort==0 && ~any(c.K,'all')); end
            if j==1
                move=simulate_published_cortex(m,squeeze(prepared{j}.states(end,:,:)),true);
                [~,hand]=simulate_published_arm(m,move.torque);
                joined=cat(1,prepared{j}.rates(1:500,:,:),move.rates); refFull=zeros(102,200,8);
                for target=1:8
                    speed=hypot(hand(:,2,target),hand(:,4,target)); mo=find(speed>=.2*max(speed),1)-1;
                    refFull(:,:,target)=joined([(-500:10:0)+501 (-50:10:450)+mo+501],:,target);
                end
            end
        end
        scale=std(matrix(refFull),0,1); normalized=refFull./reshape(scale,1,200,1); normalized=normalized-mean(normalized,3);
        Cfull=cov(matrix(normalized),0); ref=pf_geometry(prepared{1}.rates(401:10:501,:,:),scale);
        for j=1:9
            g=pf_geometry(prepared{j}.rates(401:10:501,:,:),scale); k=max(ref.k,g.k); den=sum(ref.eigenvalues(1:k));
            observed=trace(g.basis(:,1:k).'*ref.cov*g.basis(:,1:k))/den;
            null=pf_lambda_null(Cfull,ref.cov,den,k,1000,20260908+n);
            values=[g.pr-ref.pr 100*(mean(null)-observed)];
            expected=frozen(frozen(:,1)==n & frozen(:,2)==j,end-1:end);
            assert(isequal(size(expected),[1 2])); receipt.maximumError=max(receipt.maximumError,max(abs(values-expected)));
            if receipt.maximumError>=1e-8
                evidence=struct('network',n,'point',j,'computed',values,'expected',expected,'k',k,'denominator',den,'observed',observed,'expectedAlignment',mean(null));
                pf_json(fullfile(outputRoot,'FAILURE.json'),evidence);
                error('Production:LambdaMismatch','Frozen lambda source differs; no scientific correction authorized.');
            end
            rows=[rows;n j lambda(j) values k prepared{j}.effort]; %#ok<AGROW> Fixed 90 rows.
        end
        fprintf('Frozen anticipatory-control sweep reproduced: network %d\n',n);
    end
    receipt.status='PASS'; receipt.rows=rows; pf_json(fullfile(outputRoot,'validation.json'),receipt);
end

function X=matrix(rates)
    X=reshape(permute(rates,[1 3 2]),[],size(rates,2));
end
