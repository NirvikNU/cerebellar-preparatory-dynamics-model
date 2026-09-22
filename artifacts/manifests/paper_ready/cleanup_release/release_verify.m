function release_verify(root)
    % Read-only packaging checks. Never call a scientific writer or renderer.
    out = fullfile(root,'artifacts','manifests','paper_ready','cleanup_release','STATIC_FIGURES.json');
    assert(~isfile(out),'Refusing verification receipt overwrite');
    sources = [dir(fullfile(root,'analysis','paper_ready','prediction','*.m')); ...
        dir(fullfile(root,'analysis','paper_ready','stabilization_eta','*.m')); ...
        dir(fullfile(root,'figures','paper_ready','prediction','*.m')); ...
        dir(fullfile(root,'figures','paper_ready','stabilization_eta','*.m'))];
    receipt = struct('status','PASS','sourceFiles',numel(sources),'messages',{{}}, ...
        'figures',{{}},'scientificFunctionsCalled',false);
    for j = 1:numel(sources)
        file = fullfile(sources(j).folder,sources(j).name);
        messages = checkcode(file,'-id');
        assert(isempty(messages),'Code Analyzer messages in %s: %s',file,jsonencode(messages));
    end
    own = checkcode(mfilename('fullpath'),'-id');
    assert(isempty(own),'Release verifier Code Analyzer messages: %s',jsonencode(own));
    figs = [dir(fullfile(root,'plots','paper_ready','prediction','fig','*.fig')); ...
        dir(fullfile(root,'plots','paper_ready','stabilization_eta','fig','*.fig')); ...
        dir(fullfile(root,'plots','paper_ready','fig','*alignment95.fig'))];
    assert(numel(figs)==10,'Expected all ten current review figure pairs');
    for j = 1:numel(figs)
        file = fullfile(figs(j).folder,figs(j).name);
        png = strrep(strrep(file,[filesep 'fig' filesep],[filesep 'png' filesep]),'.fig','.png');
        assert(isfile(png),'Missing matching PNG: %s',png);
        info = imfinfo(png);
        pixels = imread(png);
        assert(~isempty(pixels) && info.Width>0 && info.Height>0,'Invalid PNG');
        h = openfig(file,'new','invisible');
        axesCount = numel(findall(h,'Type','axes'));
        assert(axesCount>0,'No axes in %s',file);
        drawnow;
        close(h);
        receipt.figures{end+1} = struct('file',file,'png',png,'axes',axesCount, ...
            'width',info.Width,'height',info.Height,'reopened',true,'saved',false);
    end
    fid = fopen(out,'w');
    assert(fid>=0,'Cannot write packaging receipt');
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid,'%s\n',jsonencode(receipt,'PrettyPrint',true));
    fprintf('PASS: %d scientific source files, verifier, and %d FIG/PNG pairs; no scientific computation.\n',numel(sources),numel(figs));
end
