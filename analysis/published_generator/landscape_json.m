function landscape_json(path,value)
    assert(~isfile(path),'Refuse to overwrite diagnostic evidence');
    fid=fopen(path,'w'); assert(fid>=0); guard=onCleanup(@() fclose(fid));
    fprintf(fid,'%s\n',jsonencode(value,PrettyPrint=true));
end
