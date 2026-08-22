function model = unpack_v3_trainables(model, vector, layout)
    for fieldIndex = 1:numel(layout.names)
        name = layout.names{fieldIndex};
        model.(name) = reshape(vector(layout.indices{fieldIndex}), ...
            layout.sizes{fieldIndex});
    end
end
