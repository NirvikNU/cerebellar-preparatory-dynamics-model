function audit=fc20_audit(root,d,panel,limits,dest,plots,figuresOnly)
    audit=struct('status','PASS','successes',0,'selected',0,'maxRMSError',0,'maxMeanError',0,'subsetProofs',0,'reopened',0,'graphicsObjects',0);
    palette=[1 0 .16;1 .601 0;.2549 .4118 .8824;0 1 .1476;.2510 .8784 .8157;.3137 .7843 .4706;.4827 0 1;1 0 .75];
    assert(isequal(d.targetColors,palette));
    if ~figuresOnly
        ledger=readmatrix(fullfile(root,'results/paper_ready/final_v3/fig6fgh_highrms14/all_saved_attempts.csv'));
        assert(size(ledger,1)==12674 && sum(ledger(:,6))==453);
        selected=readmatrix(fullfile(dest,'selected_trials.csv')); ranks=readmatrix(fullfile(dest,'all_success_rankings.csv'));
        phases=readmatrix(fullfile(dest,'same_four_phase_means.csv')); paths=readmatrix(fullfile(dest,'displayed_native_paths.csv'));
        scores=readmatrix(fullfile(dest,'display_contrast_scores.csv'));
        for p=1:2
            c=d.condition{p};
            for q=1:8
                ids=(q-1)*30+(1:c.counts(q)); expectedRMS=zeros(numel(ids),1); allPhase=zeros(101,2,numel(ids));
                good=ledger(ledger(:,2)==p & ledger(:,3)==q & ledger(:,6)==1,:);
                assert(isequal(good(:,4),c.attemptID(ids)) && isequal(good(:,5),c.seed(ids)) && size(good,1)==numel(ids));
                for j=1:numel(ids)
                    tr=ids(j); hand=c.hand(:,:,tr); xy=hand(:,[1 3])-hand(1,[1 3]); speed=hypot(hand(:,2),hand(:,4));
                    first=find(speed>=max(speed)/5,1); last=find(hypot(xy(:,1)-d.targetXY(q,1),xy(:,2)-d.targetXY(q,2))<=.015,1);
                    assert(~isempty(last) && last<=600 && first<last && c.moMs(tr)==first-1 && c.endMs(tr)==last-1);
                    assert(isequal(xy(1:last,:),c.xy(1:last,:,tr)) && all(isnan(c.xy(last+1:end,:,tr)),'all'));
                    total=0; target=d.targetXY(q,:); norm2=dot(target,target);
                    for t=first:last
                        along=dot(xy(t,:),target);
                        if along<0
                            dist2=sum(xy(t,:).^2);
                        elseif along>norm2
                            dist2=sum((xy(t,:)-target).^2);
                        else
                            dist2=(xy(t,1)*target(2)-xy(t,2)*target(1))^2/norm2;
                        end
                        total=total+dist2;
                    end
                    expectedRMS(j)=sqrt(total/(last-first+1));
                    at=linspace(first,last,101).'; lower=floor(at); upper=min(lower+1,last); weight=at-lower;
                    allPhase(:,:,j)=xy(lower,:).*(1-weight)+xy(upper,:).*weight;
                    assert(all(100*xy(1:last,:)>=limits(1,:),'all') && all(100*xy(1:last,:)<=limits(2,:),'all'));
                end
                audit.maxRMSError=max(audit.maxRMSError,max(abs(expectedRMS-c.pathRMS(ids))));
                direction=3-2*p; order=sortrows([expectedRMS c.attemptID(ids) ids.'],[direction 2]);
                chosen=panel.chosen(:,q,p); assert(isequal(chosen,order(1:4,3)) && numel(unique(chosen))==4);
                rows=selected(selected(:,2)==p & selected(:,3)==q,:); assert(isequal(rows(:,5),chosen));
                allRows=ranks(ranks(:,2)==p & ranks(:,3)==q,:); assert(isequal(allRows(:,5),order(:,3)));
                assert(isequal(rows(:,6),c.attemptID(chosen)) && isequal(rows(:,7),c.seed(chosen)));
                combinations=nchoosek(1:numel(ids),4); subsetMeans=mean(reshape(expectedRMS(combinations),size(combinations)),2);
                if p==1, optimum=min(subsetMeans); else, optimum=max(subsetMeans); end
                assert(abs(optimum-panel.selectedMeanRMS(q,p))<1e-13);
                chosenLocal=chosen-(q-1)*30;
                expected=(allPhase(:,:,chosenLocal(1))+allPhase(:,:,chosenLocal(2))+allPhase(:,:,chosenLocal(3))+allPhase(:,:,chosenLocal(4)))/4;
                audit.maxMeanError=max(audit.maxMeanError,max(abs(expected-panel.means(:,:,q,p)),[],'all'));
                rows=phases(phases(:,1)==p & phases(:,2)==q,:); assert(isequal(rows(:,4:5),panel.means(:,:,q,p)));
                for tr=chosen.'
                    rows=paths(paths(:,1)==p & paths(:,2)==q & paths(:,3)==c.attemptID(tr),:);
                    last=c.endMs(tr)+1; assert(isequal(rows(:,4),(0:last-1).') && isequal(rows(:,5:6),c.xy(1:last,:,tr)));
                end
                audit.successes=audit.successes+numel(ids); audit.selected=audit.selected+4; audit.subsetProofs=audit.subsetProofs+1;
            end
        end
        assert(isequal(scores(:,4:5),panel.selectedMeanRMS) && isequal(scores(:,6),panel.selectedMeanRMS(:,2)-panel.selectedMeanRMS(:,1)));
        assert(audit.successes==453 && audit.selected==64 && audit.subsetProofs==16 && audit.maxRMSError<1e-13 && audit.maxMeanError<1e-13);
        audit.allAvailableSuccessesIncluded=true; audit.extremeMeanDifferenceProven=true; return
    end
    f=openfig(fullfile(plots,'fig','Fig6f_contrast_selected.fig'),'invisible'); cleanup=onCleanup(@()close(f));
    thin=0; means=0;
    for h=findall(f,'-property','UserData').'
        u=h.UserData; if ~isstruct(u)||~isfield(u,'kind'), continue; end
        p=u.condition; q=u.target; assert(isequal(h.Color,palette(q,:)) && strcmp(h.LineStyle,'-'));
        if strcmp(u.kind,'trajectory')
            assert(ismember(u.trial,panel.chosen(:,q,p))); xy=100*d.condition{p}.xy(:,:,u.trial); thin=thin+1; assert(h.LineWidth==.65);
        else
            assert(strcmp(u.kind,'fourPhaseMean') && isequal(u.trials,panel.chosen(:,q,p))); xy=100*panel.means(:,:,q,p); means=means+1; assert(h.LineWidth==2.4);
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
    assert(thin==64 && means==16 && f.UserData.contrastSelected && ~f.UserData.random);
    audit.reopened=1; audit.graphicsObjects=thin+means;
end
