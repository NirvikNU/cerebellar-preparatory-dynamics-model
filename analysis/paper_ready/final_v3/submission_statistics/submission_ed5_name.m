function name=submission_ed5_name(name)
    % Fixed authorized panel/assembly identifiers; no pattern or palette expansion.
    old={'ED7a','ED7b','ED7c','Extended_Data_Figure_7'};
    current={'ED5a','ED5b','ED5c','Extended_Data_Figure_5'};
    match=find(strcmp(name,old));
    if ~isempty(match),assert(isscalar(match));name=current{match};end
end
