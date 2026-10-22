function [snapshot,graph]=submission_textures(snapshot,graph,root,panels)
    % Verify each derived composite texture before comparing the native layout.
    seen={};
    for j=1:numel(graph.handleNodes)
        if strcmp(graph.handleNodes{j}.class,'matlab.graphics.primitive.Image')
            panel=match(graph.handleNodes{j}.properties.CData,root,panels);
            seen{end+1}=panel; %#ok<AGROW>
            graph.handleNodes{j}.properties.CData=struct('verifiedDerivedPanelTexture',panel);
        end
    end
    assert(isequal(sort(seen),sort(panels)),'Submission:TextureCount');
    for j=1:numel(snapshot.axes)
        for k=1:numel(snapshot.axes{j}.objects)
            obj=snapshot.axes{j}.objects{k};
            if strcmp(obj.type,'image')
                panel=match(obj.properties.CData,root,panels);
                snapshot.axes{j}.objects{k}.properties.CData=struct('verifiedDerivedPanelTexture',panel);
            end
        end
    end
end

function panel=match(data,root,panels)
    hits=[];
    for k=1:numel(panels)
        if isequal(data,imread(fullfile(root,'png',[panels{k} '.png']))),hits(end+1)=k;end %#ok<AGROW>
    end
    assert(isscalar(hits),'Submission:AssemblyTexture','Texture must equal exactly one source panel PNG.');
    panel=panels{hits};
end
