function result=pv_figure_check(fig)
    f=openfig(fig,'invisible'); closer=onCleanup(@()close(f)); count=0; err=0;
    for h=findall(f,'-property','UserData').'
        u=h.UserData; if ~isstruct(u), continue; end
        if isfield(u,'x'), assert(isequaln(h.XData(:),u.x(:)) && isequaln(h.YData(:),u.y(:))); count=count+1; end
        if isfield(u,'err'), assert(isequaln(h.YPositiveDelta(:),u.err(:)) && isequaln(h.YNegativeDelta(:),u.err(:))); end
        if isfield(u,'raw')
            ix=f.UserData.indices;
            if isfield(u,'indexKind')
                if strcmp(u.indexKind,'legacy'), ix=f.UserData.legacyIndices; end
                if strcmp(u.indexKind,'subset'), ix=f.UserData.subsetIndices; end
            end
            for j=1:size(u.raw,2)
                v=u.raw(:,j); ordered=sort(reshape(v(ix),size(ix)),2); n=size(ix,2);
                bm=(ordered(:,n/2)+ordered(:,n/2+1))/2;
                se=sqrt(sum((bm-mean(bm)).^2)/(size(ix,1)-1));
                err=max([err abs(median(v)-u.y(j)) abs(se-u.err(j))]);
            end
        end
    end
    assert(err<1e-10);
    for lg=findall(f,'Type','legend').', assert(~any(startsWith(string(lg.String),'data'))); end
    result=struct('objectChecks',count,'bootstrapError',err,'reopened',true);
end
