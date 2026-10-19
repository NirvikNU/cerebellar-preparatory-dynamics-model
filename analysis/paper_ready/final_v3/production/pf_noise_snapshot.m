function out=pf_noise_snapshot(f)
    % Complete g/h layout supplement; desktop outer-window location is not scientific geometry.
    out.native=pf_snapshot(f);out.figure=grab(f,{'Color','Units','Renderer','InvertHardcopy','PaperUnits', ...
        'PaperPosition','PaperSize','PaperPositionMode','GraphicsSmoothing','UserData'});
    axesList=findall(f,'Type','axes');[~,order]=sort(arrayfun(@(a)a.Position(1),axesList));axesList=axesList(order);
    textFields={'String','Position','Units','Color','FontName','FontSize','FontWeight','FontAngle','Interpreter', ...
        'Rotation','HorizontalAlignment','VerticalAlignment','Visible','Clipping','Tag'};
    out.axes=cell(1,numel(axesList));
    for j=1:numel(axesList)
        a=axesList(j);one=struct();
        one.layout=grab(a,{'Units','Position','OuterPosition','InnerPosition','PositionConstraint', ...
            'FontName','FontSize','FontWeight','FontAngle','Color','XColor','YColor','TitleFontSizeMultiplier','LabelFontSizeMultiplier', ...
            'XLimMode','YLimMode','XTickMode','YTickMode','GridColor','GridAlpha','XGrid','YGrid','GridLineStyle', ...
            'TitleFontWeight','TickLength','LineStyleOrder','ColorOrder'});
        one.xlabel=grab(a.XLabel,textFields);one.ylabel=grab(a.YLabel,textFields);one.title=grab(a.Title,textFields);
        one.legend=[];
        if ~isempty(a.Legend)
            one.legend=grab(a.Legend,{'String','Position','Units','Location','Orientation','FontName','FontSize', ...
                'FontWeight','FontAngle','Interpreter','TextColor','Color','Box','LineWidth','Visible','NumColumns','EdgeColor','AutoUpdate'});
        end
        h=findall(a,'Type','constantline');one.constantLabels=cell(1,numel(h));
        for k=1:numel(h)
            one.constantLabels{k}=grab(h(k),{'Label','FontName','FontSize','FontWeight','Interpreter','LabelOrientation', ...
                'LabelHorizontalAlignment','LabelVerticalAlignment'});
        end
        out.axes{j}=one;
    end
end
function s=grab(h,fields)
    s=struct();
    for k=1:numel(fields),if isprop(h,fields{k}),s.(fields{k})=h.(fields{k});end,end
end
