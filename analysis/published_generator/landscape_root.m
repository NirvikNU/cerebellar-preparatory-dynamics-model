function [x,info]=landscape_root(m,alpha,x)
    info=struct('converged',false,'iterations',0,'residual',Inf);
    for iteration=0:100
        f=-x+m.W*max(x,0)+m.h+alpha; residual=norm(f,Inf);
        info.iterations=iteration; info.residual=residual;
        if residual<=1e-10, info.converged=true; return; end
        if iteration==100 || ~all(isfinite(x)), return; end
        J=-eye(m.n)+m.W.*(x>0).';
        if rcond(J)<1e-12, step=-pinv(J,1e-12)*f; else, step=-J\f; end
        accepted=false;
        for power=0:20
            eta=2^-power; trial=x+eta*step;
            ft=-trial+m.W*max(trial,0)+m.h+alpha;
            if norm(ft)<=norm(f)*(1-1e-4*eta)
                x=trial; accepted=true; break;
            end
        end
        if ~accepted, return; end
    end
end
