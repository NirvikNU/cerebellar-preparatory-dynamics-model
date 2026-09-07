function tab = stage3_logical_flags(tab)
    % CSV booleans must be finite 0/1, never positional indices or missing=true.
    names={'analytical','rateRealizable','modulationOK','endpointBoundsOK','tested','physical','finitePhenotype','feasible'};
    for k=1:numel(names)
        flag=tab.(names{k});
        assert((isnumeric(flag)||islogical(flag)) && iscolumn(flag) && numel(flag)==height(tab), ...
            'Stage3Figure:FlagShape','Invalid flag shape/type: %s',names{k});
        assert(all(isfinite(flag) & (flag==0 | flag==1)), ...
            'Stage3Figure:FlagValue','Invalid flag value: %s',names{k});
        tab.(names{k})=logical(flag);
    end
end
