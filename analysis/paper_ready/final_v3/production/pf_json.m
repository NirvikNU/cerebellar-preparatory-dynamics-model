function pf_json(filename,value)
    fid=fopen(filename,'w'); assert(fid>=0); cleaner=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',jsonencode(value,PrettyPrint=true));
end
