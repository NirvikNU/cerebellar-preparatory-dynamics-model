function f=pf_draw(recipe,name)
    % Recreate native MATLAB data objects from portable numerical specifications.
    f=figure('Visible','off','Color','w','Position',[30 30 recipe.size]);
    colormap(f,recipe.colormap);
    for k=1:numel(recipe.axes)
        r=recipe.axes{k}; ax=axes('Parent',f); hold(ax,'on'); created=gobjects(numel(r.objects),1);
        for j=1:numel(r.objects)
            o=r.objects{j}; p=o.properties;
            switch o.type
                case 'line', h=line(ax,NaN,NaN);
                case 'errorbar', h=errorbar(ax,NaN,NaN,NaN);
                case 'scatter', h=scatter(ax,NaN,NaN);
                case 'bar', h=bar(ax,p.XData,p.YData); assert(isscalar(h));
                case 'image', h=image(ax,NaN);
                case 'surface', h=surface(ax,NaN(2));
                case 'patch', h=patch(ax,NaN,NaN,'k');
                case 'rectangle', h=rectangle(ax);
                case 'text', h=text(ax,0,0,'');
                case 'constantline'
                    if strcmp(p.InterceptAxis,'y'), h=yline(ax,p.Value); else, h=xline(ax,p.Value); end
                    p=rmfield(p,'InterceptAxis');
                otherwise, error('Production:GraphicsType','Unsupported object %s',o.type);
            end
            set(h,p);
            created(j)=h;
        end
        set(ax,r.properties);
        xlabel(ax,r.xlabel); ylabel(ax,r.ylabel); title(ax,r.title);
        if ~isempty(r.legend)
            if isfield(r.legend,'objectIndices')
                lg=legend(ax,created(r.legend.objectIndices),r.legend.labels);
            else
                lg=legend(ax,r.legend.labels);
            end
            set(lg,'Location',r.legend.Location,'Orientation',r.legend.Orientation, ...
                'FontSize',r.legend.FontSize,'AutoUpdate','off','Box','off');
            lg.Interpreter='none';
        end
        if ~isempty(r.colorbar)
            cb=colorbar(ax); cb.Position=r.colorbar.Position; cb.Label.String=r.colorbar.Label; cb.Ticks=r.colorbar.Ticks;
        end
    end
    f.UserData=struct('panel',name,'source','versioned numerical graphics specification','scientificValuesChanged',false);
end
