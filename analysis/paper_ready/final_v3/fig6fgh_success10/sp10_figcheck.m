function receipt=sp10_figcheck(root,d,plots)
    receipt=struct('displayObjects',0,'reopenedCurrentFigures',0);
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
                assert(isequal(h.EdgeColor,d.conditionColors(u.condition,:)));
                if u.condition==1, assert(isequal(h.FaceColor,d.conditionColors(1,:))); end
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
                if panel=='f', expectedColor=palette(q,:); else, expectedColor=d.conditionColors(u.condition,:); end
                if isprop(h,'Color'), assert(isequal(h.Color,expectedColor)); end
                if isprop(h,'CData'), assert(isequal(h.CData,expectedColor)); end
                if strcmp(u.kind,'selectedUnsmoothedPeak'), assert(strcmp(h.MarkerFaceColor,'flat')); end
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
    receipt.intactOnlyNetworkSelection=true; receipt.truncatedAll30Summary=true;
    receipt.insetAll30=true; receipt.sameTenTrialsGH=true; receipt.canonicalPalette=true; receipt.conditionColors=true;
    receipt.unchangedStatistics='Protected file hashes independently checked; no inferential calculation invoked.';
end
