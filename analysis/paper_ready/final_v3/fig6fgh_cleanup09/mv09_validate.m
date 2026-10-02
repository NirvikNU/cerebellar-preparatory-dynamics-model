function receipt=mv09_validate(root,d,plots)
    receipt=struct('status','PASS','selectionError',0,'sourceError',0,'networkRankChecks',10, ...
        'trialRankChecks',480,'displayObjects',0,'reopenedCurrentFigures',0,'noPostEndLeak',true);
    rms=zeros(10,8);
    for n=1:10
        raw=mv09_load(root,n,1);
        [~,~,~,rms(n,:)]=independent(raw,d.targetXY);
    end
    scores=sum(rms,2)/8; rank=sortrows([scores (1:10).'],[1 2]);
    target=sortrows([rms(rank(1,2),:).' (1:8).'],[1 2]);
    assert(rank(1,2)==d.selectedNetwork && target(1,2)==d.selectedTarget);
    receipt.selectionError=max(abs(rms-d.targetRMS),[],'all'); assert(receipt.selectionError<1e-14);
    assert(isequal(rank(:,2),d.networkRanking(:,1)) && isequal(target(:,2),d.targetRanking(:,1)));
    for p=1:2
        raw=mv09_load(root,d.selectedNetwork,p); assert(isequal(raw,d.raw{p})); c=d.condition{p};
        [xy,stop,means,~,trialRMS,order]=independent(raw,d.targetXY);
        assert(isequaln(xy,c.xy) && isequal(stop,c.endIndex) && isequal(order,c.order));
        receipt.sourceError=max([receipt.sourceError max(abs(means-c.meanXY),[],'all','omitnan') max(abs(trialRMS-c.trialRMS))]);
        for tr=1:240
            ix=1:stop(tr); assert(all(isnan(c.xy(stop(tr)+1:end,:,tr)),'all'));
            assert(all(isnan(c.speed(stop(tr)+1:end,tr))) && all(isnan(c.smoothSpeed(stop(tr)+1:end,tr))));
            % Replace discarded source samples with extreme sentinels, then crop before smoothing/peak.
            v=raw.speed(:,tr); v(stop(tr)+1:end)=1e100;
            assert(isequal(smoothdata(v(ix),'gaussian',50),c.smoothSpeed(ix,tr)));
            mx=max(v(ix)); peak=find(v(ix)==mx,1);
            assert(c.peakMs(tr)==peak-1 && c.peakSpeed(tr)==mx && peak<=stop(tr));
            expected=reshape(xy(peak,:,tr),1,2); assert(isequal(expected,c.peakXY(tr,:)));
        end
        for q=1:8
            ids=(q-1)*30+(1:30); speeds=raw.speed(:,ids);
            for k=1:30, speeds(stop(ids(k))+1:end,k)=NaN; end
            med=nan(600,1);
            for t=1:600
                valid=sort(speeds(t,isfinite(speeds(t,:)))); count=numel(valid);
                if count>0, med(t)=(valid(floor((count+1)/2))+valid(ceil((count+1)/2)))/2; end
            end
            last=find(isfinite(med),1,'last'); displayMedian=nan(600,1); displayMedian(1:last)=smoothdata(med(1:last),'gaussian',50);
            assert(max(abs(displayMedian-c.medianSpeed(:,q)),[],'omitnan')<1e-14);
            pos=c.peakXY(ids,:); ordered=sort(pos,1); center=(ordered(15,:)+ordered(16,:))/2;
            distances=100*sqrt((pos(:,1)-center(1)).^2+(pos(:,2)-center(2)).^2);
            assert(max(abs(distances-c.distanceCM(:,q)))<1e-12);
        end
    end
    assert(receipt.sourceError<1e-14);
    palette=[1 0 .16;1 .601 0;.2549 .4118 .8824;0 1 .1476;.2510 .8784 .8157;.3137 .7843 .4706;.4827 0 1;1 0 .75];
    assert(isequal(d.targetColors,palette));
    for panel='f':'h'
        f=openfig(fullfile(plots,'fig',['Fig6' panel '.fig']),'invisible'); closer=onCleanup(@()close(f));
        assert(f.UserData.network==d.selectedNetwork && f.UserData.target==d.selectedTarget && isequal(f.UserData.palette,palette));
        counts=struct('trajectory',0,'all30Mean',0,'selectedSmoothedSpeed',0,'all30MedianSpeed',0,'selectedUnsmoothedPeak',0,'all30Inset',0);
        for h=findall(f,'-property','UserData').'
            u=h.UserData; if ~isstruct(u)||~isfield(u,'kind'), continue; end
            c=d.condition{u.condition}; q=u.target;
            if strcmp(u.kind,'all30Inset')
                assert(numel(h.Data)==30 && isequal(h.Data(:),c.distanceCM(:,q)) && isequal(h.BinEdges,u.edges));
            else
                assert(isequaln(h.XData(:),u.x(:)) && isequaln(h.YData(:),u.y(:)));
                switch u.kind
                    case 'trajectory'
                        ids=c.order(1:5,q); if panel=='h', ids=c.order(1:10,q); end
                        assert(ismember(u.trials,ids)); expected=100*c.xy(:,:,u.trials);
                        assert(isequaln(u.x,expected(:,1)) && isequaln(u.y,expected(:,2)));
                    case 'all30Mean'
                        expected=100*c.meanXY(:,:,q); assert(isequaln(u.x,expected(:,1)) && isequaln(u.y,expected(:,2)));
                    case 'selectedSmoothedSpeed'
                        assert(ismember(u.trials,c.order(1:10,q)) && isequaln(u.y,c.smoothSpeed(:,u.trials)));
                    case 'all30MedianSpeed'
                        assert(isequaln(u.y,c.medianSpeed(:,q)));
                    case 'selectedUnsmoothedPeak'
                        assert(isequal(u.trials,c.order(1:10,q)) && strcmp(h.Marker,'o'));
                        expected=100*c.peakXY(u.trials,:); assert(isequal(u.x,expected(:,1)) && isequal(u.y,expected(:,2)));
                end
                if isprop(h,'Color'), assert(isequal(h.Color,palette(q,:))); end
            end
            counts.(u.kind)=counts.(u.kind)+1; receipt.displayObjects=receipt.displayObjects+1;
        end
        if panel=='f'
            assert(counts.trajectory==80 && counts.all30Mean==16);
            ax=findall(f,'Type','axes'); assert(numel(ax)==2 && isequal(ax(1).XLim,ax(2).XLim) && isequal(ax(1).YLim,ax(2).YLim));
        elseif panel=='g'
            assert(counts.selectedSmoothedSpeed==20 && counts.all30MedianSpeed==2);
        else
            assert(counts.trajectory==20 && counts.selectedUnsmoothedPeak==2 && counts.all30Inset==2);
        end
        for lg=findall(f,'Type','legend').', assert(~any(startsWith(string(lg.String),'data'))); end
        info=imfinfo(fullfile(plots,'png',['Fig6' panel '.png'])); assert(info.Width>800 && info.Height>600);
        receipt.reopenedCurrentFigures=receipt.reopenedCurrentFigures+1; clear closer
    end
    addpath(fullfile(root,'analysis','paper_ready','prospective_variability'));
    for name={'Fig6a','Fig6b','Fig6c','Fig6d','Fig6e','Fig6i','Fig6j','ED7a','ED7b'}
        if ismember(name{1},{'Fig6i','Fig6j'}), path=fullfile(root,'plots','paper_ready','final_v3','fig6ij_fourlevel','fig',[name{1} '.fig']);
        else, path=fullfile(root,'plots','paper_ready','final_v3','fig',[name{1} '.fig']); end
        check=pv_figure_check(path); assert(check.reopened); receipt.reopenedCurrentFigures=receipt.reopenedCurrentFigures+1;
    end
    receipt.intactOnlySelection=true; receipt.truncatedAll30Summary=true;
    receipt.insetAll30=true; receipt.sameTenTrialsGH=true; receipt.canonicalPalette=true;
    receipt.unchangedStatistics='Protected file hashes independently checked; no inferential calculation invoked.';
end

function [xy,stops,means,rms,trms,order]=independent(raw,targets)
    xy=raw.hand(:,[1 3],:)-raw.hand(1,[1 3],1); stops=zeros(240,1);
    for tr=1:240
        q=floor((tr-1)/30)+1; first=600;
        for t=1:600
            delta=xy(t,:,tr)-targets(q,:);
            if delta(1)^2+delta(2)^2<=.015^2, first=t; break; end
        end
        stops(tr)=first; xy(first+1:end,:,tr)=NaN;
    end
    means=nan(600,2,8); rms=zeros(1,8); trms=zeros(240,1); order=zeros(30,8);
    for q=1:8
        ids=(q-1)*30+(1:30); total=0; sampleCount=0;
        for t=1:600
            valid=ids(stops(ids)>=t);
            if ~isempty(valid), means(t,:,q)=sum(xy(t,:,valid),3)/numel(valid); end
        end
        for tr=ids
            e=xy(1:stops(tr),:,tr)-means(1:stops(tr),:,q); ss=sum(e(:,1).^2+e(:,2).^2);
            trms(tr)=sqrt(ss/stops(tr)); total=total+ss; sampleCount=sampleCount+stops(tr);
        end
        rms(q)=sqrt(total/sampleCount); rows=sortrows([trms(ids) ids.'],[1 2]); order(:,q)=rows(:,2);
    end
end
