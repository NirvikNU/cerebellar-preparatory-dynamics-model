function audit = test_stage3_derivation(root)
    % Independent synthetic covariance and arbitrary-state algebra preflight.
    if nargin<1, root=fileparts(fileparts(fileparts(mfilename('fullpath')))); end
    stream=RandStream('mt19937ar','Seed',2026090810);
    Z0=sqrt(7)*null(ones(1,8)).';
    audit=struct('maxPRError',0,'maxPRDifferenceError',0,'maxAIError',0, ...
        'maxControllerIdentityError',0,'syntheticCases',0,'flatSpectrumChecked',true);
    for d=1:7
        [basis,~]=qr(randn(stream,40,2*d),0); U=basis(:,1:d); V=basis(:,d+1:end);
        for flat=[false true]
            if flat, ell=ones(d,1); else, ell=exp(linspace(-2,2,d)).'; end
            T=sum(ell); S=sum(ell.^2); YI=U*diag(sqrt(ell))*Z0(1:d,:);
            CI=cov(YI.'); PRI=trace(CI)^2/sum(CI.^2,'all');
            for alpha=[.2 1 2]
                for beta=[.1 .7 2]
                    rho=(beta/alpha)^2;
                    YB=(alpha*U*diag(sqrt(ell))+beta*V)*Z0(1:d,:);
                    CB=cov(YB.'); PRB=trace(CB)^2/sum(CB.^2,'all');
                    predicted=(T+d*rho)^2/(S+2*rho*T+d*rho^2);
                    delta=rho*(2*T+d*rho)*(d*S-T^2)/(S*(S+2*rho*T+d*rho^2));
                    [D,e]=eig(CB,'vector'); [~,ix]=sort(e,'descend'); D=D(:,ix(1:d));
                    direct=sum((YI.'*D).^2,'all')/sum(YI.^2,'all');
                    formula=sum(ell.^2./(ell+rho))/T;
                    assert(formula<=max(ell)/(max(ell)+rho)+1e-12);
                    audit.maxPRError=max(audit.maxPRError,abs(PRB-predicted));
                    audit.maxPRDifferenceError=max(audit.maxPRDifferenceError,abs(PRB-PRI-delta));
                    audit.maxAIError=max(audit.maxAIError,abs(direct-formula));
                    if flat || d==1, assert(abs(PRB-PRI)<1e-10); end
                    audit.syntheticCases=audit.syntheticCases+1;
                end
            end
            eta=.3;
            boundary=max([0,(.05*T-min(ell))/(1-.05*d),max(ell)*(1/eta-1)]);
            rho=boundary+1;
            fractions=(ell+rho)/(T+d*rho);
            assert(find(cumsum(sort(fractions,'descend'))>.95,1)==d);
            assert(sum(ell.^2./(ell+rho))/T<eta);
        end
    end
    values=zeros(10,6);
    for member=1:10
        s=load(fullfile(root,'results','stage_1','current','ensemble',sprintf('network_%02d.mat',member)),'model');
        m=s.model; Wnorm=norm(m.W,2); kappa=max(0,Wnorm-1)+3; nu=3;
        f=@(x)-x+m.W*max(x,0)+m.h;
        x=randn(stream,200,8); xB=randn(stream,200,8); star=m.xstar;
        cortical=-f(xB)-kappa*(x-xB);
        b=f(xB)-f(star)+kappa*(star-xB);
        intact=f(x)+cortical+b-nu*(x-star);
        reduced=f(x)-f(star)-(kappa+nu)*(x-star);
        audit.maxControllerIdentityError=max(audit.maxControllerIdentityError,max(abs(intact-reduced),[],'all'));
        block=f(x)+cortical;
        assert(max(abs(block-(f(x)-f(xB)-kappa*(x-xB))),[],'all')<1e-10);
        a=m.dt/m.tau;
        qB=abs(1-a*(1+kappa))+a*Wnorm;
        qI=abs(1-a*(1+kappa+nu))+a*Wnorm;
        assert(qB<1 && qI<1 && nu>=0 && 1+kappa>Wnorm);
        values(member,:)=[Wnorm kappa nu qB qI min(mean(max(star,0),2))];
    end
    assert(audit.maxPRError<1e-10 && audit.maxPRDifferenceError<1e-10);
    assert(audit.maxAIError<1e-10 && audit.maxControllerIdentityError<1e-10);
    audit.networkConstants=array2table(values,'VariableNames', ...
        {'Wnorm','kappa','nu','EulerBlockBound','EulerIntactBound','minimumMeanRate'});
    audit.status='PASS'; disp(audit); disp(audit.networkConstants);
end
