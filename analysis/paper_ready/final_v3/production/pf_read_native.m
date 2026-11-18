function f=pf_read_native(file,canvas)
    % Use a stable temporary viewport; never resave the canonical native file.
    drawnow;
    f=hgload(file,struct('Visible','off','WindowState','normal','WindowStyle','normal'));
    drawnow;
    window=get(f);assert(strcmp(window.WindowStyle,'normal'));
    desired=[30 30 ceil(canvas)];stable=0;
    for attempt=1:10
        f.WindowState='normal';f.Position=desired;
        pause(.2);drawnow;
        if isequal(f.Position,desired)&&strcmp(f.WindowState,'normal')
            stable=stable+1;
        else
            stable=0;
        end
        if stable>=2
            before=pf_snapshot(f);plotedit(f,'off');drawnow;
            assert(isequaln(before,pf_snapshot(f)),'Publication:ViewingMode','Viewing mode changed scientific content/layout.');
            assert(isequal(f.Position,desired),'Publication:Viewport','Viewing mode changed the viewport.');
            return;
        end
    end
    error('Publication:Viewport','Native viewer geometry did not settle: requested %s, observed %s.', ...
        mat2str(desired),mat2str(f.Position));
end
