function saved=submission_ed5_native(saved,name)
    % Migrate only known identifier metadata in the persisted original graph.
    old={'ED7a','ED7b','ED7c'};current={'ED5a','ED5b','ED5c'};
    hit=find(strcmp(name,current));
    if ~isempty(hit)
        assert(isscalar(hit)&&strcmp(saved.graph.handleNodes{1}.properties.UserData.panel,old{hit}));
        saved.graph.handleNodes{1}.properties.UserData.panel=name;
    elseif strcmp(name,'Extended_Data_Figure_5')
        info=saved.graph.handleNodes{1}.properties.UserData;
        assert(strcmp(info.assembly,'Extended_Data_Figure_7')&&isequal(info.panels,old));
        saved.graph.handleNodes{1}.properties.UserData.assembly=name;
        saved.graph.handleNodes{1}.properties.UserData.panels=current;
        for j=1:numel(saved.graph.handleNodes)
            node=saved.graph.handleNodes{j};
            if strcmp(node.class,'matlab.graphics.primitive.Image')
                saved.graph.handleNodes{j}.properties.CData=texture(node.properties.CData);
            end
        end
        for j=1:numel(saved.snapshot.axes)
            for k=1:numel(saved.snapshot.axes{j}.objects)
                obj=saved.snapshot.axes{j}.objects{k};
                if strcmp(obj.type,'image')
                    saved.snapshot.axes{j}.objects{k}.properties.CData=texture(obj.properties.CData);
                end
            end
        end
    end
end

function value=texture(value)
    assert(isstruct(value)&&isequal(fieldnames(value),{'verifiedDerivedPanelTexture'}));
    assert(ismember(value.verifiedDerivedPanelTexture,{'ED7a','ED7b','ED7c'}));
    value.verifiedDerivedPanelTexture=submission_ed5_name(value.verifiedDerivedPanelTexture);
end
