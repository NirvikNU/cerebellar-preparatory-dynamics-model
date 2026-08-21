function model = extract_intact_model(learnables)
    fieldNames = fieldnames(learnables);
    model = struct();

    for fieldIndex = 1:numel(fieldNames)
        fieldName = fieldNames{fieldIndex};
        model.(fieldName) = gather(extractdata(learnables.(fieldName)));
    end
end
