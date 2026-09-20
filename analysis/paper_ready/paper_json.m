function paper_json(path,value)
    fid=fopen(path,'w'); assert(fid>0); closer=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',jsonencode(value,'PrettyPrint',true));
end
