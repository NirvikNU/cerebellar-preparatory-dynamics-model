function receipt=fb22_audit(root,d,records,panels,limits,dest,plots,figuresOnly)
    receipt=struct('status','PASS','versions',5,'selectedRecords',480,'maxPhaseError',0,'figuresReopened',0,'objectsChecked',0);
    palette=[1 0 .16;1 .601 0;.2549 .4118 .8824;0 1 .1476;.2510 .8784 .8157;.3137 .7843 .4706;.4827 0 1;1 0 .75];
    assert(isequal(d.targetColors,palette) && d.selectedNetwork==8);
    if ~figuresOnly
        ledger=readmatrix(fullfile(root,'results/paper_ready/final_v3/fig6fgh_highrms14/all_saved_attempts.csv'));
        selected=readmatrix(fullfile(dest,'selected_trials.csv')); paths=readmatrix(fullfile(dest,'displayed_native_paths.csv'));
        means=readmatrix(fullfile(dest,'same_six_phase_means.csv')); pools=readmatrix(fullfile(dest,'pool_counts.csv'));
        phase=zeros(101,2,numel(records)); ends=zeros(numel(records),1);
        for at=1:numel(records)
            r=records(at); p=r.row(2); q=r.row(3);
            rawPath=fullfile(root,'results/paper_ready/cache/fig6fgh_successful11/reservoir',sprintf('p%d_t%d',p,q),sprintf('batch_%04d.mat',r.batchID));
            z=load(rawPath,'raw'); slot=find(z.raw.attemptIDs==r.row(4)); assert(isscalar(slot));
            hand=z.raw.hand(:,:,slot); assert(isequal(hand,r.hand) && isequaln(ledger(r.ledgerIndex,:),r.row));
            assert(z.raw.seeds(slot)==r.row(5) && z.raw.success(slot)==r.row(6));
            xy=[hand(:,1)-hand(1,1) hand(:,3)-hand(1,3)]; speed=sqrt(hand(:,2).^2+hand(:,4).^2);
            first=find(speed>=.2*max(speed),1); entry=find(hypot(xy(:,1)-d.targetXY(q,1),xy(:,2)-d.targetXY(q,2))<=.015,1);
            assert(first-1==r.row(7) && isfinite(first)); last=600;
            if r.row(6)
                assert(~isempty(entry) && entry-1==r.row(8)); last=entry;
            else
                assert(isempty(entry) && isnan(r.row(8)));
            end
            assert(first<last && r.stopMs==last-1); ends(at)=last;
            assert(isequal(r.xy(1:last,:),xy(1:last,:)) && all(isnan(r.xy(last+1:end,:)),'all'));
            times=linspace(first,last,101).'; low=floor(times); high=min(low+1,last); weight=times-low;
            phase(:,:,at)=xy(low,:).*(1-weight)+xy(high,:).*weight;
            assert(max(abs(phase(:,:,at)-r.phaseXY),[],'all')<1e-13);
            assert(all(100*xy(1:last,:)>=limits(1,:),'all') && all(100*xy(1:last,:)<=limits(2,:),'all'));
        end
        for version=1:5
            stream=RandStream('mt19937ar','Seed',18000+version); panel=panels(version);
            assert(panel.seed==18000+version);
            for p=1:2
                for q=1:8
                    s=find(ledger(:,2)==p & ledger(:,3)==q & ledger(:,6)==1);
                    f=find(ledger(:,2)==p & ledger(:,3)==q & ledger(:,6)==0);
                    a=randperm(stream,numel(s),3); b=randperm(stream,numel(f),3); expected=[s(a(:));f(b(:))];
                    chosen=panel.chosen(:,q,p); assert(isequal([records(chosen).ledgerIndex].',expected));
                    assert(numel(unique(chosen))==6 && isequal(ledger(expected,6),[1;1;1;0;0;0]));
                    row=pools(pools(:,1)==p & pools(:,2)==q,:); assert(isequal(row,[p q numel(s) numel(f)]));
                    rows=selected(selected(:,1)==version & selected(:,6)==p & selected(:,7)==q,:);
                    assert(isequal(rows(:,3),(1:6).') && isequal(rows(:,4),expected) && isequaln(rows(:,5:12),ledger(expected,1:8)));
                    assert(isequal(rows(:,13),[records(chosen).stopMs].') && isequal(rows(:,14),[records(chosen).batchID].'));
                    expectedMean=sum(phase(:,:,chosen),3)/6;
                    receipt.maxPhaseError=max(receipt.maxPhaseError,max(abs(expectedMean-panel.means(:,:,q,p)),[],'all'));
                    rows=means(means(:,1)==version & means(:,3)==p & means(:,4)==q,:);
                    assert(isequal(rows(:,6:7),panel.means(:,:,q,p)));
                    for at=chosen.'
                        r=records(at); last=ends(at); rows=paths(paths(:,1)==version & paths(:,2)==p & paths(:,3)==q & paths(:,4)==r.row(4),:);
                        assert(all(rows(:,5)==r.row(6)) && isequal(rows(:,6),(0:last-1).') && isequal(rows(:,7:8),r.xy(1:last,:)));
                    end
                end
            end
        end
        assert(size(selected,1)==480 && sum(selected(:,10))==240 && receipt.maxPhaseError<1e-13);
        receipt.uniqueNativeTrials=numel(records); receipt.successesDisplayed=240; receipt.failuresDisplayed=240;
        receipt.independentSelectionReplay=true; receipt.rawEvidenceReopened=true; return
    end
    for version=1:5
        panel=panels(version); f=openfig(fullfile(plots,'fig',sprintf('Fig6f_balanced_option%d_seed%d.fig',version,panel.seed)),'invisible');
        cleanup=onCleanup(@()close(f)); thin=0; thick=0; successes=0; failures=0;
        assert(f.UserData.seed==panel.seed && f.UserData.balancedSuccessFailure);
        for h=findall(f,'-property','UserData').'
            u=h.UserData; if ~isstruct(u)||~isfield(u,'kind'), continue; end
            if strcmp(u.kind,'trajectory')
                at=u.record; assert(ismember(at,panel.chosen(:,u.target,u.condition)));
                xy=100*records(at).xy; assert(h.LineWidth==.65 && u.success==records(at).row(6)); thin=thin+1;
                successes=successes+(u.success==1); failures=failures+(u.success==0);
            else
                assert(strcmp(u.kind,'sixPhaseMean') && isequal(u.records,panel.chosen(:,u.target,u.condition)));
                xy=100*panel.means(:,:,u.target,u.condition); assert(h.LineWidth==2.4); thick=thick+1;
            end
            assert(isequaln(h.XData(:),xy(:,1)) && isequaln(h.YData(:),xy(:,2)) && strcmp(h.LineStyle,'-') && isequal(h.Color,palette(u.target,:)));
        end
        axesList=findall(f,'Type','axes'); assert(numel(axesList)==2 && isempty(findall(f,'Type','legend')));
        for ax=axesList.'
            assert(isequal(ax.XLim,limits(:,1).') && isequal(ax.YLim,limits(:,2).') && isequal(ax.DataAspectRatio,[1 1 1]));
            assert(strcmp(ax.XLabel.String,'Hand x (cm)') && strcmp(ax.YLabel.String,'Hand y (cm)'));
            for q=1:8
                h=findall(ax,'Tag',sprintf('zone_%d',q)); assert(isscalar(h) && isequal(h.Color,palette(q,:)));
                assert(max(abs(hypot(h.XData-100*d.targetXY(q,1),h.YData-100*d.targetXY(q,2))-1.5))<1e-12);
            end
        end
        assert(thin==96 && thick==16 && successes==48 && failures==48);
        receipt.figuresReopened=receipt.figuresReopened+1; receipt.objectsChecked=receipt.objectsChecked+thin+thick; clear cleanup
    end
end
