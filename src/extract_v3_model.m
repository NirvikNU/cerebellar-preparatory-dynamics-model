function output = extract_v3_model(input)
    output = struct();
    names = fieldnames(input);
    for fieldIndex = 1:numel(names)
        value = input.(names{fieldIndex});
        if isa(value, 'dlarray')
            value = extractdata(value);
        end
        output.(names{fieldIndex}) = gather(value);
    end
end
