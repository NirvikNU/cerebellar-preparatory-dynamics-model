function [roots,attempts]=landscape_roots(m,alpha,seeds,roots)
    if nargin<4, roots=zeros(m.n,0); end
    attempts=zeros(size(seeds,2),3);
    for j=1:size(seeds,2)
        [x,info]=landscape_root(m,alpha,seeds(:,j));
        attempts(j,:)=[info.converged info.residual info.iterations];
        if info.converged
            if isempty(roots) || all(vecnorm(roots-x)>1e-7*max(1,norm(x)))
                roots(:,end+1)=x; %#ok<AGROW>
            end
        end
    end
end
