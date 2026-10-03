function r=f518_audit(d,panels,limits,results,plots,figuresOnly)
    r=struct('status','PASS','selectedRecords',0,'maxPhaseMeanError',0,'reopened',0,'graphicsObjects',0);
    palette=[1 0 .16;1 .601 0;.2549 .4118 .8824;0 1 .1476;.2510 .8784 .8157;.3137 .7843 .4706;.4827 0 1;1 0 .75];
    assert(isequal(palette,d.targetColors));
    if ~figuresOnly
        saved=readmatrix(fullfile(results,'selected_trials.csv')); meanSaved=readmatrix(fullfile(results,'same_four_phase_means.csv'));
        for v=1:5
            stream=RandStream('mt19937ar','Seed',18000+v);
            for p=1:2
                c=d.condition{p};
                for q=1:8
                    chosen=panels(v).chosen(:,q,p); n=c.counts(q);
                    reproduce=(q-1)*30+randperm(stream,n,4).'; assert(isequal(chosen,reproduce) && numel(unique(chosen))==4);
                    records=saved(saved(:,1)==v & saved(:,4)==p & saved(:,5)==q,:); assert(isequal(records(:,7),chosen));
                    coordinates=zeros(101,2,4);
                    for j=1:4
                        tr=chosen(j); hand=c.hand(:,:,tr); xy=hand(:,[1 3])-hand(1,[1 3]); velocity=hypot(hand(:,2),hand(:,4));
                        first=find(velocity>=.2*max(velocity),1); last=find(sum((xy-d.targetXY(q,:)).^2,2)<=.015^2,1);
                        assert(first==c.moMs(tr)+1 && last==c.endMs(tr)+1 && first<last && last<=600);
                        assert(isequaln(c.xy(1:last,:,tr),xy(1:last,:)) && all(isnan(c.xy(last+1:end,:,tr)),'all'));
                        % Direct piecewise-linear interpolation on the sample index, independent of interp1.
                        at=linspace(first,last,101).'; lower=floor(at); upper=min(lower+1,last); weight=at-lower;
                        coordinates(:,:,j)=xy(lower,:).*(1-weight)+xy(upper,:).*weight;
                        r.selectedRecords=r.selectedRecords+1;
                    end
                    expected=(coordinates(:,:,1)+coordinates(:,:,2)+coordinates(:,:,3)+coordinates(:,:,4))/4;
                    r.maxPhaseMeanError=max(r.maxPhaseMeanError,max(abs(expected-panels(v).means(:,:,q,p)),[],'all'));
                    rows=meanSaved(meanSaved(:,1)==v & meanSaved(:,3)==p & meanSaved(:,4)==q,:);
                    assert(isequal(rows(:,6:7),panels(v).means(:,:,q,p)));
                end
            end
        end
        assert(r.selectedRecords==320 && r.maxPhaseMeanError<1e-12);
        r.allFiveShownWithoutRanking=true; return
    end
    for v=1:5
        name=sprintf('Fig6f_option%d_seed%d.fig',v,panels(v).seed);
        f=openfig(fullfile(plots,'fig',name),'invisible'); cleanup=onCleanup(@()close(f)); means=0; thin=0;
        for h=findall(f,'-property','UserData').'
            u=h.UserData; if ~isstruct(u)||~isfield(u,'kind'), continue; end
            p=u.condition; q=u.target;
            assert(isequal(h.Color,palette(q,:)) && strcmp(h.LineStyle,'-'));
            if strcmp(u.kind,'trajectory')
                assert(ismember(u.trial,panels(v).chosen(:,q,p)));
                xy=100*d.condition{p}.xy(:,:,u.trial); thin=thin+1; assert(h.LineWidth==.65);
            else
                assert(strcmp(u.kind,'fourPhaseMean') && isequal(u.trials,panels(v).chosen(:,q,p)));
                xy=100*panels(v).means(:,:,q,p); means=means+1; assert(h.LineWidth==2.4 && size(xy,1)==101);
            end
            assert(isequaln(h.XData(:),xy(:,1)) && isequaln(h.YData(:),xy(:,2)));
        end
        axs=findall(f,'Type','axes'); assert(numel(axs)==2 && isempty(findall(f,'Type','legend')));
        for ax=axs.'
            assert(isequal(ax.XLim,limits(:,1).') && isequal(ax.YLim,limits(:,2).') && isequal(ax.DataAspectRatio,[1 1 1]));
            for q=1:8
                h=findall(ax,'Tag',sprintf('zone_%d',q)); assert(isscalar(h) && isequal(h.Color,palette(q,:)));
                radius=hypot(h.XData-100*d.targetXY(q,1),h.YData-100*d.targetXY(q,2)); assert(max(abs(radius-1.5))<1e-12);
            end
        end
        assert(thin==64 && means==16); r.graphicsObjects=r.graphicsObjects+thin+means; r.reopened=r.reopened+1; clear cleanup
    end
    assert(r.reopened==5 && r.graphicsObjects==400);
end
