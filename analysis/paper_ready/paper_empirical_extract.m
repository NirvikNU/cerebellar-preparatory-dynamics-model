function receipt = paper_empirical_extract(root)
    % Graphics-only extraction: never infer scientific metadata from colors.
    dest=fullfile(root,'results','paper_ready','empirical');
    source=fullfile(dest,'dimensionality_alignment_epochs_raw_data.fig');
    output=fullfile(dest,'graphics_inventory.json');
    assert(~isfile(output),'Refuse to overwrite extraction evidence.');
    f=openfig(source,'invisible'); closer=onCleanup(@()close(f));
    objects=findall(f); rows=cell(numel(objects),1);
    fields={'Type','Tag','DisplayName','String','XData','YData','CData', ...
        'YNegativeDelta','YPositiveDelta','XNegativeDelta','XPositiveDelta', ...
        'XTick','XTickLabel','YTick','YTickLabel','XLim','YLim','Position', ...
        'UserData','Title','XLabel','YLabel'};
    for k=1:numel(objects)
        h=objects(k); s=struct('class',class(h));
        for j=1:numel(fields)
            key=fields{j};
            if isprop(h,key)
                v=get(h,key);
                if ismember(key,{'Title','XLabel','YLabel'}), v=get(v,'String'); end
                if isnumeric(v)||islogical(v)||ischar(v)||isstring(v)||iscellstr(v)||isstruct(v)
                    s.(key)=v;
                end
            end
        end
        rows{k}=s;
    end
    receipt=struct('source',source,'objects',{rows},'figureUserData',f.UserData);
    fid=fopen(output,'w'); assert(fid>0); cleanup=onCleanup(@()fclose(fid));
    fprintf(fid,'%s',jsonencode(receipt,'PrettyPrint',true)); clear cleanup;
    save(fullfile(dest,'graphics_inventory.mat'),'receipt');
    exportgraphics(f,fullfile(dest,'empirical_source_review.png'),'Resolution',160);
    fprintf('Graphics extraction complete: %d objects, original FIG not modified.\n',numel(objects));
end
