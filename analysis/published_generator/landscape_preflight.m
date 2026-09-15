function receipt=landscape_preflight(root)
    c=landscape_paths(root); assert(isfile(fullfile(c.manifest,'INPUTS_BEFORE.csv')));
    assert(~isfile(fullfile(c.land,'preflight.json')));
    receipt=revalidate_stage1_accepted_ensemble(root);
    receipt.wrapperError=0; receipt.spontaneousResidual=0;
    for n=1:10
        p=fullfile(c.cache,sprintf('baseline_%02d.mat',n)); assert(~isfile(p));
        s=load(fullfile(c.gate1.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        base=landscape_trace(m,m.xstar);
        old=simulate_published_cortex(m,m.xstar,true); [theta,hand]=simulate_published_arm(m,old.torque);
        err=max([max(abs(max(base.states,0)-old.rates),[],'all'),max(abs(base.torque-old.torque),[],'all'), ...
            max(abs(base.finalState-old.finalState),[],'all'),max(abs(base.hand-hand),[],'all'),max(abs(base.theta-theta),[],'all')]);
        receipt.wrapperError=max(receipt.wrapperError,err); assert(err<=1e-12);
        residual=norm(-m.spontaneous+m.W*max(m.spontaneous,0)+m.h,Inf);
        receipt.spontaneousResidual=max(receipt.spontaneousResidual,residual); assert(residual<=1e-12);
        distances=zeros(28,1); k=0;
        for q=1:7, for r=q+1:8, k=k+1; distances(k)=norm(m.xstar(:,q)-m.xstar(:,r)); end, end
        scale=median(distances); assert(scale>0);
        if n==1
            e1=m.xstar(:,3)-m.spontaneous; e1=e1/norm(e1);
            [~,peak]=max(hypot(base.hand(:,2,3),base.hand(:,4,3))); assert(peak<=m.nSamples);
            d=base.states(peak,:,3).'-m.xstar(:,3); e2=d-e1*(e1.'*d);
            assert(norm(e2)>1e-10*max(1,norm(d)),'Landscape:Plane','Degenerate predeclared plane axis2');
            plane=[e1 e2/norm(e2)]; receipt.planeAxis2Norm=norm(e2); receipt.planePeakMS=peak-1;
        else
            plane=[];
        end
        save(p,'base','scale','plane','-v7.3');
    end
    receipt.status='PASS'; landscape_json(fullfile(c.land,'preflight.json'),receipt);
    landscape_json(fullfile(c.manifest,'PREFLIGHT.json'),receipt); disp(receipt);
end
