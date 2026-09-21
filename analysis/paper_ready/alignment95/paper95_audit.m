function audit = paper95_audit(root)
    addpath(fullfile(root,'analysis','stage_3')); cfg=stage3_bio_paths(root);
    dest=fullfile(root,'results','paper_ready','alignment95'); cache=fullfile(root,'results','paper_ready','cache','alignment95');
    gridAudit=jsondecode(fileread(fullfile(dest,'grid_audit.json'))); assert(strcmp(gridAudit.status,'PASS'));
    s=load(fullfile(dest,'controls.mat'),'result'); controls=s.result;
    audit=struct('checks',0,'maxTransition',0,'maxArm',0,'maxSE',0);
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        s=load(fullfile(cache,sprintf('controls_n%02d.mat',n)));
        targets=repelem(1:8,30); c=s.c; d=s.d;
        for policy=1:4
            p=s.policies{policy}; flags=cfg.policyFlags(policy,:);
            fB=-d.xB+m.W*max(d.xB,0)+m.h;
            fS=-m.xstar+m.W*max(m.xstar,0)+m.h;
            b=fB-fS+c.kappa0*(m.xstar-d.xB);
            for a=p.audit
                xx=a.x; u0=-fB(:,targets)-c.kappa0*(xx-d.xB(:,targets));
                cb=flags(1)*b(:,targets)-flags(2)*c.L*(xx-m.xstar(:,targets));
                pred=xx+m.dt/m.tau*(-xx+m.W*max(xx,0)+m.h+u0+cb)+a.noiseIncrement;
                audit.maxTransition=max(audit.maxTransition,max(abs(pred-a.next),[],'all'));
                audit.checks=audit.checks+1;
            end
            move=s.moves{policy}; speed=sqrt(squeeze(move.hand(:,2,:)).^2+squeeze(move.hand(:,4,:)).^2);
            [pk,pi]=max(speed,[],1); assert(max(abs(pk-move.peak))<1e-12 && isequal(pi-1,move.peakMs));
            for trial=1:240
                if pk(trial)>0, onset=find(speed(:,trial)>=.2*pk(trial),1)-1; else, onset=NaN; end
                assert(isequaln(onset,move.moMs(trial))); audit.checks=audit.checks+1;
                count=0; lastPeak=-Inf;
                for sample=2:size(speed,1)-1
                    v=speed(sample,trial);
                    if v>speed(sample-1,trial) && v>=speed(sample+1,trial) && v>=.5*pk(trial) && sample-lastPeak>=20
                        count=count+1; lastPeak=sample;
                    end
                end
                assert(count==move.multiPeakCount(trial)); audit.checks=audit.checks+1;
            end
            assert(isequal(pk<=1e-8,move.nearZero));
            assert(isequal(pi==1|pi==size(speed,1),move.boundaryPeak));
            assert(isequal(pk<=0|move.moMs+100>m.nSamples-1,move.missingWindow));
            audit.checks=audit.checks+3;
            for t=[1 200 599]
                if t>size(move.torque,1), continue; end
                q=squeeze(move.theta(t,:,:)); tq=squeeze(move.torque(t,:,:));
                q1=q(1,:); v1=q(2,:); q2=q(3,:); v2=q(4,:); arm=m.arm;
                a1=arm.I1+arm.I2+arm.M2*arm.L1^2; a2=arm.M2*arm.L1*arm.S2; a3=arm.I2;
                m11=a1+2*a2*cos(q2); m12=a3+a2*cos(q2); m22=a3;
                rhs=tq-[-a2*sin(q2).*v2.*(2*v1+v2);a2*sin(q2).*v1.^2]-arm.B*[v1;v2];
                detm=m11*m22-m12.^2;
                acc=[(m22*rhs(1,:)-m12.*rhs(2,:))./detm;(m11.*rhs(2,:)-m12.*rhs(1,:))./detm];
                next=[q1+m.samplingDt*v1;v1+m.samplingDt*acc(1,:);q2+m.samplingDt*v2;v2+m.samplingDt*acc(2,:)];
                audit.maxArm=max(audit.maxArm,max(abs(next-squeeze(move.theta(t+1,:,:))),[],'all'));
                audit.checks=audit.checks+240;
            end
        end
    end
    for name={'noise','policy','time'}
        values=reshape(controls.(name{1}),10,[]); expected=controls.summary.(name{1});
        for j=1:size(values,2)
            v=values(:,j); medians=median(v(controls.indices),2);
            se=sqrt(sum((medians-mean(medians)).^2)/(numel(medians)-1));
            if isfinite(se)
                audit.maxSE=max(audit.maxSE,abs(se-expected.se(j)));
                assert(abs(median(v)-expected.median(j))<1e-10);
            end
            audit.checks=audit.checks+1;
        end
    end
    assert(audit.maxTransition<1e-9 && audit.maxArm<1e-9 && audit.maxSE<1e-9);
    audit.gridAudit=gridAudit; audit.status='PASS'; audit.predictionRun=false;
    paper_json(fullfile(dest,'independent_audit.json'),audit); disp(audit);
end
