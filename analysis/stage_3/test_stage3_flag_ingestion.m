function test_stage3_flag_ingestion(cfg)
    % Cache-safe CSV roundtrip with exact row-identity and invalid-value tests.
    a=readtable(fullfile(cfg.resultsRoot,'feasibility_map.csv'));
    b=stage3_logical_flags(a); names={'analytical','rateRealizable','modulationOK','endpointBoundsOK','tested','physical','finitePhenotype','feasible'};
    for j=1:numel(names)
        exact=find(a.(names{j})==1); assert(isequal(find(b.(names{j})),exact));
        assert(isequal(a(exact,{'network','direction','gridIndex'}),b(b.(names{j}),{'network','direction','gridIndex'})));
    end
    path=[tempname '.csv']; cleanup=onCleanup(@()delete(path));
    writetable(b,path); c=stage3_logical_flags(readtable(path)); assert(isequaln(b,c));
    for badValue=[NaN Inf -1 2]
        bad=a; bad.analytical(1)=badValue; rejected=false;
        try
            stage3_logical_flags(bad);
        catch err
            rejected=strcmp(err.identifier,'Stage3Figure:FlagValue');
        end
        assert(rejected,'Invalid flags were not rejected.');
    end
    clear cleanup;
end
