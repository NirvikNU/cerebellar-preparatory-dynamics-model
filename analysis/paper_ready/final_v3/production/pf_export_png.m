function receipt=pf_export_png(nativeFile,file,canvas)
    % Render the native canvas through a deterministic physical-size print path.
    assert(~isfile(file),'Production:ExistingPNG','Preserve an existing PNG.');
    assert(isfile(nativeFile),'Production:NativeSource','Export requires a saved native source.');
    nativeBytes=bytes(nativeFile);
    f=hgload(nativeFile,struct('Visible','off','WindowState','normal'));drawnow;
    assert(strcmp(f.Units,'pixels'),'Production:CanvasUnits','Native canvas must use pixels.');
    f.Position=[f.Position(1:2) canvas];
    assert(isequal(f.Position(3:4),canvas),'Production:CanvasDimensions');
    before=pf_snapshot(f);
    dpi=160;screenDpi=get(groot,'ScreenPixelsPerInch');
    inches=canvas/screenDpi;
    f.PaperUnits='inches';f.PaperPositionMode='manual';
    f.PaperPosition=[0 0 inches];f.PaperSize=inches;
    print(f,file,'-dpng','-r160','-vector');drawnow;
    assert(isequal(f.PaperPosition,[0 0 inches])&&isequal(f.PaperSize,inches),'Production:PrintGeometry');
    close(f);
    assert(isequal(nativeBytes,bytes(nativeFile)),'Production:CanonicalChanged','Print modified its saved source.');
    info=imfinfo(file);expected=ceil(inches*dpi);
    assert(isequal([info.Width info.Height],expected),'Production:RasterDimensions','Unexpected print dimensions.');
    receipt=struct('status','PASS','renderer','vector','resolution',dpi,'screenPixelsPerInch',screenDpi, ...
        'nativeCanvas',before.size,'physicalInches',inches,'dimensionsWH',expected,'canonicalNativeBytesExact',true);
end

function out=bytes(file)
    fid=fopen(file,'rb');assert(fid>=0);guard=onCleanup(@()fclose(fid));out=fread(fid,Inf,'*uint8');
end
