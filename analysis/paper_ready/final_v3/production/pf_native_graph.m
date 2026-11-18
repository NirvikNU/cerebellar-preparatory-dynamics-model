function graph=pf_native_graph(f,file)
    % Materialize lazy text-edit interactions before the complete property read.
    before=pf_snapshot(f);
    submission_graph(f);drawnow;
    graph=submission_graph(f);
    assert(isequaln(before,pf_snapshot(f)),'Publication:GetterSideEffect','Property read changed scientific content/layout.');
    actual=graph.handleNodes{1}.properties.FileName;
    assert(strcmpi(strrep(actual,'\','/'),strrep(file,'\','/')),'Publication:NativeSourcePath');
    graph.handleNodes{1}.properties.FileName='<verified source filename>';
end
