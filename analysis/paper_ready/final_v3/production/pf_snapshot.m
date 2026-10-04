function recipe = pf_snapshot(f)
    % Plain numerical graphics specification: no handles, FIGs, or local paths.
    recipe.size=f.Position(3:4); recipe.colormap=colormap(f); recipe.axes={};
    aa=findall(f,'Type','axes'); [~,order]=sort(arrayfun(@(a)a.Position(1),aa)); aa=aa(order);
    axisProps={'Position','XLim','YLim','XScale','YScale','XDir','YDir','XTick','YTick', ...
        'XTickLabel','YTickLabel','XTickLabelRotation','YTickLabelRotation','CLim', ...
        'DataAspectRatio','DataAspectRatioMode','PlotBoxAspectRatio','PlotBoxAspectRatioMode', ...
        'Visible','Box','TickDir','FontName','FontSize','LineWidth','Tag','TickLabelInterpreter'};
    common={'Visible','Tag','DisplayName','HandleVisibility'};
    lineProps={'XData','YData','ZData','Color','LineStyle','LineWidth','Marker','MarkerSize','MarkerEdgeColor','MarkerFaceColor'};
    for k=1:numel(aa)
        a=aa(k); one.properties=grab(a,axisProps); one.xlabel=a.XLabel.String; one.ylabel=a.YLabel.String;
        one.title=a.Title.String; one.objects={}; one.legend=[]; one.colorbar=[];
        children=flipud(allchild(a));
        children(ismember(children,[a.Title a.Subtitle a.XLabel a.YLabel a.ZLabel]))=[];
        for j=1:numel(children)
            h=children(j); type=h.Type;
            switch type
                case 'line', fields=lineProps;
                case 'errorbar', fields=[lineProps {'YNegativeDelta','YPositiveDelta','XNegativeDelta','XPositiveDelta','CapSize'}];
                case 'scatter', fields={'XData','YData','ZData','CData','SizeData','Marker','MarkerFaceColor','MarkerEdgeColor','MarkerFaceAlpha','MarkerEdgeAlpha','LineWidth'};
                case 'bar', fields={'XData','YData','CData','BarWidth','BarLayout','BaseValue','Horizontal','FaceColor','EdgeColor','FaceAlpha','LineWidth'};
                case 'image', fields={'XData','YData','CData','CDataMapping','AlphaData','AlphaDataMapping'};
                case 'surface', fields={'XData','YData','ZData','CData','FaceColor','EdgeColor','FaceAlpha','EdgeAlpha','LineStyle','LineWidth'};
                case 'patch', fields={'XData','YData','ZData','CData','FaceColor','EdgeColor','FaceAlpha','EdgeAlpha','LineStyle','LineWidth'};
                case 'rectangle', fields={'Position','Curvature','EdgeColor','FaceColor','LineStyle','LineWidth'};
                case 'text', fields={'Position','String','Color','FontName','FontSize','FontWeight','Interpreter','Rotation','HorizontalAlignment','VerticalAlignment','Clipping'};
                case 'constantline', fields={'Value','InterceptAxis','Color','LineStyle','LineWidth','Label','LabelHorizontalAlignment','LabelVerticalAlignment'};
                otherwise, error('Production:GraphicsType','Unsupported native graphics object: %s',type);
            end
            one.objects{end+1}=struct('type',type,'properties',grab(h,[common fields]));
        end
        if ~isempty(a.Legend)
            one.legend=struct('labels',{a.Legend.String},'Location',a.Legend.Location,'Orientation',a.Legend.Orientation,'FontSize',a.Legend.FontSize);
        end
        if ~isempty(a.Colorbar)
            one.colorbar=struct('Position',a.Colorbar.Position,'Label',{a.Colorbar.Label.String},'Ticks',a.Colorbar.Ticks);
        end
        recipe.axes{end+1}=one;
    end
end

function p=grab(h,names)
    p=struct();
    for k=1:numel(names)
        if isprop(h,names{k}), p.(names{k})=h.(names{k}); end
    end
end
