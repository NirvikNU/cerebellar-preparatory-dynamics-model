function a=landscape_audit(root)
    c=landscape_paths(root); loaded=load(fullfile(c.land,'summary.mat'),'s'); s=loaded.s;
    a=struct('status','running','roots',0,'metricCases',0,'maxRootResidual',0,'maxLinearRootError',0, ...
        'maxJacobianDifference',0,'maxMetricError',0,'maxIncrementError',0,'maxBootstrapError',0,'maxArrowError',0);
    target=load(fullfile(c.gate1.targetRoot,'stage1_gate1_targets.mat'),'target');
    desired=target.target.initialHand([1 3])+target.target.endpointDisplacement;
    for n=1:10
        loaded=load(fullfile(c.gate1.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=loaded.model;
        loaded=load(fullfile(c.cache,sprintf('baseline_%02d.mat',n))); base=loaded.base;
        d=load(fullfile(c.land,sprintf('network_%02d.mat',n)));
        distances=zeros(28,1); k=0;
        for q=1:7, for t=q+1:8, k=k+1; distances(k)=sqrt(sum((m.xstar(:,q)-m.xstar(:,t)).^2)); end, end
        assert(abs(d.scale-median(distances))<1e-12);
        assert(max(abs(sum(d.directions.^2,1)-1))<1e-12);
        chosen=[1:5 196:200]; Q=(m.Qnative+m.Qnative.')/2;
        assert(norm(Q*d.directions(:,1:10)-d.directions(:,1:10).*d.lambda(chosen).','fro')<1e-9);
        stream=RandStream('mt19937ar','Seed',2026091600+n); random=randn(stream,m.n,10); random=random./sqrt(sum(random.^2,1));
        assert(max(abs(random-d.directions(:,11:20)),[],'all')<1e-12);
        loaded=load(fullfile(c.cache,sprintf('landscape_%02d.mat',n)),'result'); r=loaded.result;
        stream=RandStream('mt19937ar','Seed',2026091500+n); rd=randn(stream,m.n,3); rd=rd./sqrt(sum(rd.^2,1));
        expectedSeeds=[m.spontaneous+.01*d.scale*rd m.spontaneous-.01*d.scale*rd];
        assert(max(abs(r.seeds(:,end-5:end)-expectedSeeds),[],'all')<1e-12);
        for g=1:3
          for sign=1:2
            ids=d.classes(d.directionIds)==g & d.signs==s.signs(sign);
            direct=mean(d.metric(ids,:,:),1); saved=reshape(s.values(n,g,sign,:,:),1,6,7);
            assert(isequal(isnan(direct),isnan(saved)));
            assert(max(abs(direct(isfinite(direct))-saved(isfinite(saved))))<1e-10);
          end
        end
        assert(max(abs(mean(r.speed,2).'-s.speed(n,:)))<1e-12);
        same=mean(r.distance,2).'; good=isfinite(same);
        assert(isequal(good,isfinite(s.distance(n,:))));
        assert(all(abs(same(good)-s.distance(n,good))<1e-12));
        for i=1:numel(c.alpha)
            roots=r.roots{i};
            for j=1:size(roots,2)
                x=roots(:,j); D=diag(double(x>0)); M=-eye(m.n)+m.W*D;
                residual=max(abs(-x+m.W*max(x,0)+m.h+c.alpha(i)));
                a.maxRootResidual=max(a.maxRootResidual,residual); assert(residual<=1e-10);
                y=(eye(m.n)-m.W*D)\(m.h+c.alpha(i)); err=norm(y-x);
                a.maxLinearRootError=max(a.maxLinearRootError,err); assert(err<1e-7*max(1,norm(x)));
                assert(abs(max(real(eig(M/m.tau)))-r.poles{i}(j))<1e-8);
                assert(r.kinks{i}(j)==any(abs(x)<=1e-8));
                for column=[1 51 101 151 200]
                    h=min(1e-5,abs(x(column))/4);
                    if h<1e-9, continue; end
                    xp=x; xm=x; xp(column)=xp(column)+h; xm(column)=xm(column)-h;
                    numeric=((-xp+m.W*max(xp,0))-(-xm+m.W*max(xm,0)))/(2*h*m.tau);
                    err=max(abs(numeric-M(:,column)/m.tau)); a.maxJacobianDifference=max(a.maxJacobianDifference,err); assert(err<1e-5);
                end
                if j<size(roots,2), assert(all(vecnorm(roots(:,j+1:end)-x)>1e-7*max(1,norm(x)))); end
                a.roots=a.roots+1;
            end
        end
        for i=1:size(r.links,1)
            row=r.links(i,:);
            if all(row(4:6))
                left=r.roots{row(1)}(:,row(2)); right=r.roots{row(1)+1}(:,row(3));
                middle=(left+right)/2; drive=mean(c.alpha(row(1)+(0:1)));
                assert(norm(-middle+m.W*max(middle,0)+m.h+drive,Inf)<1e-9);
            end
        end
        for time=1:m.nSamples
            roots=r.exactRoots{time}; x=squeeze(base.states(time,:,:)); stable=false(1,size(roots,2));
            for j=1:size(roots,2)
                y=roots(:,j); assert(norm(-y+m.W*max(y,0)+m.h+r.drive(time),Inf)<=1e-10);
                pole=max(real(eig((-eye(m.n)+m.W*diag(double(y>0)))/m.tau)));
                stable(j)=pole< -1e-7 && all(abs(y)>1e-8);
            end
            for q=1:8
                if any(stable)
                    value=min(sqrt(sum((roots(:,stable)-x(:,q)).^2,1)));
                    assert(abs(value-r.distance(time,q))<1e-10);
                else
                    assert(isnan(r.distance(time,q)));
                end
            end
        end
        if n==1
            assert(norm(r.plane.'*r.plane-eye(2),'fro')<1e-12);
            for phase=1:3
              for point=[1 101 481 961]
                coordinate=[r.xx(point);r.yy(point)]; x=m.spontaneous+r.plane*coordinate;
                expected=r.plane.'*(-x+m.W*max(x,0)+m.h+r.snapshotAlpha(phase))/m.tau;
                arrows=reshape(r.flow(:,:,:,phase),[],2);
                err=max(abs(arrows(point,:).'-expected)); a.maxArrowError=max(a.maxArrowError,err); assert(err<1e-10);
              end
            end
        end
        for amp=2:6
            loaded=load(fullfile(c.cache,sprintf('perturb_n%02d_a%d.mat',n,amp)),'out','values'); out=loaded.out;
            delta=out.initial-m.xstar(:,d.targetIds);
            assert(max(abs(vecnorm(delta)-c.fractions(amp)*d.scale))<1e-12);
            expected=c.fractions(amp)*d.scale*d.directions(:,d.directionIds).*d.signs;
            assert(max(abs(delta-expected),[],'all')<1e-12);
            gain=max(out.nativeNorm,[],1)./out.nativeNorm(1,:);
            assert(max(abs(gain-out.maxAmplification))<1e-10);
            [~,maximumIndex]=max(out.nativeNorm,[],1);
            assert(max(abs((maximumIndex-1)*m.dt-out.maxAmplificationTime))<1e-12);
            select=find(ismember(d.targetIds,[1 3 8]) & ismember(d.directionIds,[1 6 11 20]));
            for j=select
                q=d.targetIds(j); speed=sqrt(out.hand(:,2,j).^2+out.hand(:,4,j).^2);
                bs=sqrt(base.hand(:,2,q).^2+base.hand(:,4,q).^2); mo=find(bs>=max(bs)/5,1);
                dh=out.hand(mo+(0:200),[1 3],j)-base.hand(mo+(0:200),[1 3],q);
                e=out.hand(end,[1 3],j); eb=base.hand(end,[1 3],q);
                values=[max(out.nativeNorm(:,j))/norm(delta(:,j)),1000*norm(dh,'fro')/sqrt(201), ...
                    1000*norm(e-eb),max(speed)-max(bs),1000*norm(e-desired(q,:)), ...
                    1000*(norm(e-desired(q,:))-norm(eb-desired(q,:))), ...
                    norm(out.torque(:,:,j)-base.torque(:,:,q),'fro')/sqrt(numel(out.torque(:,:,j)))];
                err=max(abs(values-loaded.values(j,:))); a.maxMetricError=max(a.maxMetricError,err); assert(err<1e-9); a.metricCases=a.metricCases+1;
                for time=[1 101 501]
                    x=out.states(time,:,j).';
                    for step=(time-1)*5:(time-1)*5+4
                        x=x+m.dt*(-x+m.W*max(x,0)+m.h+published_movement_input(step*m.dt,m))/m.tau;
                    end
                    err=max(abs(x-out.states(time+1,:,j).')); a.maxIncrementError=max(a.maxIncrementError,err); assert(err<1e-10);
                    expectedNorm=norm(out.states(time,:,j).'-base.states(time,:,q).');
                    assert(abs(expectedNorm-out.nativeNorm((time-1)*5+1,j))<1e-10);
                end
                for time=[1 101 501]
                    state=out.theta(time,:,j); z=m.arm; q1=state(1); q2=state(3); v1=state(2); v2=state(4);
                    xy=[z.L1*cos(q1)+z.L2*cos(q1+q2),-z.L1*v1*sin(q1)-z.L2*(v1+v2)*sin(q1+q2), ...
                        z.L1*sin(q1)+z.L2*sin(q1+q2),z.L1*v1*cos(q1)+z.L2*(v1+v2)*cos(q1+q2)];
                    assert(max(abs(xy-out.hand(time,:,j)))<1e-12);
                    A=z.I1+z.I2+z.M2*z.L1^2+2*z.M2*z.L1*z.S2*cos(q2);
                    B=z.I2+z.M2*z.L1*z.S2*cos(q2); D=z.I2; H=z.M2*z.L1*z.S2*sin(q2);
                    rhs=out.torque(time,:,j).'-[-H*v2*(2*v1+v2);H*v1^2]-z.B*[v1;v2];
                    acceleration=[D*rhs(1)-B*rhs(2);A*rhs(2)-B*rhs(1)]/(A*D-B^2);
                    next=state+m.samplingDt*[v1 acceleration(1) v2 acceleration(2)];
                    assert(max(abs(next-out.theta(time+1,:,j)))<1e-10);
                end
            end
        end
        fprintf('Independent landscape audit network%d/10 PASS\n',n);
    end
    previous=rng; guard=onCleanup(@()rng(previous)); rng(c.bootstrapSeed,'twister');
    indices=zeros(10000,10); for draw=1:10000, indices(draw,:)=randi(10,10,1).'; end
    values=reshape(s.values,10,[]); values=values(:,s.validColumns);
    for column=1:size(values,2)
        v=values(:,column); draws=median(reshape(v(indices),10000,10),2);
        se=sqrt(sum((draws-mean(draws)).^2)/9999);
        err=abs(se-s.bootstrap.standardError(column)); a.maxBootstrapError=max(a.maxBootstrapError,err); assert(err<1e-10);
        assert(median(v)==s.bootstrap.median(column));
    end
    complete=all(isfinite(s.distance),1);
    curves=[s.distance(:,complete) s.speed];
    savedSE=[s.distanceSE(complete) s.speedBootstrap.standardError];
    savedMedian=[s.distanceMedian(complete) s.speedBootstrap.median];
    for column=1:size(curves,2)
        v=curves(:,column); draws=median(reshape(v(indices),10000,10),2);
        se=sqrt(sum((draws-mean(draws)).^2)/9999);
        err=abs(se-savedSE(column)); a.maxBootstrapError=max(a.maxBootstrapError,err); assert(err<1e-10);
        assert(median(v)==savedMedian(column));
    end
    a.status='PASS'; landscape_json(fullfile(c.land,'independent_audit.json'),a);
    landscape_json(fullfile(c.manifest,'AUDIT.json'),a); disp(a);
end
