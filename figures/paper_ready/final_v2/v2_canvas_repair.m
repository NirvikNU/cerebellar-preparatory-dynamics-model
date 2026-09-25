function receipt=v2_canvas_repair(root)
    % openfig can clamp an off-screen tall canvas to the current display size.
    cfg=v2_paths(root); receipt.status='PASS'; receipt.scientificDataChanged=false;
    receipt.files={}; dims=[2200 2700;1500 650;2100 650;2000 650;1900 1200;1900 1200];
    original=jsondecode(fileread(fullfile(cfg.manifest,'final_figures.json')));
    for j=[1 2 4]
        pair=original.pairs(j); f=openfig(pair.fig,'invisible'); objects=findall(f,'-property','UserData'); before=get(objects,'UserData');
        set(f,'Units','pixels','Position',[20 20 dims(j,:)]); drawnow;
        assert(isequaln(before,get(objects,'UserData')));
        savefig(f,pair.fig); exportgraphics(f,pair.png,'Resolution',160); close(f);
        f=openfig(pair.fig,'invisible'); objects=findall(f,'-property','UserData'); assert(isequaln(before,get(objects,'UserData'))); close(f);
        receipt.files{end+1}=pair.fig;
    end
    paper_json(fullfile(cfg.manifest,'canvas_repair.json'),receipt);
end
