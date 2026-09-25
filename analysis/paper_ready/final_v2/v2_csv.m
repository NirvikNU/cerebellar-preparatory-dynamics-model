function v2_csv(path,names,values)
    assert(~isfile(path) && size(values,2)==numel(names));
    fid=fopen(path,'w'); assert(fid>0); closer=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',strjoin(names,','));
    format=[repmat('%.17g,',1,size(values,2)-1) '%.17g\n']; fprintf(fid,format,values.');
end
