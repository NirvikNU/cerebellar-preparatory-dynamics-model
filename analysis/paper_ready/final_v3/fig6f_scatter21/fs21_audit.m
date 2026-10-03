function audit=fs21_audit(root,d,panel,limits,dest,plots,figuresOnly)
    audit=struct('status','PASS','successes',0,'selected',0,'candidatesChecked',0,'maxScoreError',0,'maxPhaseError',0,'reopened',0,'graphicsObjects',0);
    palette=[1 0 .16;1 .601 0;.2549 .4118 .8824;0 1 .1476;.2510 .8784 .8157;.3137 .7843 .4706;.4827 0 1;1 0 .75];
    assert(isequal(d.targetColors,palette));
    if ~figuresOnly
        ledger=readmatrix(fullfile(root,'results/paper_ready/final_v3/fig6fgh_highrms14/all_saved_attempts.csv'));
        assert(size(ledger,1)==12674 && sum(ledger(:,6))==453);
        peaks=readmatrix(fullfile(dest,'all_peak_positions.csv')); selected=readmatrix(fullfile(dest,'selected_trials.csv'));
        quality=readmatrix(fullfile(dest,'scatter_match_quality.csv')); phases=readmatrix(fullfile(dest,'same_four_phase_means.csv'));
        paths=readmatrix(fullfile(dest,'displayed_native_paths.csv'));
        for p=1:2
            c=d.condition{p};
            for q=1:8
                ids=(q-1)*30+(1:c.counts(q)); n=numel(ids); positions=zeros(n,2); allPhase=zeros(101,2,n);
                good=ledger(ledger(:,2)==p & ledger(:,3)==q & ledger(:,6)==1,:);
                assert(isequal(good(:,4),c.attemptID(ids)) && isequal(good(:,5),c.seed(ids)));
                for j=1:n
                    tr=ids(j); hand=c.hand(:,:,tr); xy=hand(:,[1 3])-hand(1,[1 3]); speed=hypot(hand(:,2),hand(:,4));
                    first=find(speed>=max(speed)/5,1); last=find(sum((xy-d.targetXY(q,:)).^2,2)<=.015^2,1);
                    assert(~isempty(last) && last<=600 && first<last && first-1==c.moMs(tr) && last-1==c.endMs(tr));
                    [peakValue,at]=max(speed(1:last)); positions(j,:)=xy(at,:);
                    assert(peakValue==c.peakSpeed(tr) && at-1==c.peakMs(tr) && isequal(positions(j,:),c.peakXY(tr,:)));
                    assert(isequal(xy(1:last,:),c.xy(1:last,:,tr)) && all(isnan(c.xy(last+1:end,:,tr)),'all'));
                    t=linspace(first,last,101).'; low=floor(t); high=min(low+1,last); w=t-low;
                    allPhase(:,:,j)=xy(low,:).*(1-w)+xy(high,:).*w;
                    assert(all(100*xy(1:last,:)>=limits(1,:),'all') && all(100*xy(1:last,:)<=limits(2,:),'all'));
                end
                [fullCenter,fullScatter,fullD]=direct_moments(positions);
                combinations=nchoosek(1:n,4); scores=zeros(size(combinations,1),1);
                for k=1:size(combinations,1)
                    [center,scatter]=direct_moments(positions(combinations(k,:),:));
                    if fullD>0
                        scores(k)=dot(center-fullCenter,center-fullCenter)/(fullD*fullD) ...
                            +sum(sum((scatter-fullScatter).^2))/sum(sum(fullScatter.^2));
                    end
                end
                [best,k]=min(scores); chosen=ids(combinations(k,:)).'; assert(isequal(chosen,panel.chosen(:,q,p)));
                audit.maxScoreError=max(audit.maxScoreError,abs(best-panel.scores(q,p)));
                [center,scatter,D]=direct_moments(c.peakXY(chosen,:));
                row=quality(quality(:,1)==p & quality(:,2)==q,:);
                expected=[p q n size(combinations,1) best fullD D 0 norm(center-fullCenter) 0 fullCenter center ...
                    fullScatter(1,1) fullScatter(1,2) fullScatter(2,2) scatter(1,1) scatter(1,2) scatter(2,2)];
                if fullD>0, expected(8)=100*(D/fullD-1); expected(10)=norm(scatter-fullScatter,'fro')/norm(fullScatter,'fro'); end
                assert(max(abs(expected-row))<1e-10);
                rows=selected(selected(:,2)==p & selected(:,3)==q,:); assert(isequal(rows(:,4),chosen) && all(rows(:,13)==1));
                rows=peaks(peaks(:,2)==p & peaks(:,3)==q,:);
                assert(isequal(rows(:,9:10),positions) && isequal(rows(:,5),c.attemptID(ids)) && sum(rows(:,13))==4);
                local=chosen-(q-1)*30; expectedMean=sum(allPhase(:,:,local),3)/4;
                audit.maxPhaseError=max(audit.maxPhaseError,max(abs(expectedMean-panel.means(:,:,q,p)),[],'all'));
                rows=phases(phases(:,1)==p & phases(:,2)==q,:); assert(isequal(rows(:,4:5),panel.means(:,:,q,p)));
                for tr=chosen.'
                    rows=paths(paths(:,1)==p & paths(:,2)==q & paths(:,3)==c.attemptID(tr),:); last=c.endMs(tr)+1;
                    assert(isequal(rows(:,4),(0:last-1).') && isequal(rows(:,5:6),c.xy(1:last,:,tr)));
                end
                audit.successes=audit.successes+n; audit.selected=audit.selected+4; audit.candidatesChecked=audit.candidatesChecked+numel(scores);
            end
        end
        assert(audit.successes==453 && audit.selected==64 && audit.candidatesChecked==407422);
        assert(audit.maxScoreError<1e-10 && audit.maxPhaseError<1e-13); audit.all16GlobalOptimaVerified=true; return
    end
    f=openfig(fullfile(plots,'fig','Fig6f_scatter_matched.fig'),'invisible'); cleanup=onCleanup(@()close(f));
    thin=0; means=0; circles=0;
    for h=findall(f,'-property','UserData').'
        u=h.UserData; if ~isstruct(u)||~isfield(u,'kind'), continue; end
        p=u.condition; q=u.target;
        if strcmp(u.kind,'peakPositions')
            assert(isequal(u.trials,panel.chosen(:,q,p))); xy=100*d.condition{p}.peakXY(u.trials,:);
            assert(isequal(h.CData,palette(q,:)) && all(h.SizeData==28) && strcmp(h.Marker,'o')); circles=circles+4;
        elseif strcmp(u.kind,'trajectory')
            assert(ismember(u.trial,panel.chosen(:,q,p))); xy=100*d.condition{p}.xy(:,:,u.trial); thin=thin+1;
            assert(h.LineWidth==.65 && isequal(h.Color,palette(q,:)) && strcmp(h.LineStyle,'-'));
        else
            assert(strcmp(u.kind,'fourPhaseMean') && isequal(u.trials,panel.chosen(:,q,p))); xy=100*panel.means(:,:,q,p); means=means+1;
            assert(h.LineWidth==2.4 && isequal(h.Color,palette(q,:)) && strcmp(h.LineStyle,'-'));
        end
        assert(isequaln(h.XData(:),xy(:,1)) && isequaln(h.YData(:),xy(:,2)));
    end
    axs=findall(f,'Type','axes'); assert(numel(axs)==2 && isempty(findall(f,'Type','legend')));
    for ax=axs.'
        assert(isequal(ax.XLim,limits(:,1).') && isequal(ax.YLim,limits(:,2).') && isequal(ax.DataAspectRatio,[1 1 1]));
        assert(strcmp(ax.XLabel.String,'Hand x (cm)') && strcmp(ax.YLabel.String,'Hand y (cm)'));
        for q=1:8
            h=findall(ax,'Tag',sprintf('zone_%d',q)); assert(isscalar(h) && isequal(h.Color,palette(q,:)));
            radii=hypot(h.XData-100*d.targetXY(q,1),h.YData-100*d.targetXY(q,2)); assert(max(abs(radii-1.5))<1e-12);
        end
    end
    assert(thin==64 && means==16 && circles==64 && f.UserData.scatterMatched && ~f.UserData.contrastSelected);
    audit.reopened=1; audit.graphicsObjects=thin+means+16; audit.peakMarkers=circles; clear cleanup
end

function [center,scatter,D]=direct_moments(points)
    sorted=sort(points,1); n=size(points,1); center=(sorted(floor((n+1)/2),:)+sorted(ceil((n+1)/2),:))/2;
    scatter=zeros(2);
    for k=1:n
        delta=points(k,:)-center;
        scatter=scatter+[delta(1)*delta(1) delta(1)*delta(2);delta(2)*delta(1) delta(2)*delta(2)]/n;
    end
    D=sqrt(scatter(1,1)+scatter(2,2));
end
