function receipt=validate_submission_raster(publicationFolder,receiptFile)
    % Exact finite image allowlist; no image-wide tolerance or automatic expansion.
    root=fileparts(fileparts(mfilename('fullpath')));
    source=fullfile(root,'data/paper_ready/final_v3/submission_statistics_20261021/raster_acceptance.json');
    rule=jsondecode(fileread(source));
    expected='951BADEF0C76E42C56AA19830E3E828C2872A4D1D448E0539E4DCFB3B215EFBC';
    assert(strcmp(rule.approvedProposalSHA256,expected)&&rule.automaticExpansionForbidden);
    assert(numel(rule.outputs)==13);rows=cell(13,1);
    for j=1:13
        item=rule.outputs(j);file=fullfile(publicationFolder,'figures/png',[item.name '.png']);
        [rgb,map,alpha]=imread(file);
        if ~isempty(map),rgb=uint8(round(255*ind2rgb(rgb,map)));end
        if size(rgb,3)==1,rgb=repmat(rgb,1,1,3);end
        assert(isa(rgb,'uint8')&&size(rgb,3)==3);
        if isempty(alpha),alpha=repmat(uint8(255),size(rgb,1),size(rgb,2));end
        assert(isa(alpha,'uint8'));
        dims=[size(rgb,2) size(rgb,1)];assert(isequal(dims,item.dimensionsWH(:).'), ...
            'Submission:RasterDimensions','Changed dimensions in %s',item.name);
        raw=permute(cat(3,rgb,alpha),[3 2 1]);md=java.security.MessageDigest.getInstance('SHA-256');md.update(raw(:));
        hash=lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2).',1,[]));
        assert(any(strcmp(hash,item.allowedWholePixelArraySHA256)), ...
            'Submission:UnobservedRaster','Unapproved full-image raster in %s: %s',item.name,hash);
        expectedCount=1;
        if strcmp(item.name,'Fig6f'),expectedCount=2;end
        if ismember(item.name,{'ED7c','Extended_Data_Figure_7'}),expectedCount=8;end
        assert(numel(item.allowedWholePixelArraySHA256)==expectedCount);
        rows{j}=struct('panel',item.name,'dimensionsWH',dims,'pixelSHA256',hash,'exception',item.exception,'status','PASS');
    end
    receipt=struct('status','PASS','approvedProposalSHA256',expected,'outputs',{vertcat(rows{:})}, ...
        'noToleranceExpansion',true,'scientificAndNativeGatesSeparateAndUnchanged',true);
    assert(~isfile(receiptFile),'Preserve existing receipt.');
    fid=fopen(receiptFile,'w');assert(fid>=0);guard=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',jsonencode(receipt,'PrettyPrint',true));
end
