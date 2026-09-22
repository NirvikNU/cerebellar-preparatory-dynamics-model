function result = eta_equations(m,d,c,eta)
    % Independent algebra/active-set audit; no trajectory or parameter fitting.
    f=@(x)-x+m.W*max(x,0)+m.h;
    star=m.xstar; xb=d.xB; k=eta*c.kappa0;
    b=f(xb)-f(star)+k*(star-xb);
    result=struct('eta',eta,'kappa',k,'b',b,'algebraError',0, ...
        'equilibriumError',0,'jacobianError',0,'spectralShiftError',0, ...
        'poles',zeros(200,8,2),'spectralAbscissa',zeros(8,2), ...
        'eulerRadius',zeros(8,2),'minKinkDistance',zeros(8,2));
    probes=reshape(sin(1:1600),200,8);
    decomposed=f(probes)-f(xb)-k*(probes-xb)+b-c.L*(probes-star);
    direct=f(probes)-f(star)-(k*eye(200)+c.L)*(probes-star);
    result.algebraError=max(abs(decomposed-direct),[],'all');
    result.equilibriumError=max(abs(f(star)-f(xb)-k*(star-xb)+b),[],'all');
    for policy=1:2
        if policy==1, equilibrium=star; feedback=c.L; else, equilibrium=xb; feedback=zeros(200); end
        for q=1:8
            x=equilibrium(:,q); gap=min(abs(x)); result.minKinkDistance(q,policy)=gap;
            assert(gap>0,'ETA:Kink','Equilibrium at a ReLU kink: report before local-linear claims.');
            J=(-eye(200)+m.W*diag(double(x>0))-k*eye(200)-feedback)/m.tau;
            h=min(1e-6,gap/4); shifts=h*eye(200);
            plus=(f(x+shifts)-f(x)-k*shifts-feedback*shifts)/m.tau;
            minus=(f(x-shifts)-f(x)+k*shifts+feedback*shifts)/m.tau;
            numerical=(plus-minus)/(2*h);
            result.jacobianError=max(result.jacobianError,norm(numerical-J,'fro')/max(1,norm(J,'fro')));
            poles=eig(J); base=eig((-eye(200)+m.W*diag(double(x>0))-feedback)/m.tau);
            result.spectralShiftError=max(result.spectralShiftError,abs(max(real(poles))-(max(real(base))-k/m.tau)));
            result.poles(:,q,policy)=poles;
            result.spectralAbscissa(q,policy)=max(real(poles));
            result.eulerRadius(q,policy)=max(abs(1+m.dt*poles));
        end
    end
    assert(result.algebraError<1e-10 && result.equilibriumError<1e-10);
    assert(result.jacobianError<1e-7 && result.spectralShiftError<1e-8);
    % Unstable poles are an outcome, never an assertion failure or eta filter.
end
