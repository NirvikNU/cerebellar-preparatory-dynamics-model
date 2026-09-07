function stage3_write_json(path, value)
    fid=fopen(path,'w'); assert(fid>=0,'Cannot open JSON output.');
    cleanup=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',jsonencode(value,'PrettyPrint',true));
end
