function out=v2_grid_network(input,n)
    % Calibration reads no movement, convergence, prediction or QC outcomes.
    % Client-side V7.3 loading only; workers receive the same immutable arrays.
    m=input.model; ref=input.ref; definitions=input.definitions; c=input.controller;
    assert(c.lambda==10 && m.dt==.0002 && m.tau==.15); c.kappa0=0;
    intact=input.intact;
    assert(input.eta==0 && input.network==n && intact.sInit==.1 && intact.sTemporal==.1);
    ig=paper95_geometry(intact.meanRates(401:10:501,:,:),ref.scale);
    P=input.projectors{ig.k}; Q=input.qrProjectors{ig.k};
    assert(~isempty(P) && abs(trace(P)-ig.k)<1e-8);
    noise=paper_noise(n,repelem(1:8,30),repmat(1:30,1,8),2500);
    assert(isequal(intact.initial,m.spontaneous+.1*noise.initial));
    out.blocks=cell(1,36); out.rows=cell(36,1); out.definition=definitions; out.controller=c;
    for first=1:6:36
        js=first:first+5;
        p=paper_prepare(m,definitions(js),c,[0 0],.1,.1,noise,m.dt,false,false);
        for a=1:6
            j=js(a); d=definitions{j}; g=paper95_geometry(p(a).meanRates(401:10:501,:,:),ref.scale);
            [ob,ex,den,K,capture]=paper95_compare(ig,g,P);
            out.blocks{j}=p(a);
            out.rows{j}=table(n,j,d.alpha,d.betaNormalized,ig.pr,g.pr,g.pr-ig.pr, ...
                100*ob,100*ex,100*(ex-ob),K,ig.captureControl,ig.beforeControl,capture,den, ...
                'VariableNames',{'network','gridIndex','alpha','betaNormalized','prIntact','prBlock','deltaPR', ...
                'observedPct','expectedPct','deficitPP','kControl','captureControl','beforeControl','captureBlock','denominator'});
        end
    end
    out.rows=vertcat(out.rows{:}); out.intactGeometry=ig; out.P=P; out.Q=Q;
    out.intactMean=intact.meanRates(401:10:501,:,:); out.scale=ref.scale;
    out.noiseSeeds=noise.seeds; out.auditError=0; out.geometryError=0;
    % Independent neuron-column covariance/eigen audit, all 360 candidates.
    ai=paper95_direct(out.intactMean,ref.scale); assert(ai.k==ig.k);
    out.geometryError=max(abs(ai.pr-ig.pr));
    targets=noise.targets;
    for j=1:36
        d=definitions{j}; b=out.blocks{j}; ab=paper95_direct(b.meanRates(401:10:501,:,:),ref.scale);
        den=sum(ai.eigenvalues(1:ai.k)); basis=ab.basis(:,1:ai.k);
        ob=trace(basis.'*ai.cov*basis)/den; ex=trace(ai.cov*Q)/den;
        out.geometryError=max([out.geometryError abs(ab.pr-out.rows.prBlock(j)) ...
            abs(100*ob-out.rows.observedPct(j)) abs(100*ex-out.rows.expectedPct(j))]);
        fB=-d.xB+m.W*max(d.xB,0)+m.h;
        for a=b.audit
            increment=.1*sqrt(2*m.dt/m.tau)*noise.process(:,:,a.step+1);
            next=a.x+m.dt/m.tau*(-a.x+m.W*max(a.x,0)+m.h-fB(:,targets))+increment;
            out.auditError=max([out.auditError max(abs(next-a.next),[],'all') ...
                max(abs(increment-a.noiseIncrement),[],'all')]);
        end
        assert(isequal(b.initial,intact.initial));
    end
    % Intact reduced field proves independence from the selected geometry.
    for a=intact.audit
        star=m.xstar(:,targets); fs=-star+m.W*max(star,0)+m.h;
        next=a.x+m.dt/m.tau*(-a.x+m.W*max(a.x,0)+m.h-fs-c.L*(a.x-star))+a.noiseIncrement;
        out.auditError=max(out.auditError,max(abs(next-a.next),[],'all'));
    end
    assert(out.auditError<1e-10 && out.geometryError<1e-8);
end
