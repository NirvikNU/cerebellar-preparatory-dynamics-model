function c = stage3_biological_controller(m,d,frozen)
    % Candidate state-feedback analogue; exact frozen Stage-2 CARE matrices.
    assert(frozen.lambda==.1 && d.alpha==.1 && d.betaNormalized==1);
    c.Q=frozen.Q; c.P=frozen.P; c.L=c.P/frozen.lambda; c.lambda=.1;
    raw=(m.Qnative+m.Qnative.')/2;
    assert(isequal(c.Q,m.n*raw/trace(raw)));
    c.stateDesignA=m.W-eye(m.n); c.stateDesignB=eye(m.n);
    residual=c.stateDesignA.'*c.P+c.P*c.stateDesignA-c.P*c.P/.1+c.Q;
    c.careResidual=norm(residual,'fro')/max(1,norm(c.Q,'fro'));
    c.signError=norm(c.L+frozen.K,'fro');
    eq=[m.xstar d.xB]; c.intrinsicSpectra=zeros(m.n,16);
    for q=1:16
        c.intrinsicSpectra(:,q)=eig(-eye(m.n)+m.W.*(eq(:,q)>0).');
    end
    c.zeroGainWorstPole=max(real(c.intrinsicSpectra),[],'all')/m.tau;
    c.kappa0=max(0,1+max(real(c.intrinsicSpectra),[],'all'));
    c.oldKappa=d.kappa;
    c.residualSpectra=(c.intrinsicSpectra-c.kappa0)/m.tau;
    c.intactSpectra=zeros(m.n,8);
    for q=1:8
        c.intactSpectra(:,q)=eig((-eye(m.n)+m.W.*(m.xstar(:,q)>0).' ...
            -c.kappa0*eye(m.n)-c.L)/m.tau);
    end
    c.residualWorstPole=max(real(c.residualSpectra),[],'all');
    c.intactWorstPole=max(real(c.intactSpectra),[],'all');
    c.eulerRadius=max(abs(1+m.dt*[c.residualSpectra(:);c.intactSpectra(:)]));
    c.fB=-d.xB+m.W*max(d.xB,0)+m.h;
    c.fStar=-m.xstar+m.W*max(m.xstar,0)+m.h;
    c.b=c.fB-c.fStar+c.kappa0*(m.xstar-d.xB);
    x=reshape(sin(1:m.n*8),m.n,8); f=-x+m.W*max(x,0)+m.h;
    u0=-c.fB-c.kappa0*(x-d.xB); fb=-c.L*(x-m.xstar);
    ri=f-c.fStar-(c.kappa0*eye(m.n)+c.L)*(x-m.xstar);
    rb=f-c.fB-c.kappa0*(x-d.xB);
    c.policyIdentityError=max([max(abs(f+u0+c.b+fb-ri),[],'all'), ...
        max(abs(f+u0-rb),[],'all')]);
    c.equilibriumError=max(abs(c.fStar-c.fB-c.kappa0*(m.xstar-d.xB)+c.b),[],'all');
    % Inactive-state coordinates require W*D, not D*W or the all-active A.
    h=1e-6; e=m.xstar(:,1); shift=h*eye(m.n);
    fd=((-e-shift+m.W*max(e+shift,0)+m.h) ...
        -(-e+shift+m.W*max(e-shift,0)+m.h))/(2*h);
    exact=-eye(m.n)+m.W.*(e>0).';
    c.jacobianDifference=norm(fd-exact,'fro')/max(1,norm(exact,'fro'));
    c.stateRateFeedbackDifference=norm(c.L*((x-m.xstar) ...
        -(max(x,0)-max(m.xstar,0))),'fro');
    % A basis-change unit test verifies the state quadratic and feedback map.
    order=m.n:-1:1; v=x(:,1)-m.xstar(:,1); vp=v(order);
    Qp=c.Q(order,order); Lp=c.L(order,order); Lv=c.L*v;
    c.coordinateError=max(abs(v.'*c.Q*v-vp.'*Qp*vp),norm(Lp*vp-Lv(order)));
    [basis,D]=eig((c.L+c.L.')/2); [ev,ix]=sort(diag(D),'descend');
    c.gainEigenvalues=ev; c.gainBasis=basis(:,ix);
    c.gainRank=sum(ev>m.n*eps(max(ev)));
    c.gainParticipationRatio=sum(ev.^2)^2/sum(ev.^4);
    c.gainK95=find(cumsum(ev.^2)>.95*sum(ev.^2),1);
    B=c.gainBasis(:,1:c.gainK95);
    c.strongGainQFraction=trace(B.'*c.Q*B)/trace(c.Q);
    c.isotropicQFraction=c.gainK95/m.n;
    c.gainDirectionQ=diag(c.gainBasis.'*c.Q*c.gainBasis);
    assert(c.careResidual<1e-7 && c.signError<1e-9);
    assert(c.policyIdentityError<1e-10 && c.equilibriumError<1e-10);
    assert(c.jacobianDifference<1e-7 && c.coordinateError<1e-9);
    assert(c.residualWorstPole<=-1/m.tau+1e-9);
    assert(c.intactWorstPole<0 && c.eulerRadius<1);
end
