function [vector, layout] = pack_v2_trainables(values)
    fields = v2_trainable_fields();
    vector = [];
    offset = 0;
    for fieldIndex = 1:numel(fields)
        name = fields{fieldIndex};
        value = values.(name);
        count = numel(value);
        layout.names{fieldIndex} = name;
        layout.sizes{fieldIndex} = size(value);
        layout.indices{fieldIndex} = offset + (1:count);
        offset = offset + count;
        flattened = reshape(value, [], 1);
        if isempty(vector)
            vector = flattened;
        else
            vector = cat(1, vector, flattened);
        end
    end
    layout.totalCount = offset;
end
