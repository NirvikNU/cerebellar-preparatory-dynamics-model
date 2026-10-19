function receipt=pf_save_noise_figure(f,fig,png)
    % Preserve the editable native figure; export through separate readback instances.
    drawnow;before=pf_noise_snapshot(f);save([fig '.snapshot.mat'],'before','-v7');savefig(f,fig);close(f);
    saved=bytes(fig);readback=hgload(fig,struct('Visible','off'));drawnow;
    readbackSnapshot=pf_noise_snapshot(readback);save([fig '.readback.mat'],'readbackSnapshot','-v7');
    assert(isequaln(before,readbackSnapshot),'Production:NoiseNative','Saved native scientific/layout snapshot differs.');close(readback);
    for pass=1:2
        copy=hgload(fig,struct('Visible','off'));drawnow;
        assert(isequaln(before,pf_noise_snapshot(copy)));
        if pass==1,target=png;else,target=[png '.repeat.png'];end
        exportgraphics(copy,target,'Resolution',160);close(copy);
        assert(isequal(saved,bytes(fig)),'Production:CanonicalChanged','PNG export modified canonical FIG.');
    end
    a=imread(png);b=imread([png '.repeat.png']);
    assert(isequal(a,b),'Production:NoiseRaster','Repeated native-source PNG exports differ.');
    final=hgload(fig,struct('Visible','off'));drawnow;assert(isequaln(before,pf_noise_snapshot(final)));close(final);
    receipt=struct('status','PASS','nativeSnapshotExact',true,'canonicalFIGUnchanged',true, ...
        'independentExportPixelsExact',true,'width',size(a,2),'height',size(a,1),'nativeCanvas',before.native.size);
end
function data=bytes(file)
    fid=fopen(file,'rb');assert(fid>=0);cleanup=onCleanup(@()fclose(fid));
    data=fread(fid,Inf,'*uint8');
end
