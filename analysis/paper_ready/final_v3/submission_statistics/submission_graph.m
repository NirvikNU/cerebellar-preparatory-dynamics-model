function out=submission_graph(f)
    % Traverse all gettable/public properties with stable handle references.
    % Unlike raw struct(handle), this does not recurse indefinitely into parent/event cycles.
    found=findall(f);handles=num2cell(found);nodes=cell(numel(handles),1);at=1;
    while at<=numel(handles)
        outerHandle=handles{at};
        if isgraphics(outerHandle)
            outerProps=get(outerHandle);
        else
            outerProps=struct();outerNames=sort(properties(outerHandle));
            for outerK=1:numel(outerNames),outerProps.(outerNames{outerK})=outerHandle.(outerNames{outerK});end
        end
        nodes{at}=struct('class',class(outerHandle),'properties',normValue(outerProps));at=at+1;
    end
    out=struct('originalFindallCount',numel(found),'handleNodes',{nodes});
    function z=normValue(v)
        if isnumeric(v)||islogical(v)||ischar(v)||isstring(v),z=v;return;end
        if isa(v,'function_handle')
            if isempty(v),z=struct('functionSize',size(v),'function','');else,assert(isscalar(v));z=struct('functionSize',size(v),'function',func2str(v));end;return
        end
        if iscell(v)
            z=cell(size(v));for m=1:numel(v),z{m}=normValue(v{m});end;return
        end
        if isstruct(v)
            z=v;names=fieldnames(v);for m=1:numel(v),for k=1:numel(names),z(m).(names{k})=normValue(v(m).(names{k}));end,end;return
        end
        if istable(v)
            z=struct('tableClass',class(v),'properties',normValue(v.Properties),'values',normValue(table2struct(v,'ToScalar',true)));return
        end
        if isa(v,'handle')
            refs=zeros(size(v));
            for m=1:numel(v)
                h=v(m);
                if isequal(h,groot),refs(m)=-1;continue;end
                hit=[];
                for k=1:numel(handles)
                    if strcmp(class(h),class(handles{k}))&&h==handles{k},hit=k;break;end
                end
                if isempty(hit),handles{end+1}=h;hit=numel(handles);end %#ok<AGROW> Stable traversal expands only for newly discovered reference handles.
                refs(m)=hit;
            end
            z=struct('handleClass',class(v),'references',refs);return
        end
        if numel(v)~=1
            items=cell(size(v));for m=1:numel(v),items{m}=normValue(v(m));end
            z=struct('valueClass',class(v),'items',{items});return
        end
        names=sort(properties(v));p=struct();
        for k=1:numel(names),p.(names{k})=normValue(v.(names{k}));end
        z=struct('valueClass',class(v),'properties',p);
    end
end
