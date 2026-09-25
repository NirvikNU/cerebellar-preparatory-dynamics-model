function error=ns_movement_audit(move,m)
    error=0; speed=sqrt(squeeze(move.hand(:,2,:)).^2+squeeze(move.hand(:,4,:)).^2);
    endpoints=reshape(move.hand(end,[1 3],:),2,240); centers=zeros(2,8); scatter=zeros(8,1);
    for j=1:240
        [peak,ix]=max(speed(:,j)); mo=NaN; if peak>0, mo=find(speed(:,j)>=peak/5,1)-1; end
        assert(abs(peak-move.peak(j))<1e-12 && ix-1==move.peakMs(j) && isequaln(mo,move.moMs(j)));
        assert((peak<=1e-8)==move.nearZero(j) && (ix==1||ix==size(speed,1))==move.boundaryPeak(j));
        assert((~isfinite(mo)||mo+100>size(move.states,1)-1)==move.missingWindow(j));
        previous=-Inf; count=0;
        for t=2:size(speed,1)-1
            if speed(t,j)>speed(t-1,j) && speed(t,j)>=speed(t+1,j) && speed(t,j)>=peak/2 && t-previous>=20
                count=count+1; previous=t;
            end
        end
        assert(count==move.multiPeakCount(j));
        for t=[1 200 599]
            state=reshape(move.theta(t,:,j),4,1); next=reshape(move.theta(t+1,:,j),4,1);
            q1=state(1); q2=state(3); v1=state(2); v2=state(4); a=m.arm;
            coupling=a.M2*a.L1*a.S2; z=coupling*cos(q2);
            mass=[a.I1+a.I2+a.M2*a.L1^2+2*z a.I2+z;a.I2+z a.I2];
            centrifugal=[-coupling*sin(q2)*v2*(2*v1+v2);coupling*sin(q2)*v1^2];
            acceleration=mass\(reshape(move.torque(t,:,j),2,1)-centrifugal-a.B*[v1;v2]);
            expected=state+m.samplingDt*[v1;acceleration(1);v2;acceleration(2)];
            hand=[a.L1*cos(q1)+a.L2*cos(q1+q2);-a.L1*v1*sin(q1)-a.L2*(v1+v2)*sin(q1+q2); ...
                a.L1*sin(q1)+a.L2*sin(q1+q2);a.L1*v1*cos(q1)+a.L2*(v1+v2)*cos(q1+q2)];
            error=max([error;abs(expected-next);abs(hand-reshape(move.hand(t,:,j),4,1))]);
        end
    end
    for q=1:8
        x=endpoints(:,(q-1)*30+(1:30)); centers(:,q)=sum(x,2)/30; scatter(q)=sqrt(sum((x-centers(:,q)).^2,'all')/30);
    end
    distances=zeros(28,1); at=0;
    for q=1:7, for j=q+1:8, at=at+1; distances(at)=norm(centers(:,q)-centers(:,j)); end, end
    error=max([error;abs(scatter-move.endpointRmsByTarget(:));abs(median(distances)/(sum(scatter)/8)-move.targetSeparationToScatter)]);
end
