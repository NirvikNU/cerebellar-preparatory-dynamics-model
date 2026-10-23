function [data,currentPath]=submission_ed5_source(root,oldPath,migration)
    % Reconstruct only the exact authorized naming edits before original blob checks.
    currentPath=oldPath;
    for j=1:numel(migration.pathRenames)
        row=migration.pathRenames(j);
        if strcmp(row.old,oldPath),currentPath=row.new;end
    end
    fid=fopen(fullfile(root,currentPath),'rb');assert(fid>=0);
    cleanup=onCleanup(@()fclose(fid));data=fread(fid,Inf,'*uint8');
    for j=1:numel(migration.textEdits)
        row=migration.textEdits(j);
        if ~strcmp(row.oldPath,oldPath),continue;end
        assert(strcmp(hash(data),row.newSHA256),'ED5:ChangedRenamedSource');
        body=char(data.');
        for k=1:numel(row.replacements)
            op=row.replacements(k);
            assert(numel(strfind(body,op.new))==op.count,'ED5:IdentifierCount');
            body=strrep(body,op.new,op.old);
        end
        data=uint8(body).';
        assert(strcmp(hash(data),row.oldSHA256),'ED5:NonNamingChange');
    end
end

function value=hash(data)
    md=java.security.MessageDigest.getInstance('SHA-256');md.update(data);
    value=upper(reshape(dec2hex(typecast(md.digest(),'uint8'),2).',1,[]));
end
